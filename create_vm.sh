#!/bin/sh

function determine_network_device
{
	OIFS=$IFS
	IFS=$'\n'
	for device in $(networksetup -listnetworkserviceorder | grep 'Hardware Port' | sed -E 's/^.*Device: ([a-zA-Z0-9]+).*$/\1/')
	do
		if ifconfig $device 2>/dev/null | grep 'status: active' > /dev/null 2>&1
		then
			echo $device
			IFS=$OIFS
			return 0
		fi
	done
	IFS=$OIFS
	return 1
}

vm_dir="$HOME/VirtualBox VMs"
tpl_vdi=`ls -r "$vm_dir/CoreOS Template"/coreos_production_*.vdi | head -n 1`

[[ $# -lt 1 ]] && echo "ERROR: VM name is mandatory!" && exit 1

new_vm="$1"
ram=${2-1024}
hdd_size=${3-10240}
device=`determine_network_device`
[[ $? -ne 0 ]] && echo "ERROR: default network device could not be determined!" && exit 1

VBoxManage createvm --name "$new_vm" --ostype "Linux26_64" --register || exit 1

new_vdi="$vm_dir/$new_vm/$new_vm-`basename "$tpl_vdi"`"
VBoxManage clonehd "$tpl_vdi" "$new_vdi" || exit 1
VBoxManage modifyhd "$new_vdi" --resize "$hdd_size"
VBoxManage storagectl "$new_vm" --name "SATA Controller" --add sata --portcount 2 --controller IntelAHCI || exit 1
VBoxManage storageattach "$new_vm" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$new_vdi" || exit 1

VBoxManage storagectl "$new_vm" --name "IDE Controller" --add ide || exit 1
#TODO  attach config-drive.iso
#VBoxManage storageattach "$new_vm" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium /path/to/config-drive.iso

VBoxManage modifyvm "$new_vm" --ioapic on --rtcuseutc on --audio none || exit 1
VBoxManage modifyvm "$new_vm" --boot1 disk --boot2 none --boot3 none --boot4 none || exit 1
VBoxManage modifyvm "$new_vm" --memory "$ram" --vram 128 || exit 1
VBoxManage modifyvm "$new_vm" --nic1 bridged --bridgeadapter1 "$device" || exit 1
