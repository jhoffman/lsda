function detect10k_demo(rcnn_model, rcnn_feat, imname, outname)
th = tic;
% Read image
im = imread(imname);

% Get boxes
numbox = 256*4;
boxes = extract_boxes(im, numbox);

% Extract per region features and scores
scores = per_region_features(rcnn_model, rcnn_feat, im, boxes);

% Prune the boxes based on scoresegprs
[top_boxes, cats_ids, ~] = prune_boxes(boxes, scores);
cats_found = rcnn_model.classes(cats_ids);
%[top_boxes, cats_ids, cats_found] = prune_boxes_hedging(boxes, scores, ...
%    rcnn_model.classes);


fprintf('\n Final time: %.3fs\n', toc(th));
% Show detections
m = min(length(cats_ids), 5);
if exist('outname', 'var')
    showdets(im, top_boxes(1:m,:), cats_found(1:m), cats_ids(1:m),outname);
else
    showdets(im, top_boxes(1:m,:), cats_found(1:m), cats_ids(1:m));
end
end

function [top_boxes, cats_ids, top_scores] = prune_boxes(boxes, scores)
max_numcat = 100;
th = tic;
fprintf('Prune boxes...');

% find scores > 0
[ind_c, c] = find(scores > 0);
nz_classes = unique(c);
if length(nz_classes) > max_numcat
    % subsample classes with top max_numcat scores
    t = max(scores(:, nz_classes));
    [~, ord] = sort(t, 'descend');
    nz_classes = nz_classes(ord(1:max_numcat));
end

top_boxes = zeros(50,5); % preallocate some space
cats_ids = zeros(50,1);
top_scores = zeros(50, size(scores,2));
index = 1;
thresh = 0.1; % percat threshold for nms
for i = 1:length(nz_classes)
    ind = c==nz_classes(i);
    sc = scores(ind_c(ind), nz_classes(i));
    scored_boxes = cat(2, boxes(ind_c(ind),:), sc);
    keep = nms(scored_boxes, thresh);
    indices = index:index+length(keep)-1;
    top_boxes(indices,:) = scored_boxes(keep,:);
    cats_ids(indices) = nz_classes(i)*ones(length(keep),1);
    
    index = index + length(keep);
    
    top_scores(indices,nz_classes(i)) = sc(keep);
end
top_boxes = top_boxes(1:index-1,:);
cats_ids = cats_ids(1:index-1);
top_scores = top_scores(1:index-1,:);

keep = nms(top_boxes,0.4);
cats_ids = cats_ids(keep);
top_boxes = top_boxes(keep,:);
top_scores = top_scores(keep,:);
ind = find(top_boxes(:,5) >= 1.0);
%
if length(ind) >= 2
    top_boxes = top_boxes(ind,:);
    cats_ids = cats_ids(ind);
    top_scores = top_scores(ind,:);
end
%}
fprintf(' done (ind %.3fs)\n', toc(th));
end

function boxes = extract_boxes(im, numbox)
th = tic;
fprintf('Extract boxes...');
fast_mode = true;
im_width = 500;
boxes = selective_search_boxes(im, fast_mode, im_width);
boxes = boxes(:, [2 1 4 3]); %[y1 x1 y2 x2] to [x1 y1 x2 y2]

numbox = min(numbox, size(boxes,1));
boxes = single(boxes(1:numbox,:));
fprintf(' found %d boxes: done (in %.3fs)\n', size(boxes, 1), toc(th));
end

function feat = per_region_features(rcnn_model, rcnn_feat, im, boxes)
fprintf('Extracting CNN features from regions...');
th = tic();
tt = tic;
feat = rcnn_features(im, boxes, rcnn_feat);
fprintf('ft comp in %.3f\n', toc(tt));
feat = rcnn_lX_to_fcX(feat, length(rcnn_feat.cnn.layers), 8, rcnn_model);
ft_norm = rcnn_model.training_opts.feat_norm_mean;
feat = rcnn_scale_features(feat, ft_norm);
fprintf('done (in %.3fs).\n', toc(th));
end

function [top_boxes, cats_ids, cats_found] = prune_boxes_hedging(boxes, scores, cats)

th = tic;
fprintf('Prune boxes...');

% find scores > 0
[ind_c, c] = find(scores > 0);
nz_classes = unique(c);
top_boxes = zeros(50,5); % preallocate some space
top_scores = zeros(50, size(scores,2));
index = 1;
thresh = 0.1; % percat threshold for nms
for i = 1:length(nz_classes)
    ind = c==nz_classes(i);
    sc = scores(ind_c(ind), :);
    scored_boxes = cat(2, boxes(ind_c(ind),:), sc(:,nz_classes(i)));
    keep = nms(scored_boxes, thresh);
    indices = index:index+length(keep)-1;
    top_boxes(indices,:) = scored_boxes(keep,:);
    
    index = index + length(keep);
    
    top_scores(indices,:) = sc(keep,:);
    %top_scores(top_scores < 0) = 0;
end
top_boxes = top_boxes(1:index-1,:);
top_scores = top_scores(1:index-1,:);


load meta10K
lambda =-5;%.05;
tree = synsets;
all_cats = {synsets(:).words};
num_leaves = 7404;
if size(top_scores,2) > num_leaves
    sc = top_scores(:, 201:end);
    sc200 = top_scores(:,1:200);
    probs200 = exp(sc200);
    probs200 = bsxfun(@rdivide, probs200, sum(probs200,2));
    top_scores(:,1:200) = probs200;
    all_cats = [cats(1:200) all_cats];
else
    sc = top_scores;
end

%sc = sc*5;
leaf_probs = exp(sc);
leaf_probs = bsxfun(@rdivide, leaf_probs, sum(leaf_probs,2));
all_probs = get_all_probs(leaf_probs, tree);
top_scores(:,201:200+size(all_probs,2)) = all_probs;

rewards = info_rewards(tree);
rewards = rewards + lambda;
%rewards = rewards ./ max(rewards);

% Simply get the expected reward of each node for each image and take the max.
expected_rewards = bsxfun(@times, all_probs, rewards(:)');

[e_vals,cats_ids] = max(expected_rewards, [],2);
[mv, mi] = max(probs200,[],2);
%e_vals = e_vals*15;
%
for i = 1:size(all_probs,1)
    top_boxes(i,5) = all_probs(i, cats_ids(i));
    if size(top_scores,2) > num_leaves
        % check if one of the 200 has a higher cat
        %mv, mi] = max( sc200(i,:) );
        %[mv, mi] = max( probs200(i,:) );
        if mv(i) > e_vals(i) %top_boxes(i,5)
            top_boxes(i,5) = mv(i);
            cats_ids(i) = mi(i);
        else
            top_boxes(i,5) = e_vals(i);
            cats_ids(i) = cats_ids(i) + 200;
        end
    end      
end
%}


keep = nms(top_boxes,0.5);
cats_ids = cats_ids(keep);
top_boxes = top_boxes(keep,:);
top_scores = top_scores(keep,:);

%
ind = find(top_boxes(:,5) >= 1.0);
if length(ind) >= 2
    top_boxes = top_boxes(ind,:);
    cats_ids = cats_ids(ind);
    top_scores = top_scores(ind,:);
end
%}
cats_found = all_cats(cats_ids);

fprintf(' done (ind %.3fs)\n', toc(th));
end
