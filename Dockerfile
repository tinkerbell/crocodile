FROM ubuntu:latest
RUN apt-get update; apt-get upgrade -y; DEBIAN_FRONTEND=noninteractive apt-get install -y ansible git qemu-kvm unzip xorriso curl jq

# Get virtio drivers (ensures a drive is usable for qemu
RUN curl -L -o /var/tmp/virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso; xorriso -report_about WARNING -osirrox on -indev /var/tmp/virtio-win.iso -extract / /var/tmp/virtio-win
ENV VIRTIO_WIN_ISO_DIR="/var/tmp/virtio-win"

# Get LATEST release of packer 
RUN export PACKER_LATEST_VERSION="$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r -M '.current_version')"; curl -L -o /tmp/packer_linux_amd64.zip "https://releases.hashicorp.com/packer/${PACKER_LATEST_VERSION}/packer_${PACKER_LATEST_VERSION}_linux_amd64.zip" ; unzip /tmp/packer_linux_amd64.zip -d /usr/local/bin/ ; rm /tmp/packer_linux_amd64.zip

# Install the tinkerbell packer builds
COPY . /packer/
WORKDIR /packer

# Set additional environment variables to make usage easier
ENV PACKER_IMAGES_OUTPUT_DIR="/var/tmp/images"

# Set a default entrypoint
ENTRYPOINT [ "./crocodile.sh" ]
