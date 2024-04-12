FROM ubuntu:22.04

VOLUME /workdir

ARG ROCM_VERSION=6.0.2
ARG AMDGPU_VERSION=6.0.2

#nightly/rocm6.0, nightly/rocm5.7, nightly/rocm5.6, rocm5.4.2
ENV PYTORCH_VERSION="torch==2.1.2+rocm6.0 torchvision==0.16.1+rocm6.0 --index-url https://download.pytorch.org/whl/nightly/rocm6.0"
ENV AUTOMATIC1111_COMMIT="bef51ae"
ENV EXTRA_OPTIONS="--upcast-sampling --listen"
ENV RENDER_GID=110
ENV UNAME="newuser"
ENV PUID=1000
ENV PGID=1000

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

ENTRYPOINT [ "/entrypoint.sh" ]
