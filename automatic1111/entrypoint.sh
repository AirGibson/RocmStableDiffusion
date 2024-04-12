#!/bin/bash
set -x

# Create the user this process should be running as, create the render group with the proper matching ID, grant the user rights to the video and render groups, and grant it ownership of the workdir
groupadd -g $PUID $UNAME 
groupadd -g $RENDER_GID render 
useradd -m $UNAME -u $PUID -g $PGID  
usermod -a -G video,render $UNAME
chown $PGID /workdir


# Switch to the new user that was created and perform the installation of all AUTOMATIC1111 requirements and the application itself, then start the service.
exec sudo -u $UNAME env AUTOMATIC1111_COMMIT=$AUTOMATIC1111_COMMIT EXTRA_OPTIONS="$EXTRA_OPTIONS" /bin/bash -c '
set -x
cd /workdir

if [ ! -d "stable-diffusion-webui/venv" ]; then

  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui

  cd /workdir/stable-diffusion-webui 
  git checkout $AUTOMATIC1111_COMMIT
  
  python3 -m venv venv
  source venv/bin/activate
  python -m pip install --upgrade pip wheel
  curl -O -J https://repo.radeon.com/rocm/manylinux/rocm-rel-6.0.2/torch-2.1.2+rocm6.0-cp310-cp310-linux_x86_64.whl
  curl -O -J https://repo.radeon.com/rocm/manylinux/rocm-rel-6.0.2/torchvision-0.16.1+rocm6.0-cp310-cp310-linux_x86_64.whl
  pip3 install --force-reinstall torch-2.1.2+rocm6.0-cp310-cp310-linux_x86_64.whl torchvision-0.16.1+rocm6.0-cp310-cp310-linux_x86_64.whl
  #pip3 install --no-cache-dir $PYTORCH_VERSION
  deactivate
  rm *.whl
fi

cd /workdir/stable-diffusion-webui 
source venv/bin/activate
./webui.sh $EXTRA_OPTIONS
'
