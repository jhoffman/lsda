#!/bin/bash

echo "Downloading LSDA 7K model..."

wget --no-check-certificate https://www.eecs.berkeley.edu/~jhoffman/caffe_nets/rcnn_model7200.mat \
--output-document=data/rcnn_models/rcnn_model7200.mat

echo "Downloading R-CNN initial weights..."

wget --no-check-certificate \
https://www.eecs.berkeley.edu/~jhoffman/caffe_nets/finetune_ilsvrc13_val1+train1k_iter_50000 \
--output-document=data/caffe_nets/finetune_ilsvrc13_val1+train1k_iter_50000

echo "Done."
