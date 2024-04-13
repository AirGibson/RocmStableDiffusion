#!/bin/bash
set -x

# Create the user this process should be running as, create the render group with the proper matching ID, grant the user rights to the video and render groups, and grant it ownership of the workdir
groupadd -g $PUID $UNAME 
groupadd -g $RENDER_GID render 
useradd -m $UNAME -u $PUID -g $PGID  
usermod -a -G video,render $UNAME
cp -rl /workdir/temp/stable-diffusion-webui/ /workdir/
rm -rdf /workdir/temp
chown $PUID:$PGID -R /workdir

# Switch to the new user that was created and start the service.  First run will take a significant amount of time to retrieve all requirements and initial model.
exec sudo -u $UNAME env EXTRA_OPTIONS="$EXTRA_OPTIONS" /bin/bash -c '
set -x
cd /workdir/stable-diffusion-webui
python3 -m venv venv
python3 -m pip install --upgrade pip wheel
. venv/bin/activate
./webui.sh $EXTRA_OPTIONS
'
