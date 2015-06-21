# Setup An Amazon EC2 GPU Instance for Deep Learning

__Last updated: 2015-05-04__

## From scratch

### Create EC2 GPU Instance

After you registered at AWS (Amazon Web Services), you should be able to create EC2 instance.

Choose `Launch`, then select `Ubuntu Server 14.04 LTS (HVM), SSD Volume Type`, then choose `g2.2xlarge` instance type.

The initial storage on the instance settings is 8GB, but it's far from enough. I personally pushed to 500GB so that I can have enough room for installing packages, drivers, databases, etc.

Amazon AWS now is offering another type of GPU instance, and it's a lot more powerful, it's `g2.8xlarge`. You can get much more detailed information from [here](http://aws.amazon.com/ec2/instance-types/).

### Install packages.

You got a brand new Ubuntu machine after your instance is running successfully.

Home folder of the instance is empty, for further usage, we can create a `Downloads` folder to store all downloads

~~~
mkdir Downloads
~~~

Firstly, you need to update your update library by:

~~~
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install linux-headers-generic linux-headers-virtual linux-image-virtual linux-virtual
sudo apt-get install linux-image-extra-virtual
~~~

__Reboot your instance by rebooting it.__

Then, you need to install `build-essential` to enable your development support:

~~~
sudo apt-get install build-essential binutils
~~~

Some supporting libraries needed for getting and building your project later:

~~~
sudo apt-get install git cmake
~~~

Theano and Caffe are two popular deep learning framework. In this instance, we are going to support them. You need to install following packages:

~~~
sudo apt-get install libopenblas-dev libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libboost-all-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler libtiff4-dev
~~~

Your BLAS in this case is openBLAS.

You may also need Java support for some cases:

~~~
sudo apt-get install openjdk-7-jdk
~~~

__Reboot your instance by rebooting it.__

### Scientific Python Support from Anaconda

Anaconda is an awesome Python distribution for large-scale data processing, predictive analysis, and scientific computing. It contains many well-known packages and maintained it well. Therefore, instead of messing with Ubuntu's Python, we use Anaconda's Python. Anaconda provides a clean installation, and once you don't need it, you can simply delete it from home folder.

First, get Anaconda (use Anaconda Python 2.7) (Note that as I'm writing, latest Anaconda is 2.2.0, you can download the latest version from [here](http://continuum.io/downloads) also):

~~~
cd Downloads
wget https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.2.0-Linux-x86_64.sh
~~~

After download, you simply run the bash file:

~~~
bash ./Anaconda-2.2.0-Linux-x86_64.sh
~~~

Follow the default instruction, you should be able to find a new folder: `anaconda` in your home folder. Now if you check you Python's version, it should give you:

~~~
Python 2.7.9 :: Anaconda 2.2.0 (64-bit)
~~~

Otherwise, you need to add Anaconda's path to your `.bashrc`

~~~
nano ~/.bashrc
~~~

Add following line to the end of the file

~~~
export PATH="/home/ubuntu/anaconda/bin:$PATH"
~~~

Press `Ctrl+X` to save and exit, then you need to source the file to enable current setting:

~~~
source ~/.bashrc
~~~

Update all packages in Anaconda

~~~
conda update --all
~~~

### GPU Driver and CUDA Support

#### Install GPU Driver

Check your instance's graphic card by:

~~~
lspci | grep -i nvidia
~~~

It should give you something similar to this:

```
00:03.0 VGA compatible controller: NVIDIA Corporation GK104GL [GRID K520] (rev a1)
```

Nvidia Grid K520 is a Cloud Gaming Graphic Card, it got 2 GK104 GPUs where each of GPU has 1536 CUDA cores. The compute capability is 3.0, so you can install latest cuDNN support. If you are using `g2.8xlarge`, then you will get 4 GPUs on board.

You need to download the driver for Grid K520 firstly from [here](http://www.nvidia.com/Download/index.aspx?lang=en-us). You also can use this address to download:

~~~
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/346.59/NVIDIA-Linux-x86_64-346.59.run
~~~

You will not be able to install it because `nouveau` of the system is still on. The installer will add a blacklist to `nouveau` and quit. After the installer quited, you need to update your system by:

~~~
cd /etc/modprobe.d/
sudo nano blacklist.conf
~~~

Add `blacklist nouveau` at the end of `blacklist.conf`.

~~~
sudo update-initramfs -u
~~~

__Reboot your instance by stopping and starting it.__

Then you can simply install the driver by:

~~~
sudo bash NVIDIA-Linux-x86_64-346.59.run
~~~

#### Install CUDA Toolkit

You need to get recent CUDA Toolkit in order to use your GPU:

~~~
wget http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/cuda_7.0.28_linux.run
~~~

This will take a while, you may want to grab a coffee.

And install CUDA by:
~~~
sudo bash cuda_7.0.28_linux64.run
~~~

**DO NOT INSTALL GPU DRIVER INSIDE THE CUDA TOOLKIT**

Add following line to end of your `.bashrc` file.

~~~
# This configuration uses CUDA's symbolic link
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
export CUDA_ROOT=/usr/local/cuda
~~~

#### Install cuDNN

Download cuDNN from [here](https://developer.nvidia.com/cuDNN). You need to register a membership if you want to request a copy. The evaluation will take a while. At this time, the latest version of this library is cuDNN v2

Extract cuDNN

~~~
tar zxvf cudnn-6.5-linux-x64-v2.tgz
~~~

Copy extracted files to CUDA folder

~~~
sudo cp cudnn.h /usr/local/cuda-7.0/include
sudo cp libcudnn* /usr/local/cuda-7.0/lib64
~~~

### Theano support

Create Theano's configuration file:

~~~
touch $HOME/.theanorc
~~~

and modify it as

~~~
[global]
floatX = float32
device = gpu0

[nvcc]
fastmath = True

[cuda]
root = /usr/local/cuda
~~~

You can use [this test](http://deeplearning.net/software/theano/tutorial/using_gpu.html#testing-theano-with-gpu) to valid your installation.

### Caffe support [UNDER REVISION]

Caffe recently supports Nvidia's new machine learning library --- cuDNN. It improves Caffe's performance. Note that cuDNN requires that the graphic card has at least 3.0 of compute capability. Graphic card of this instance is 3.0.

Clone Caffe from GitHub

~~~
cd ~
git clone https://github.com/BVLC/caffe
~~~

There are several libraries needed for Caffe's Python support, we can install them by:

~~~
pip install leveldb
pip install protobuf
pip install python-gflags
~~~

After you installed Python dependencies, we can start to modify Caffe's `make` configurations.

1. Enable `USE_CUDNN := 1`
2. Change `BLAS := atlas` to `BLAS := open`
3. Comment system's Python support and enable Anaconda's Python support.
4. Comment system's Python library support and enable Anaconda's Python library support.

Some Anaconda release has bad `libm` library, we need to force the compiler to choose the one from system:

~~~
$ cd ~/anaconda/lib
$ mv libm.so.6 libm.so.6.tmp
$ mv lib.so lib.so.tmp
~~~

Your final `.bashrc` should look like this

~~~
# added by Anaconda 2.1.0 installer
export PATH="/home/ubuntu/anaconda/bin:$PATH"
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/home/ubuntu/anaconda/lib:/usr/local/lib:/usr/lib
export CUDA_ROOT=/usr/local/cuda
export CAFFE_ROOT=/home/ubuntu/caffe
~~~

Build Caffe

~~~
$ make all -j8
$ make test
$ make runtest
~~~

You might run into one problem when you compile:

~~~
src/caffe/util/math_functions.cu(140): error: calling a __host__ function("std::signbit<float> ") from a __global__ function("caffe::sgnbit_kernel<float> ") is not allowed
src/caffe/util/math_functions.cu(140): error: calling a __host__ function("std::signbit<double> ") from a __global__ function("caffe::sgnbit_kernel<double> ") is not allowed
2 errors detected in the compilation of "/tmp/tmpxft_00003c94_00000000-12_math_functions.compute_35.cpp1.ii".
make: *** [build/src/caffe/util/math_functions.cuo] Error 2
~~~

You can change `caffe/include/caffe/util/math_functions.hpp`, try change

~~~ cpp
using std::signbit;
DEFINE_CAFFE_CPU_UNARY_FUNC(sgnbit, y[i] = signbit(x[i]));
~~~

to

~~~ cpp
// using std::signbit;
DEFINE_CAFFE_CPU_UNARY_FUNC(sgnbit, y[i] = std::signbit(x[i]));
~~~

You should have 2 Disabled tests, the reason is from OpenCV part.

## From AMI (Amazon Machine Image)

I made two ready-to-use AMIs so that you don't have to be so painful for these technical details.

I made this AMI public so that you can use it to launch a new instance or make a spot request (Asia Singapore).

+ __DGYDLGPUv4__ (ami-ba516ee8) [Based on g2.2xlarge]
+ __DGYDLGPUXv1__ (ami-52516e00) [Based on g2.8xlarge]

If you are primarily using Caffe, now you can use an AMI that is built by Caffe in US East (N. Virginia):

+ __Caffe/CuDNN built 2015-05-04__ (ami-763a331e) [For both g2.2xlarge and g2.8xlarge]

## Contacts

Hu Yuhuang  
Advanced Robotic Lab  
Department of Artificial Intelligence  
Faculty of Computer Science & IT  
University of Malaya  
Email: duguyue100@gmail.com
