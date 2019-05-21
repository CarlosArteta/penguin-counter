#!/bin/bash
FOLDERS=$1
GPU=$2

echo "Calling penguinCounter.m to process $FOLDERS on GPU $2"

LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6:/usr/local/cuda-8.0/lib64/libcudart.so.8.0:/usr/local/cuda-8.0/lib64/libcublas.so.8.0 matlab -nodisplay -r "try; penguinCounter('$FOLDERS', 'gpu', '$GPU'); catch; end; quit();"
