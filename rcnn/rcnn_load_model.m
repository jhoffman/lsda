function rcnn_model = rcnn_load_model(rcnn_model_or_file, use_gpu, device_id)
% rcnn_model = rcnn_load_model(rcnn_model_or_file, use_gpu)
%   Takes an rcnn_model structure and loads the associated Caffe
%   CNN into memory. Since this is nasty global state that is carried
%   around, a randomly generated 'key' (or handle) is returned.
%   Before making calls to caffe it's a good idea to check that
%   rcnn_model.cnn.key is the same as caffe('get_init_key').

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

if isstr(rcnn_model_or_file)
  assert(exist(rcnn_model_or_file, 'file') ~= 0);
  ld = load(rcnn_model_or_file);
  rcnn_model = ld.rcnn_model; clear ld;
else
  rcnn_model = rcnn_model_or_file;
end

assert(exist(rcnn_model.cnn.binary_file, 'file')>0, 'Missing cnn binary file: please run data/fetch_lsda7k_model.sh');
assert(exist(rcnn_model.cnn.definition_file, 'file')>0, 'Missing definition file -- update repo');

rcnn_model.cnn.init_key = ...
    caffe('init', rcnn_model.cnn.definition_file, rcnn_model.cnn.binary_file);
if exist('use_gpu', 'var') && ~use_gpu
  caffe('set_mode_cpu');
else
  caffe('set_mode_gpu');
  if exist('device_id', 'var')
      caffe('set_device',device_id);
  else
      caffe('set_device',0);
  end
end
caffe('set_phase_test');
rcnn_model.cnn.layers = caffe('get_weights');
