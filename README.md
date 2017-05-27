# Introduction
There is a great [tutorial](https://coreos.com/os/docs/latest/booting-on-virtualbox.html) how to create a CoreOS VM on Oracle VirtualBox.
However, on Mac OS things are different as always.
Therefore I created a Docker image which performs the steps described in the above tutorial, which can be executed on Mac OS.

# Prerequisites
- Installed Docker
- Installed Oracle VirtualBox

# Steps to perform
Perform following commands to create the base VM template:
```
mkdir build-create-coreos && cd build-create-coreos
curl -o docker-compose.yml https://github.com/Cube-Earth/docker-images/build-create-coreos/docker-compose.yml
docker-compose pull
docker-compose run --rm build-create-coreos

f=`ls -r "$HOME/VirtualBox VMs/CoreOS Template"/coreos_production_*.bin | head -n 1`
VBoxManage convertdd "$f" "${f%%.bin}.vdi" --format VDI

rm "$f"
```

For each needed CoreOS instance perform following steps:
```
curl -o create_vm.sh https://github.com/Cube-Earth/docker-images/build-create-coreos/create_vm.sh
chmod +x create_vm.sh
./create_vm CoreOS-Dev 2048 10240
```
Where 'CoreOS-Dev' is the name of your new VM with 2048 MB RAM and 10240 MB HDD size.

# References
- https://coreos.com/os/docs/latest/booting-on-virtualbox.html
