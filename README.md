# RocmStableDiffusion
Dockerfiles for building an image including Stable Diffusion and kohya_ss running with the required ROCm 6.0.2 software for AMD GPUs.

## Description
Given the many combinations of AMD Radeon GPUs, the ROCm software that provides the interfaces for machine learning, and the many different requirements for Stable Diffusion, it can be challenging to get a working combination. This particular project's goals are to:
* Build a Docker image that leverages the 6.0.2 ROCm software to execute Stable Diffusion / Automatic1111 with AMD GPU support.
* Ensure the image can execute as a user other than root.
* Provide a docker-compose with common mappings for allowing the user to access the typical configuration and output folders.
* Provide a final image checkpoint with all Automatic1111 requirements installed to speed up start-up time.

## Getting Started

### Dependencies
I am unclear on how flexible this is with different linux versions.  I do know that the Radeon drivers are necessary

* Ubuntu 22.04.4 LTS
  
* Radeon Software for Linux - version 23.40.2 for Ubuntu 22.04.3 HWE with ROCm 6.0.2 - Install the software and grant your user account access to the **render** and **video** groups. 
```
sudo apt update 
wget https://repo.radeon.com/amdgpu-install/23.40.2/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb 
# Install AMD unified driver package repos and install script 
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb 
# Install AMD unified kernel-mode GPU driver, ROCm, and graphics 
sudo amdgpu-install -y --usecase=graphics,rocm 
sudo usermod -a -G render,video $LOGNAME 
sudo reboot
```
