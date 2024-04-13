FROM ubuntu:22.04

VOLUME /workdir

ARG ROCM_VERSION=6.0.2
ARG AMDGPU_VERSION=6.0.2
ARG AUTOMATIC1111_COMMIT="bef51ae"

ENV EXTRA_OPTIONS="--upcast-sampling --listen"
ENV RENDER_GID=110
ENV UNAME="newuser"
ENV PUID=1000
ENV PGID=1000

# Build the base linux system
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl libnuma-dev gnupg \
  && curl -sL https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add - \
  && printf "deb [arch=amd64] https://repo.radeon.com/rocm/apt/$ROCM_VERSION/ ubuntu main" | tee /etc/apt/sources.list.d/rocm.list \
  && printf "deb [arch=amd64] https://repo.radeon.com/amdgpu/$AMDGPU_VERSION/ubuntu jammy main" | tee /etc/apt/sources.list.d/amdgpu.list \
  && printf 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600\n' | tee /etc/apt/preferences.d/rocm-pin-600 \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  sudo \
  libelf1 \
  kmod \
  file \
  python3 \
  python3-pip \
  python3-venv \
  rocm-dev \
  rocm-libs \
  git \
  build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Create the working directory
WORKDIR /workdir
VOLUME /workdir

# Retrieve and prepare the app into a temp directory.  Users may want to set up volumes to the various directories, and GIT CLONE will not work if those directories already exist due to the volume mounts.  
# This will retrieve the project first, then merge it over to the /workdir/stable-diffusion-webui to deal with those volume conflicts.
# We will use checkout to switch to a specific version we'd like to use that we know works with this setup.
RUN mkdir temp \
&& cd temp \
&& git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui \
&& cd ./stable-diffusion-webui \
&& git checkout $AUTOMATIC1111_COMMIT

ENTRYPOINT [ "/entrypoint.sh" ]
