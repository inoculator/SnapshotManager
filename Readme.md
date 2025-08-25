# QEMU Snapshot Management

## DISCLAIMER

This is not for commercial use. There is no guarantee coming with those files. 
Use them on your own risk. If You do not know, what it is about, keep your hands off.
Do not use in production environments without peer review and excessive testing.

## prologue

This code comes from a very indivitualistique environment. As someone who is working with Powershell on a daily base,  
I wanted to step forward on my private Linux environment, switching from BASH to PWSH.  
Most of the regular maintenance I try to automate using Jenkins, while the infrastructure is based on QEMU as hypervisor.

## requirements

The scripts are developed under Powershell 7.5.1 on an Ubuntu 22.04
There is no guarantee, they work under different versions of Linux or Powershell.
Please test before usage!

## Description

This repo represents a collection of small function to enable snapshot management in QEMU / KVM under Linux using PowerShell.
The main focus is set to run with Jenkins as a controller to execute the management by  
* reading snapshots
* creating snapshots
* removing snaphots

## not included (as of 2025-08-25)

You can easily manage snapshots in QEMU if you are using fully virtualized machines.  
There is one gap if it comes to RAW disks. Actually ```virsh``` is not capable of doing snapshots for those completely seamlessly.  
You have to switch to a "disk-only" mode, where removal or reverting of snapshots get a little delight.
I have spared out this for now, but will try to solve it in future steps.

Also not included it a "revert to snapshot". This should always be done manual and not fully automated.

## Setup  

### Full Scale  

If you own a Jenkins Server you can pull the repo as is from it or fork it to your own Repo Server or whereever Your Jenkins has access to.
You can create 3 pipelines pointing to that repo and load each of the jenkinsfiles depending on the task you want to estabish.
All three jobs come with some parameter. Check the comments in each for details.
You need to change the Jenkins Agent to your QEMU/KVM machine. The Agent user has to have SUDO rights on VIRSH.

### intermediate Scale  

There is no need to run in full scale. You can use the functions also in a standalone or manual setup.
Just copy the files in the functions folder to you KVM host and load them from the pwsh console.
You can add them to your $profile to automate on startup.
Read the information in each function how to use them.

