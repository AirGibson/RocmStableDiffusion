# RocmStableDiffusion
Dockerfiles for building an image including Stable Diffusion and kohya_ss running with the required ROCm 6.0.2 software for AMD GPUs.
This project is heavily influenced by Matteo Pacini's similar project from 2023 which has been closed and archived here: https://github.com/matteo-pacini/RoCMyDocker
This is in a rough "first draft" state and I welcome all contributions to make this more flexible for other users.

## Description
Given the many combinations of AMD Radeon GPUs, the ROCm software that provides the interfaces for machine learning, and the many different requirements for Stable Diffusion, Automatic1111 web ui, and kohya_ss, it can be challenging to get a working combination. Compounding the challenge is that many of the various "how to" guides instruct users to pull "latest" tag versions of the various software involved which doesn't always work as expected since some of these projects have changed significantly in short amounts of time. This particular project's goals are to:
* Build a Docker image based on a **rocm/pytorch** that will install a specific version of Stable Diffusion / Automatic1111 and kohya_ss with AMD GPU support compatible with our selected hardware, drivers, and OS.
* Ensure the image can execute as a user other than root.
* Provide a docker-compose with common mappings for allowing the user to access the typical configuration and output folders.


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

### Get the project, tune the image, and Build your Docker images
Obtain the project using git and change into the project directory of your choice, then review the entrypoint.sh file to add any options you may need for your particular setup.
```
cd ~
git clone https://github.com/AirGibson/RocmStableDiffusion
cd ./RocmStableDiffusion/automatic1111
```

Once you're ready, build the docker image.
```
docker build -t airgibson/rocmautomatic1111:1.0 .
```

## Set Up Volume Folders
Create a directory structure for accessing the necessary AUTOMATIC1111 folders such as models, output, etc... so that they can be mounted as volumes.
```
mkdir -p ~/sd/output
mkdir ~/sd/extensions
mkdir ~/sd/models
mkdir ~/sd/styles
```

## Start The Containers
You can start the two containers via the typical "docker run" command, or using docker-compose.  

### Docker Run
```
docker run --name rocmstablediffusion --restart always -i -t -p 8090:7860 --cap-add SYS_PTRACE --security-opt seccomp=unconfined --device /dev/kfd --device /dev/dri --group-add render --group-add video --ipc host --shm-size 8G -v $HOME/sd/models/Stable-diffusion:/workdir/stable-diffusion-webui/models/Stable-diffusion -v $HOME/sd/output:/workdir/stable-diffusion-webui/output -v $HOME/sd/styles:/workdir/stable-diffusion-webui/styles -v $HOME/sd/extensions:/workdir/stable-diffusion-webui/extensions -v $HOME/sd/models/extensions:/workdir/stable-diffusion-webui/models/extensions -v $HOME/sd/models/VAE:/workdir/stable-diffusion-webui/models/VAE airgibson/rocmstablediffusion:1.0
 
docker run --name rocmkohyass --restart always -i -t -p 8091:7860 --cap-add SYS_PTRACE --security-opt seccomp=unconfined --device /dev/kfd --device /dev/dri --group-add render --group-add video --ipc host --shm-size 8G airgibson/rocmkohyass:1.0
```

### Docker-Compose
Here is a sample of a docker-compose file for starting both containers.
```
name: mystack
services:
    rocmstablediffusion:
        container_name: rocmstablediffusion
        restart: always
        stdin_open: true
        tty: true
        ports:
            - 8090:7860
        cap_add:
            - SYS_PTRACE
        security_opt:
            - seccomp=unconfined
        devices:
            - /dev/kfd
            - /dev/dri
        group_add:
            - render
            - video
        ipc: host
        shm_size: 8G
        image: airgibson/rocmstablediffusion:1.0
        volumes:
            - $HOME/sd/models/Stable-diffusion:/workdir/stable-diffusion-webui/models/Stable-diffusion 
            - $HOME/sd/output:/workdir/stable-diffusion-webui/output 
            - $HOME/sd/styles:/workdir/stable-diffusion-webui/styles 
            - $HOME/sd/extensions:/workdir/stable-diffusion-webui/extensions 
            - $HOME/sd/models/extensions:/workdir/stable-diffusion-webui/models/extensions 
            - $HOME/sd/models/VAE:/workdir/stable-diffusion-webui/models/VAE 


    rocmkohyass:
        container_name: rocmkohyass
        restart: always
        stdin_open: true
        tty: true
        ports:
            - 8091:7860
        cap_add:
            - SYS_PTRACE
        security_opt:
            - seccomp=unconfined
        devices:
            - /dev/kfd
            - /dev/dri
        group_add:
            - render
            - video
        ipc: host
        shm_size: 8G
        image: airgibson/rocmkohyass:1.0
```

