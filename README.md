AWS GPU Instance for Deep Learning
========

A description for setting up an Amazon EC2 GPU instance for Deep Learning.

Find the description [here](../master/aws_for_dl.md).

## Updates

+ Setup guide is uploaded [2014-10-15]
+ DGYDLGPUv2 is up, you can search this AMI from public images. [2014-10-15]

## Todo

+ Clean current AMI for saving space
+ Prepare DGYDLGPUv3
   + Prepare installation script for the server [Design for Ubuntu 14.04]
   + Prepare another version with remote desktop
   + Web access for submitting gpu scripts

## Notes

+ Just now I updated kernel version to `Linux 3.13.0-39-generic`, however, under this kernel, Nvidia's driver cannot be loaded, your `modprobe` may report `FATAL: Module nvidia not found` (as I'm writing, I installed the latest driver 340.32). Therefore I have to switch down to `Linux 3.13.0-37-generic`. You should do following in order to perform this action:
   1. Reboot your system, press `Shift` key while it's booting up. Choose `Advanced Options` and select a older version, in my case, I chose `Linux 3.13.0-37-generic`. You now should be able to use this old kernel.
   2. Open a terminal and start to edit `grub`'s config.

      ```
      $ sudo /etc/default/grub
      ```
   3. Change `DEFAULT_GRUB=0` to `DEFAULT_GRUB=saved`. And save the modification.
   4. In you terminal, execute
   
      ```
      sudo grub-set-default "Ubuntu, with Linux 3.13.0-37-generic"
      ```
   5. And execute
   
      ```
      sudo update-grub
      ```
   6. However, this will not actually update your boot kernel becaue `"Ubuntu, with Linux 3.13.0-37-generic"` is acutally old title. `update-grub` actually will give you the correct title for the choice. So re-execute `grub-set-default` again with correct title and then execute `update-grub`.
   7. Now reboot your machine, you should be able to boot your machine from old kernel version.

## Contacts

Hu Yuhuang  
Advanced Robotic Lab  
Department of Artificial Intelligence  
Faculty of Computer Science & IT  
University of Malaya  
Email: duguyue100@gmail.com
