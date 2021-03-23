#!/bin/bash

# ISO URLS (updated as of 23/03/2021 - @thebsdbox)
WIN2012ISO="http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO"

WIN2016ISO="https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

WIN2019ISO="https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"

WIN20ISO="https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

tput setaf 2
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
echo "Select \"quit\"  when you've finished building Operating Systems"
PS3="Enter a number: "

select WINDOWS_VERSION in windows-2012 windows-2016 windows-2019 windows-10 quit
do
  case $WINDOWS_VERSION in
    windows-2012)
      export ISO_URL=$WIN2012ISO
      export NAME=tink-$WINDOWS_VERSION
      export WINDOWS_VERSION=$WINDOWS_VERSION
      packer build -only="qemu" windows.json  
      ;;
    windows-2016)
      export ISO_URL=$WIN2016ISO
      export NAME=tink-$WINDOWS_VERSION
      export WINDOWS_VERSION=$WINDOWS_VERSION
      packer build -only="qemu" windows.json    
      ;;
    windows-2019)
      export ISO_URL=$WIN2019ISO
      export NAME=tink-$WINDOWS_VERSION
      export WINDOWS_VERSION=$WINDOWS_VERSION
      packer build -only="qemu" windows.json
      ;;
    windows-10)
      export ISO_URL=$WIN10ISO
      export NAME=tink-$WINDOWS_VERSION
      export WINDOWS_VERSION=$WINDOWS_VERSION
      packer build -only="qemu" windows.json
      ;;
    quit)
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
  esac
done
