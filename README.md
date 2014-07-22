Large Scale Detection through Adaptation
========

Demo code available at: https://github.com/jhoffman/lsda
This code accompanies the arXiv report.

Download pre-trained 7.5K model:
-------

* Includes all leaf synsets + 200 detection categories
* Pre-trained Model: https://www.eecs.berkeley.edu/~jhoffman/caffe_nets/rcnn_model7200.mat

To try out an example, run:
    
    load data/rcnn_models/rcnn_model7200.mat;
    detect10k_demo(rcnn_model, 'ex_img.jpg');

Dependency
-------

This code requires Caffe to be installed. For Installation instructions
visit: http://caffe.berkeleyvision.org


Citing
-------

    "LSDA: Large Scale Detection Through Adaptation." J. Hoffman, 
    S. Guadarrama, E. Tzeng, J. Donahue, R. Girshick, T. Darrell, and
    K. Saenko. arXiv:1407.5035

http://arxiv.org/abs/1407.5035
