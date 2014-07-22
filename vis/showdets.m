function showdets(im, boxes, names, ids, out)
% Draw bounding boxes on top of an image.
%   showboxes(im, boxes, out)
%
%   If out is given, a pdf of the image is generated (requires export_fig).

% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% Copyright (C) 2008, 2009, 2010 Pedro Felzenszwalb, Ross Girshick
% Copyright (C) 2007 Pedro Felzenszwalb, Deva Ramanan
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------

if nargin > 4
  % different settings for producing pdfs
  toprint = true;
  %wwidth = 2.25;
  %cwidth = 1.25;
  cwidth = 2;%1.4;
  wwidth = cwidth + 1.1;
  %imsz = size(im);
  % resize so that the image is 300 pixels per inch
  % and 1.2 inches tall
  %scale = 1.2 / (imsz(1)/300);
  %im = imresize(im, scale, 'method', 'cubic');
  %boxes = (boxes-1)*scale+1;
else
  toprint = false;
  cwidth = 2;
end

if toprint
    h = figure('visible', 'off');
    image(im);
    truesize(h);
else
    h = figure;
    image(im);
end

axis image;
axis off;
set(h, 'Color', 'white');

if ~isempty(boxes)
  numfilters = size(boxes,1);%floor(size(boxes, 2)/4);
  if toprint
    % if printing, increase the contrast around the boxes
    % by printing a white box under each color box
    for i = numfilters:-1:1
      x1 = boxes(i,1);%boxes(:,1+(i-1)*4);
      y1 = boxes(i,2);%boxes(:,2+(i-1)*4);
      x2 = boxes(i,3);%boxes(:,3+(i-1)*4);
      y2 = boxes(i,4);%boxes(:,4+(i-1)*4);
      % remove unused filters
      del = find(((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0)) == 1);
      x1(del) = [];
      x2(del) = [];
      y1(del) = [];
      y2(del) = [];
      if i == 1
        w = wwidth;
      else
        w = wwidth;
      end
      c='w';
      line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', w);   
    end
  end
  
  % draw the boxes with the detection window on top (reverse order)
  for i = numfilters:-1:1
    x1 = boxes(i,1);%boxes(:,1+(i-1)*4);
    y1 = boxes(i,2);%boxes(:,2+(i-1)*4);
    x2 = boxes(i,3);%boxes(:,3+(i-1)*4);
    y2 = boxes(i,4);%boxes(:,4+(i-1)*4);
    % remove unused filters
    del = find(((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0)) == 1);
    x1(del) = [];
    x2(del) = [];
    y1(del) = [];
    y2(del) = [];
    if ids(i) > 200 
      c = 'r'; %[160/255 0 0];
      s = '-';
    else
      c = 'b';
      s = '-';
    end
    line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', cwidth, 'linestyle', s);
    ss = regexp(names{i}, ',', 'split');
    text(double(x1-5),double(y2+5),sprintf('%s: %2.1f', ss{1}, boxes(i,5)),...
        'BackgroundColor', [0.7 0.9 0.7], 'FontSize', 12);
  end
end

% save to pdf
if toprint
  % requires export_fig from http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig
  %export_fig([out]);
  %saveas(h, out);
  im_new = frame2im(getframe(h));
  imwrite(im_new, out);
end
