# RocmStableDiffusion
Dockerfiles for building an image including Stable Diffusion and kohya_ss running with the required ROCm 6.0.2 software for AMD GPUs.
This project is heavily influenced by Matteo Pacini's similar project from 2023 which has been closed and archived here: https://github.com/matteo-pacini/RoCMyDocker
This is in a rough "first draft" state and I welcome all contributions to make this more flexible for other users.

## Description
Given the many combinations of AMD Radeon GPUs, the ROCm software that provides the interfaces for machine learning, and the many different requirements for Stable Diffusion, Automatic1111 web ui, and kohya_ss, it can be challenging to get a working combination. Compounding the challenge is that many of the various "how to" guides instruct users to pull "latest" tag versions of the various software involved which doesn't always work as expected since some of these projects have changed significantly in short amounts of time. This particular project's goals are to:
* Build a Docker image that will install a specific version of the ROCm software, Stable Diffusion / Automatic1111, and kohya_ss with AMD GPU support compatible with our selected hardware, drivers, and OS.
* Ensure the image can execute as a user other than root.
* Provide a docker-compose with common mappings for allowing the user to access the typical configuration and output folders.


## Hardware 

⚠️ These Dockerfiles have been tested on my Linux distribution and hardware only. Contributions to expand compatibility are welcomed!

| Distro Name            | Kernel Version        | CPU                 | GPU                                              | VRAM | DRIVERS                                                                          |
|------------------------|-----------------------|---------------------|--------------------------------------------------|------|----------------------------------------------------------------------------------|
| Ubuntu                 | 22.04.4 LTS           | AMD Ryzen 7 5800X3D | AMD Radeon RX 6900 XT (Navi 21)                  | 16GB |Radeon Software for Linux - version 23.40.2 for Ubuntu 22.04.3 HWE with ROCm 6.0.2|
| Ubuntu                 | 22.04.4 LTS           | Ryzen 5 5600X       | AMD Radeon RX 570X                               | 16GB | |

## Getting Started

### Dependencies
The hardware drivers from AMD must be installed on the host system so that the hardware can be exposed to the container.  I have installed the following specific version.  Please carefully review this before deciding to update your drivers as there may be many other valid reasons you are running different AMD drivers.  Which version you use could significantly impact compatibility with the underlying software:
  
* Radeon Software for Linux - version 23.40.2 for Ubuntu 22.04.3 HWE with ROCm 6.0.2 - Install the software and grant your user account access to the **render** and **video** groups. 
```
sudo apt update 
wget https://repo.radeon.com/amdgpu-install/23.40.2/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb 
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb 
sudo amdgpu-install -y --usecase=graphics,rocm 
sudo usermod -a -G render,video $LOGNAME 
sudo reboot
```

### Retrieve Your User ID And The Render Group ID
After the drivers and software are installed, a **render** group should have been created. Obtain the group id by executing the following
```
cat /etc/group | grep render
```
Make a note of the group id for the render group. For me, it was 110. If it is different for your installation, you will need to adjust that environment variable later for your container.
You will also want to run the container under the same user ID as your current user account. Simply type `id` into a terminal running under your user ID and make note of the UID and GID. If they are not **1000**, then you will need to change the **PUID** and **PGID** environment variables for your containers. That will be done later when you start the container.


## Get the project, tune the image, and Build your Docker images
Retrive the code for this project using git and change into the project directory of your choice where you would like to build this (your Home directory is suggested below), then review the entrypoint.sh file to add any options you may need for your particular setup.
```
cd ~
git clone https://github.com/AirGibson/RocmStableDiffusion
cd ./RocmStableDiffusion/automatic1111
```

Once you are ready, build the docker image.
```
docker build -t airgibson/rocmautomatic1111:1.0 .
```

## Set Up Volume Folders
Create a directory structure for accessing the necessary AUTOMATIC1111 folders such as models, output, etc... so that they can be mounted as volumes. If you use a different pattern for these, please adjust your volume mounts accordingly in your docker-compose or docker run statements. Here are some basic ones I set up for folders inside of SD that I use regularly and want to persist.
```
mkdir -p ~/sd/output
mkdir ~/sd/models
mkdir ~/sd/extensions
mkdir ~/sd/styles
```

For kohya_ss, part of the configuration in their UI is specifying the various input / output directories, so it will be difficult for me to make a recommendation on how to set that up. Set up your own volumes as you see fit.


## Start The Containers
You can start the two containers via the typical "docker run" command, or using docker-compose. The first start-up will take a while as it is pulling AUTOMATIC1111 or kohya_ss and all of the various requirements icluding Pytorch sot that it can be installed using the user specified. After the first time the container is started, it should be much faster unless you remove the container entirely. Note that these are being set up with `--restart always` so that they should start when docker starts. Please adjust these configurations if you don't want them starting / restarting automatically.

If you have environment variable changes you need to make such as PUID, PGID, etc... then this is the time to apply those changes.

### Docker Run
Here are some sample `docker run` commands for starting both containers.
```
docker run --name rocmautomatic1111 --restart always -t -d -p 8090:7860 --cap-add SYS_PTRACE --security-opt seccomp=unconfined --device /dev/kfd --device /dev/dri --group-add video --ipc host --shm-size 8G -v $HOME/sd/models:/workdir/stable-diffusion-webui/models -v $HOME/sd/output:/workdir/stable-diffusion-webui/output -v $HOME/sd/styles:/workdir/stable-diffusion-webui/styles -v $HOME/sd/extensions:/workdir/stable-diffusion-webui/extensions airgibson/rocmautomatic1111:1.0 airgibson/rocmautomatic1111:1.0
 
docker run --name rocmkohyass --restart always -t -d -p 8091:7860 --cap-add SYS_PTRACE --security-opt seccomp=unconfined --device /dev/kfd --device /dev/dri --group-add video --ipc host --shm-size 8G airgibson/rocmkohyass:1.0
```

### Docker-Compose
Here is a sample of a docker-compose file for starting both containers.
```
name: mystack
services:
    rocmautomatic1111:
        container_name: rocmautomatic1111
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
            - video
        ipc: host
        shm_size: 8G
        image: airgibson/rocmautomatic1111:1.0
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

### To Watch The Build
If you wish to connect to the container while it is building things out, use the standard `docker attach` command.  To exit when you are done without disrupting things, use **ctrl-c** to exit the attached terminal. 
```
docker attach rocmkohyass
```

## Launch The GUIs
Once your container(s) are up and running, simply navigate to the mapped local ports.  In the configurations above, AUTOMATIC1111 is mapped to port 8090 and kohya_ss is mapped to port 8091 so that they can be accessible simultaneously if you want. However, you should avoid actively processing jobs with both applications at the same time as both of them are extreme GPU memory hogs.

| Application     | URL                   |
|-----------------|-----------------------|
| AUTOMATIC1111   | http://0.0.0.0:8090   |
| kohya_ss        | http://0.0.0.0:8091   |

### Once Stable, Save A New Image
If you are satisfied with the container that has been built, you can also consider making a snapshot using `docker commit` to create a new image with everything completely installed.

## Evironment Variables
The following environment variables are available and their default values are listed below. The **EXTRA_OPTIONS** variable is particularly important as that is how you can easily pass all of the various options into those applications.

### Variables for AUTOMATIC1111 Container
* ENV EXTRA\_OPTIONS="--upcast-sampling --listen"
* ENV RENDER\_GID=110
* ENV UNAME="newuser"
* ENV PUID=1000
* ENV PGID=1000

### Variables for kohya_ss Container
* ENV PYTORCH_VERSION="nightly/rocm6.0"
* ENV EXTRA\_OPTIONS="--listen=0.0.0.0 --headless"
* ENV HSA\_OVERRIDE\_GFX_VERSION="10.3.0"
* ENV HCC\_AMDGPU\_TARGET="gfx1030"
* ENV RENDER\_GID=110
* ENV UNAME="newuser"
* ENV PUID=1000
* ENV PGID=1000

## Options for AUTOMATIC1111 Issues
TBD

