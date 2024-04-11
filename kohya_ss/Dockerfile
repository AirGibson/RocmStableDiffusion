FROM rocm/pytorch:rocm6.0.2_ubuntu22.04_py3.10_pytorch_2.1.2

COPY ./entrypoint.sh /entrypoint.sh

# This dockerfile attemps to change things so that kohya_ss can run with GPU access without running the container as root.

# kohya_ss will need to be able to use the GPU on the host.
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
RUN git clone https://github.com/bmaltais/kohya_ss

#We want version version 23.0.15 of kohya_ss, which is checkout bef51ae
WORKDIR /workdir/kohya_ss 
RUN git checkout c9c4ef1

# The final line of the requirements.txt file needed to be commented to work for me.  ./sd-scripts causes a malfunction if it is left alone.
COPY ./requirements.txt ./requirements.txt

RUN export HSA_OVERRIDE_GFX_VERSION=10.3.0 HCC_AMDGPU_TARGET=gfx1030\
  && python3 -m venv venv \
  && . venv/bin/activate \
  && pip install --use-pep517 --upgrade -r requirements.txt \
  && pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.0 \
  && pip install tensorflow-rocm

ENTRYPOINT [ "/entrypoint.sh" ]
