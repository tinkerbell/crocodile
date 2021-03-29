#!/bin/bash

# ISO URLS (updated as of 23/03/2021 - @thebsdbox)

## Windows URLS
WIN2012ISO="http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO"

WIN2016ISO="https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

WIN2019ISO="https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"

WIN20ISO="https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

## ESXi URLS
ESXI67ISO="http://200.131.248.12/ISO/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso"
ESXI70ISO="http://arv.asuhu.com/ESXi/VMware-VMvisor-Installer-7.0b-16324942.x86_64.iso"
ESXI65ISO="http://visionnet.com.hk/vmware/VMware-VMvisor-Installer-6.5.0.update02-8294253.x86_64.iso"

NIXOS2009ISO="https://channels.nixos.org/nixos-20.09/latest-nixos-minimal-x86_64-linux.iso"

CONFIG=./configs/windows.json
tput setaf 2
if [[ $1 == "fast" ]] ; then
  CONFIG=./configs/windows-fast.json
  tput setaf 1
fi

cat << "CROC"
                          .--.  .--.
                         /    \/    \
                        | .-.  .-.   \
                        |/_  |/_  |   \
                        || `\|| `\|    `----.
                        |\0_/ \0_/    --,    \_
      .--"""""-.       /              (` \     `-.
     /          \-----'-.              \          \
     \  () ()                         /`\          \
     |                         .___.-'   |          \
     \                        /` \|      /           ;
      `-.___             ___.' .-.`.---.|             \
         \| ``-..___,.-'`\| / /   /     |              `\
          `      \|      ,`/ /   /   ,  /
                  `      |\ /   /    |\/
                   ,   .'`-;   '     \/
              ,    |\-'  .'   ,   .-'`
            .-|\--;`` .-'     |\.'
           ( `"'-.|\ (___,.--'`'
            `-.    `"`          _.--'
               `.          _.-'`-.
                 `''---''``       `."
CROC
tput sgr0
echo "Select quit (1)  when you've finished building Operating Systems"
PS3="Enter a number: "
set -o posix

select OS in quit $(ls http)

do
  case $OS in
    windows-2012)
      export ISO_URL=$WIN2012ISO
      export NAME=tink-$OS
      export VERSION=$OS
      packer build -only="qemu" $CONFIG
      ;;
    windows-2016)
      export ISO_URL=$WIN2016ISO
      export NAME=tink-$OS
      export VERSION=$OS
      packer build -only="qemu" $CONFIG
      ;;
    windows-2019)
      export ISO_URL=$WIN2019ISO
      export NAME=tink-$OS
      export VERSION=$OS
      packer build -only="qemu" $CONFIG
      ;;
    windows-10)
      export ISO_URL=$WIN10ISO
      export NAME=tink-$OS
      export VERSION=$OS
      packer build -only="qemu" $CONFIG
      ;;
    esxi6.5)
      chmod u+s /usr/lib/qemu/qemu-bridge-helper
      mkdir -p /etc/qemu && echo "allow virbr0" >>/etc/qemu/bridge.conf	
      export CONFIG=./configs/esxi.json
      export ISO_URL=$ESXI65ISO
      export NAME=tink-$OS
      export VERSION=$OS
      export DISK_SIZE=2048
      packer build -only="qemu" $CONFIG
      ;;
    esxi6.7)
      chmod u+s /usr/lib/qemu/qemu-bridge-helper
      mkdir -p /etc/qemu && echo "allow virbr0" >>/etc/qemu/bridge.conf
      export CONFIG=./configs/esxi.json
      export ISO_URL=$ESXI67ISO
      export NAME=tink-$OS
      export VERSION=$OS
      packer build -only="qemu" $CONFIG
      ;;
    esxi7.0)
      chmod u+s /usr/lib/qemu/qemu-bridge-helper
      mkdir -p /etc/qemu && echo "allow virbr0" >>/etc/qemu/bridge.conf
      export CONFIG=./configs/esxi.json
      export ISO_URL=$ESXI70ISO
      export NAME=tink-$OS
      export VERSION=$OS
      export DISK_SIZE=4096
      packer build -only="qemu" $CONFIG
      ;;
    nixos-20-09)
      export CONFIG=./configs/nixos-20-09.json
      export ISO_URL=$NIXOS2009ISO
      export NAME=tink-$WINDOWS_VERSION
      export WINDOWS_VERSION=$WINDOWS_VERSION
      packer build -only="qemu" $CONFIG
      ;;
    quit)
      break
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
  esac
done
set +o posix

