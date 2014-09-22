#!/bin/bash

mkdir data/rcnn_models

echo "Downloading LSDA 7K model..."

wget https://www.eecs.berkeley.edu/~jhoffman/caffe_nets/rcnn_model7200.mat

echo "Done."
