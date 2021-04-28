# Crocodile

The **Crocodile** repository contains everything that a user should need in order to build compressed raw images
of Windows{x}, VMware ESXi, and various Linux distros
for [tinkerbell](https://tinkerbell.org). The repository contains a number of key pieces:

## Dockerfile

The `Dockerfile` contains everything that is needed to build a docker container with **everything** that is needed to build
the Operating System images:

- Packer
- Qemu-kvm
- virtio drivers (needed for Qemu to work with disks)

## Host requirements

### Minimal
For most OS image builds, all you should really need is Docker on a reasonably modern Linux distro with KVM virtualization support.

### ESXi special requirements
To build ESXi images we depend on special bridged networking provided by libvirt-daemon.
To confirm expected bridged networking, `ip link show virbr0` should succeed.
You will also need to add `--device=/dev/net/tun --cap-add=NET_ADMIN" to your docker commands.

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
Select quit (1)  when you've finished building Operating Systems
1) quit		   4) esxi6.5	     7) ubuntu-2004   10) windows-2016
2) alma		   5) esxi6.7	     8) windows-10    11) windows-2019
3) arch		   6) esxi7.0	     9) windows-2012
```

## Troubleshooting

In the event that a build is failing then we can debug the issue by adding `-e PACKER_LOG=1` to the `docker run`
command.
