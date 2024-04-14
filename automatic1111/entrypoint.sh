#!/bin/bash
set -x

# Create the user this process should be running as, create the render group with the proper matching ID, and grant the user rights to the video and render groups.
groupadd -g $PUID $UNAME 
groupadd -g $RENDER_GID render 
useradd -m $UNAME -u $PUID -g $PGID  
usermod -a -G video,render $UNAME

# Copy the application over to its permanent location, merging it with existing folders that may have been created from the volume mounts.  Then, delete the 
# old temp files and change ownership of everything in /workdir to the PUID / GUID provided.
cp -rl /workdir/temp/stable-diffusion-webui/ /workdir/
rm -rdf /workdir/temp
chown $PUID:$PGID -R /workdir

# Switch to the new user that was created and start the service.  First run will take a significant amount of time to retrieve all requirements and initial model.
# Note that this application installs its own requirements, inlcuding Pytorch 5.4.2.  If you want to use a different version of pytorch, it will require modifications
# of the AUTOMATIC1111 shell scripts.
exec sudo -u $UNAME env EXTRA_OPTIONS="$EXTRA_OPTIONS" /bin/bash -c '
set -x
cd /workdir/stable-diffusion-webui
python3 -m venv venv
python3 -m pip install --upgrade pip wheel
. venv/bin/activate
./webui.sh $EXTRA_OPTIONS
'
