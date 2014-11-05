addpath('selective_search');
if exist('selective_search/SelectiveSearchCodeIJCV')
  addpath('selective_search/SelectiveSearchCodeIJCV');
  addpath('selective_search/SelectiveSearchCodeIJCV/Dependencies');
else
  fprintf('Warning: you will need the selective search IJCV code.\n');
  fprintf('Press any key to download it (runs ./selective_search/fetch_selective_search.sh)> ');
  pause;
  system('./selective_search/fetch_selective_search.sh');
  addpath('selective_search/SelectiveSearchCodeIJCV');
  addpath('selective_search/SelectiveSearchCodeIJCV/Dependencies');
end
addpath('vis');
addpath('nms');
addpath('rcnn');
%addpath('external/libsvm-mat-3.12/');
if exist('external/caffe/matlab/caffe','dir')
  addpath('external/caffe/matlab/caffe');
else
  warning('Please install Caffe in ./external/caffe');
end
fprintf('Setting up caffe and loading models...');
model_loc = 'data/rcnn_models/rcnn_model7200.mat';
if ~exist(model_loc, 'file') || ~exist('data/caffe_nets/finetune_ilsvrc13_val1+train1k_iter_50000')
    fprintf('Warning: you need the LSDA model to run the demo.\n');
    fprintf('Press any key to download it (stores in data/rcnn_models/rcnn_model7200.mat)');
    pause;
    if ~exist('data/rcnn_models', 'dir')
        mkdir('data/rcnn_models');
    end
    if ~exist('data/caffe_nets', 'dir')
        mkdir('data/caffe_nets');
    end
    system('./data/fetch_lsda7k_model.sh');
end
load(model_loc);

fprintf(' Done.\n');
fprintf('Preparing models for detection use...');
% pre-multiply the detector weights by the final layer of caffe.
if size(rcnn_model.cnn.layers(end).weights{1},2) == size(rcnn_model.detectors.W,1)
  rcnn_model.cnn.layers(end).weights{1} = rcnn_model.cnn.layers(end).weights{1} * rcnn_model.detectors.W;
  rcnn_model.cnn.layers(end).weights{2} = rcnn_model.detectors.W' * rcnn_model.cnn.layers(end).weights{2};
end
rcnn_feat = rcnn_model;
rcnn_feat.training_opts.layer = 7;
if rcnn_feat.training_opts.layer == 5
    rcnn_feat.cnn.definition_file ='model-defs/imagenet_rcnn_batch_256_output_pool5.prototxt';
else
    rcnn_feat.cnn.definition_file ='model-defs/imagenet_rcnn_batch_256_output_fc7.prototxt';
end
rcnn_feat = rcnn_load_model(rcnn_feat);
fprintf(' Done.\n');

fprintf('LSDA startup done\n');
