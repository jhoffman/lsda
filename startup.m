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
fprintf('LSDA startup done\n');
