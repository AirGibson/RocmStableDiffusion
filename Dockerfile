FROM rocm/pytorch:rocm6.0.2_ubuntu22.04_py3.10_pytorch_2.1.2

COPY ./entrypoint.sh /entrypoint.sh

# The rocm/pytorch image has a group named _ssh that is using GID 110.  That is the same GID
# as the "render" group on my host system.  The AMD ROCm drivers now install a "render" group
# which controls access to the GPU.  Whatever user will be running Stable Diffusion will need
# to be assigned to that group.
RUN chmod +x /entrypoint.sh \
  && usermod -a -G "_ssh" jenkins 
   
USER jenkins

WORKDIR /workdir
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

  
WORKDIR /workdir/stable-diffusion-webui 
RUN git checkout bef51ae #We want version 1.8.0 \
  && python3 -m venv venv \
  && . venv/bin/activate \
  && python -m pip install --upgrade pip wheel \
  && pip3 install torch==2.0.1+rocm5.4.2 torchvision==0.15.2+rocm5.4.2 --index-url https://download.pytorch.org/whl/rocm5.4.2

#VOLUME /workdir

ENTRYPOINT [ "/entrypoint.sh" ]
