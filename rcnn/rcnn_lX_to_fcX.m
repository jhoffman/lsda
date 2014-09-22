function feat = rcnn_lX_to_fcX(feat, precomp_layer, layer, rcnn_model)
% feat = rcnn_lX_to_fcX(feat, layer, rcnn_model)
%   On-the-fly conversion of some layer (5 or higher) features to a final
%   fully connected layer using the weights and biases stored in 
%   rcnn_model.cnn.layers.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

% no-op for layer <= precomp_layer
if layer > precomp_layer
  for i = (precomp_layer+1):layer
    % weights{1} = matrix of CNN weights [input_dim x output_dim]
    % weights{2} = column vector of biases
    feat = bsxfun(@plus, feat*rcnn_model.cnn.layers(i).weights{1}, ...
        rcnn_model.cnn.layers(i).weights{2}');
    if i < length(rcnn_model.cnn.layers)
        feat = max(0,feat);
    end
  end
end
