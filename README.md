Large Scale Detection through Adaptation
========
This code accompanies the arXiv report: 
"LSDA: Large Scale Detection Through Adaptation." J. Hoffman, 
S. Guadarrama, E. Tzeng, J. Donahue, R. Girshick, T. Darrell, and
K. Saenko. arXiv:1407.5035

To try out an example, run:
load rcnn_model7200.mat;
detect10k_demo(rcnn_model, 'ex_img.jpg');

This code requires Caffe to be installed. For Installation instructions
visit: http://caffe.berkeleyvision.org
