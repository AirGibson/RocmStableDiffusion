# RocmStableDiffusion
Dockerfiles for building an image including Stable Diffusion and kohya_ss running with the required ROCm 6.0.2 software for AMD GPUs.
This project is heavily influenced by Matteo Pacini's similar project from 2023 which has been closed and archived here: https://github.com/matteo-pacini/RoCMyDocker

## Description
Given the many combinations of AMD Radeon GPUs, the ROCm software that provides the interfaces for machine learning, and the many different requirements for Stable Diffusion, it can be challenging to get a working combination. Compounding the challenge is that many of the various "how to" guides instruct users to pull "latest" tag versions of the various software involved which doesn't always work as expected since some of these projects have changed significantly in short amounts of time. This particular project's goals are to:
* Build a Docker image that leverages the 6.0.2 ROCm software to execute specivic version of Stable Diffusion / Automatic1111 with AMD GPU support.
* Ensure the image can execute as a user other than root.
* Provide a docker-compose with common mappings for allowing the user to access the typical configuration and output folders.
* Provide a final image checkpoint with all Automatic1111 requirements installed to speed up start-up time.

## Hardware 

⚠️ These Dockerfiles have been tested on my Linux distribution and hardware only. Contributions to expand compatibility are welcomed!

| Distro Name            | Kernel Version        | CPU                           | GPU                                              | VRAM |
|------------------------|-----------------------|-------------------------------|--------------------------------------------------|------|
| Ubuntu                 | 22.04.4 LTS           | AMD Ryzen 7 5800X3D (8-core)  | AMD Radeon RX 6900 XT (Navi 21)                  | 16GB |

## Getting Started

### Dependencies
The hardware drivers from AMD must be installed on the host system so that the hardware can be exposed to the container.  I have installed the following specific version.  Which version you use could significantly impact compatibility with the underlying software:
  
* Radeon Software for Linux - version 23.40.2 for Ubuntu 22.04.3 HWE with ROCm 6.0.2 - Install the software and grant your user account access to the **render** and **video** groups. 
```
sudo apt update 
wget https://repo.radeon.com/amdgpu-install/23.40.2/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb 
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb 
sudo amdgpu-install -y --usecase=graphics,rocm 
sudo usermod -a -G render,video $LOGNAME 
sudo reboot
```
