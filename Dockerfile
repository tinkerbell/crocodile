FROM ubuntu:hirsute-20210723

# Disable DL3008 as it is not possible to pin virtual packages such as qemu-kvm
# hadolint ignore=DL3008
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
   ansible=2.10.7-1 \
   git=1:2.30.2-1ubuntu1 \
   qemu-kvm \
   qemu-utils \
   unzip=6.0-26ubuntu1 \
   xorriso=1.5.2-1 \
   curl \
   jq=1.6-2.1ubuntu1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Get virtio drivers (ensures a drive is usable for qemu
RUN curl -L -o /var/tmp/virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso \
  && xorriso -report_about WARNING -osirrox on -indev /var/tmp/virtio-win.iso -extract / /var/tmp/virtio-win \
  && rm /var/tmp/virtio-win.iso

ENV VIRTIO_WIN_ISO_DIR="/var/tmp/virtio-win"

# Get LATEST release of packer 
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN PLV="$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r -M '.current_version')" \
  && curl -L -o /tmp/packer_linux_amd64.zip "https://releases.hashicorp.com/packer/${PLV}/packer_${PLV}_linux_amd64.zip" \
  && unzip /tmp/packer_linux_amd64.zip -d /usr/local/bin/ \
  && rm /tmp/packer_linux_amd64.zip

# Install the tinkerbell packer builds
COPY . /packer/
WORKDIR /packer

# Set additional environment variables to make usage easier
ENV PACKER_IMAGES_OUTPUT_DIR="/var/tmp/images"

# Set a default entrypoint
ENTRYPOINT [ "./crocodile.sh" ]
