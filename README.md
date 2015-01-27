Large Scale Detection through Adaptation
========

Demo code available at: https://github.com/jhoffman/lsda
This code accompanies the arXiv report.

Download pre-trained 7.5K model:
-------

* Includes all leaf synsets + 200 detection categories
* Pre-trained Detection Model: https://www.eecs.berkeley.edu/~jhoffman/caffe_nets/rcnn_model7200.mat
* Caffe Weights for 200 strong detectors: https://www.eecs.berkeley.edu/~jhoffman/caffe_nets/finetune_ilsvrc13_val1+train1k_iter_50000
* Caffe Weights for 7K weak detectors: https://www.eecs.berkeley.edu/~jhoffman/caffe_nets/imagenet7k_det_ilsvrc_2013_fc8_iter_74040

To try out an example, run:
    
    startup;
    detect10k_demo(rcnn_model, rcnn_feat, 'ex_img.jpg');

Dependency
-------

This code requires Caffe to be installed. For Installation instructions
visit: http://caffe.berkeleyvision.org


Citing
-------

    "LSDA: Large Scale Detection Through Adaptation." J. Hoffman, 
    S. Guadarrama, E. Tzeng, R. Hu, J. Donahue, R. Girshick, T. Darrell, and
    K. Saenko. Neural Information Processing Systems (NIPS), 2014.

http://arxiv.org/abs/1407.5035
