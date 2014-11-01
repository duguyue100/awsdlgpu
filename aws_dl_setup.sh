#!/bin/sh

# This script is to automatically setup a AWS instance for deep learning
# This script will be manually updated based on schedule
# Author      : Hu Yuhuang
# Last update : 2014-11-01

# setup download space

cd ~;

if [ ! -d "Downloads" ]; then
    mkdir Downloads;
fi

cd Downloads;

# update system

sudo apt-get update -y;
sudo apt-get upgrade -y;
sudo apt-get linux-headers-generic linux-headers-virtual linux-image-virtual linux-virtual -y;
sudo apt-get linux-image-extra-virtual -y;

# for development support

sudo apt-get build-essential gcc g++ make binutils linux-headers-`uname -r` -y;

# git and cmake

sudo apt-get install git cmake -y;

# dependencies for Theano and Caffe

$ sudo apt-get install libopenblas-dev libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libboost-all-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler -y

# java support

sudo apt-get install openjdk-7-jdk;

# get and install Anaconda

wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-2.1.0-Linux-x86_64.sh

sh Anaconda*.sh

# block default graphic module

sudo echo "blacklist vga16fb" >> /etc/modprobe.d/blacklist.conf
sudo echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
sudo echo "blacklist rivafb" >> /etc/modprobe.d/blacklist.conf
sudo echo "blacklist nvidiafb" >> /etc/modprobe.d/blacklist.conf
sudo echo "blacklist rivatv" >> /etc/modprobe.d/blacklist.conf

sudo update-initramfs -u

# install GPU Driver
# The driver's version is 340.46 [up to 2014-11-1]

wget http://us.download.nvidia.com/XFree86/Linux-x86_64/340.46/NVIDIA-Linux-x86_64-340.46.run

sudo sh NVIDIA-Linux-x86_64-340.46.run

# get and install CUDA 6.5 [up to 2014-11-1]
# DO NOT INSTALL THE DRIVER INSIDE CUDA

wget http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run

sudo sh cuda_6.5.14_linux_64.run

# update .bashrc

echo "export PATH=$PATH:/usr/local/cuda/bin" >> ~/.bashrc;
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64 #if 64bit machine" >> ~/.bashrc;
echo "export CUDA_ROOT=/usr/local/cuda" >> ~/.bashrc;

# update theano config

touch ~/.theanorc

echo "[global]" >> ~/.theanorc
echo "floatX = float32" >> ~/.theanorc
echo "device = gpu0" >> ~/.theanorc

echo "[nvcc]" >> ~/.theanorc
echo "fastmath = true" >> ~/.theanorc

echo "[cuda]" >> ~/.theanorc
echo "root=/usr/local/cuda" >> ~/.theanorc

# Caffe support

# cuDNN [up to 2014-11-1 ]
wget http://arl.fsktm.um.edu.my/cudnn-6.5-linux-R1.tgz

tar zxvf cudnn-6.5-linux-R1.tgz

sudo cp cudnn.h /usr/local/cuda-6.5/include
sudo cp libcudnn* /usr/local/cuda-6.5/lib64

# get Caffe

cd ~
git clone https://github.com/BVLC/caffe

# install additional dependencies for python

pip install leveldb
pip install protobuf
pip install python-gflags

# use a working version of caffe configuration file

cp ~/awsdlgpu/Makefile.config ~/caffe

# update .bashrc

echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ubuntu/anaconda/lib:/usr/local/lib:/usr/lib" >> ~/.bashrc;
echo "export CAFFE_ROOT=/home/ubuntu/caffe" >> ~/.bashrc;

# some anaconda library modification for compiling caffe

cd ~/anaconda/lib
mv libm.so.6 libm.so.6.tmp
mv lib.so lib.so.tmp

# build caffe

cd ~/caffe

make all -j8
make test
make runtest

# cleaning the installers

cd ~/Downloads

rm Anaconda*.sh
rm NVIDIA-Linux-x86_64-340.46.run
rm cudnn-6.5-linux-R1.tgz
rm cuda_6.5.14_linux_64.run
