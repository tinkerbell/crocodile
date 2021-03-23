# Crocodile

The **Crocodile** repository contains everything that a user should need in order to build Windows{x} compressed raw images
for [tinkerbell](https://tinkerbell.org). The repository contains a number of key peices:

## Dockerfile

The `Dockerfile` contains everything that is needed to build a docker container with **everything** that is needed to build
the Operating System images:

- Packer
- Qemu-kvm
- virtio drivers (needed for Qemu to work with disks)

### Building our container image

```
docker build -t croc .
```

This will take a few mins (depending on the speed of the connection to the internet), and you'll be left with a docker image
called `croc:latest`

## Running our `croc` container

Our newly built croc container can work in two ways, either interactive or can be fully automated.

We will map two directories into our running container:

`-v $PWD/packer_cache:/packer/packer_cache` - Maps the `packer_cache` to a local `packer_cache` folder, this stops ISOs repeatedly downloading.

`-v $PWD/images:/var/tmp/images` - Maps a local `images` folder to where the images will be created.

### Interactive

Without passing anything specific to the container it will default to starting the interactive image building process.
```
docker run -it --rm \
-v $PWD/packer_cache:/packer/packer_cache \
-v $PWD/images:/var/tmp/images \
--net=host \
--device=/dev/kvm \
croc:latest
```
This will drop you into the crocodile shell for building your OS:

```
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
Select "quit"  when you've finished building Operating Systems
1) windows-2012
2) windows-2016
3) windows-2019
4) windows-10
5) quit
```

### Automated

In the automated approach we can pass all of the required information to the croc container
to completely build our Operating System image with no user involvement.

```
docker run -it -v $PWD/cache:/packer/packer_cache \
-e NAME=tink \
-e WINDOWS_VERSION=2016 \
-e ISO_URL=https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO \
-v $PWD/images:/var/tmp/images \
--net=host --device=/dev/kvm \
croc:latest packer build -only="qemu" windows.json
```

## Troubleshooting

In the event that a build is failing then we can debug the issue by adding `-e PACKER_LOG=1` to the `docker run`
command.
