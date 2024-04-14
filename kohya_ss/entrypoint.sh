#!/bin/bash
set -x

# Create the user this process should be running as, create the render group with the proper matching ID, and grant the user rights to the video and render groups.
groupadd -g $PUID $UNAME 
groupadd -g $RENDER_GID render 
useradd -m $UNAME -u $PUID -g $PGID  
usermod -a -G video,render $UNAME

# Copy the application over to its permanent location, merging it with existing folders that may have been created from the volume mounts.  Then, delete the 
# old temp files and change ownership of everything in /workdir to the PUID / GUID provided.
cp -rl /workdir/temp/kohya_ss/ /workdir/
rm -rdf /workdir/temp
chown $PUID:$PGID -R /workdir

# Switch to the new user that was created and perform the installation of all kohya_ss requirements and the application itself, then start the service.
exec sudo -u $UNAME env HSA_OVERRIDE_GFX_VERSION="$HSA_OVERRIDE_GFX_VERSION" HCC_AMDGPU_TARGET=$HCC_AMDGPU_TARGET EXTRA_OPTIONS="$EXTRA_OPTIONS" /bin/bash -c '
set -x
cd /workdir/kohya_ss

if [ ! -d "venv" ]; then
    
  python3 -m venv venv
  source venv/bin/activate 
  pip3 install --no-cache-dir --use-pep517 --upgrade -r /requirements.txt
  pip3 install --no-cache-dir --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$PYTORCH_VERSION
  pip3 install --no-cache-dir tensorflow-rocm
  deactivate
  rm -f ./*.whl
fi

cd /workdir/kohya_ss 
source venv/bin/activate
python kohya_gui.py $EXTRA_OPTIONS
'
