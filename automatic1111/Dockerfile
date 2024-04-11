FROM rocm/pytorch:rocm6.0.2_ubuntu22.04_py3.10_pytorch_2.1.2

COPY ./entrypoint.sh /entrypoint.sh

# This dockerfile attemps to change things up so that Stable Diffusion can run with GPU access without running the container as root.

# Stable diffusion will need to be able to use the GPU on the host.
# On my host system, the AMD driver installation created a group named "render" with the ID of 110 to control access to the GPU.
# Whatever user is executing in the container must have rights to the render group (110 for me) to be able to call the GPU on the host.
# Inside the pytorch image, it turns out they are already using group 110 for a group named "_ssh".

# The user named 'jenkins' in the pytorch image has the uid:gid of 1000:1000.
# My ID on my host is 1000 and I want the container to be able to access my various image folders, so I will be running the container as that jenkins user.


ARG UNAME=jenkins
ARG UID=1000
ARG GID=1000
ARG RENDERGID=110

RUN id -g $GID &>/dev/null || groupadd -g $GID -o $UNAME \
  && id -g $UID &>/dev/null || useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME \
  && usermod -a -G $RENDERGID $UNAME \
  && chmod +x /entrypoint.sh 
   
USER $UNAME

WORKDIR /workdir
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

#We want version 1.8.0 of the webui, which is checkout bef51ae
#We will use a virtual environment since we may be installing kohya_ss which could need conflicting packages.

WORKDIR /workdir/stable-diffusion-webui 
RUN git checkout bef51ae \
  && python3 -m venv venv \
  && . venv/bin/activate \
  && python -m pip install --upgrade pip wheel \
  && pip3 install torch==2.0.1+rocm5.4.2 torchvision==0.15.2+rocm5.4.2 --index-url https://download.pytorch.org/whl/rocm5.4.2

#VOLUME /workdir

ENTRYPOINT [ "/entrypoint.sh" ]
