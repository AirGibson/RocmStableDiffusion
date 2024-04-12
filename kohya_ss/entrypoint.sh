#!/bin/bash
set -x

# Create the user this process should be running as, create the render group with the proper matching ID, grant the user rights to the video and render groups, and grant it ownership of the workdir
groupadd -g $PUID $UNAME 
groupadd -g $RENDER_GID render 
useradd -m $UNAME -u $PUID -g $PGID  
usermod -a -G video,render $UNAME
chown $PGID /workdir


# Switch to the new user that was created and perform the installation of all kohya_ss requirements and the application itself, then start the service.
exec sudo -u $UNAME env KOHYA_SS_COMMIT=$KOHYA_SS_COMMIT HSA_OVERRIDE_GFX_VERSION="$HSA_OVERRIDE_GFX_VERSION" PYTORCH_VERSION="$PYTORCH_VERSION" HCC_AMDGPU_TARGET=$HCC_AMDGPU_TARGET EXTRA_OPTIONS="$EXTRA_OPTIONS" /bin/bash -c '
set -x
cd /workdir

if [ ! -d "kohya_ss" ]; then

  git clone https://github.com/bmaltais/kohya_ss

  cd /workdir/kohya_ss 
  git checkout $KOHYA_SS_COMMIT
  
  python3 -m venv venv
  source venv/bin/activate
  pip3 install --no-cache-dir --use-pep517 --upgrade -r /requirements.txt
  pip3 install --no-cache-dir --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$PYTORCH_VERSION
  pip3 install --no-cache-dir tensorflow-rocm
  deactivate

fi

cd /workdir/kohya_ss 
source venv/bin/activate
python kohya_gui.py $EXTRA_OPTIONS
'
