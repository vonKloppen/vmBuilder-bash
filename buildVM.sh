#!/bin/bash

##### ENVIRONMENT CONFIGURATION #####

user=`echo $USER`
date=`date "+%F %R"`

##### GENERIC CONFIGURATION #####

sshKeyPub="packer_key.pub"
sshKeyPrv="packer_key"
editor="vi"

##### FOLDER CONFIGURATION #####

binFOLDER="./bin"
confFOLDER="./conf"
ksFOLDER="./kickstarts"
profFOLDER="./profiles"
scrFOLDER="./scripts"
keyFOLDER="./sshkeys"
vmFOLDER="./vm"
tmpFOLDER="./tmp"

##### DEFAULT VM CONFIGURATION #####

vmHOSTNAME="HOSTNAME"
vmCPU="4"
vmRAM="4"
vmDISK="16"
vmOSTYPE="centos7_64Guest"
vmVLAN="VLAN"
vmNOTES="Build on "$date" by "$user""

vmNETWORK="dhcp"
vmIP="192.168.1.1"
vmNETMASK="255.255.255.0"
vmGATEWAY=""
vmNAMESERVERS="DNS1,DNS2"

vmPurpose="generic"

##### DEFAULT VCENTER CONFIGURATION #####

vcDATACENTER="DATACENTER"
vcCLUSTER="CLUSTER"
vcHOST="HOST"
vcDATASTORE="DATASTORE"
vcFOLDER="FOLDER"

##### DEFAULT KICKSTART CONFIGURATION #####

ksREMOTE="0"
ksREMOTEURL="http://server.dev.null/path/"
ksREMOTEPATH="USER@server.dev.null:KICKSTART_FOLDER"
ksNAME="$vmHOSTNAME.cfg"

prFILENAME="$vmHOSTNAME.json"

echo "VM Builder script"
echo "CopyLeft Mariusz Nowacki"
echo "Please enter machine specific parameters"
echo -e "\n"

read -p "Hostname: " -i "$vmHOSTNAME" -e userInput 
	vmHOSTNAME="$userInput"

if [[ -f "$tmpFOLDER"/"$vmHOSTNAME"  ]]; then
	echo "Configuration for "$vmHOSTNAME" already exists"
	read -p "do you want to continue {y/n}? : " -i "n" -e userInput

	if [[ "$userInput" != "y"  ]]; then
		exit 1
	fi

fi

read -p "CPU: " -i "$vmCPU" -e userInput 
	vmCPU="$userInput"

read -p "RAM: " -i "$vmRAM" -e userInput 
	vmRAM=$(($userInput*1024))

read -p "Disk: " -i "$vmDISK" -e userInput 
	vmDISK=$(($userInput*1024))

read -p "OS type: " -i "$vmOSTYPE" -e userInput 
	vmOSTYPE="$userInput"

read -p "VLAN: " -i "$vmVLAN" -e userInput 
	vmVLAN="$userInput"

read -p "Notes: " -i "$vmNOTES" -e userInput 
	vmNOTES="$userInput"

read -p "Network configuration { dhcp, static }: " -i "dhcp" -e userInput

	if [[ "$userInput" = "static" ]]; then

		vmNETWORK="static"

		read -p "IP: " -i "$vmIP" -e userInput 
		vmIP="$userInput"

		read -p "Netmask: " -i "$vmNETMASK" -e userInput 
		vmNETMASK="$userInput"

		read -p "Gateway: " -i "$vmGATEWAY" -e userInput 
		vmGATEWAY="$userInput"

		read -p "Nameservers: " -i "$vmNAMESERVERS" -e userInput 
		vmNAMESERVERS="$userInput"

	fi

echo -e "\n"
echo "Please VCenter specific parameters"
echo -e "\n"

read -p "Datacenter: " -i "$vcDATACENTER" -e userInput 
	vcDATACENTER="$userInput"

read -p "Cluster: " -i "$vcCLUSTER" -e userInput 
	vcCLUSTER="$userInput"

read -p "Host: " -i "$vcHOST" -e userInput 
	vcHOST="$userInput"

read -p "Datastore: " -i "$vcDATASTORE" -e userInput 
	vcDATASTORE="$userInput"

read -p "Folder: " -i "$vcFOLDER" -e userInput 
	vcFOLDER="$userInput"

read -p "Select machine purpose { generic, mongo, mysql, psql, k8s, web }: " -i "generic" -e userInput
	vmPurpose="$userInput"

read -p "Use (l)ocal or (r)emote kickstart file? : " -i "r" -e userInput

	if [[ "$userInput" = "r" ]]; then

		ksREMOTE=1

		read -p "Remote path: " -i "$ksREMOTEPATH" -e userInput
			ksREMOTEPATH="$userInput"

	fi

if [[ ! -f "$ksFOLDER"/centos-7-"$vmPurpose".cfg ]]; then

	echo "Purpose "$vmPurpose" doesn't exists"
	exit 1
fi

ksNAME="$vmHOSTNAME.cfg"
prFILENAME="$vmHOSTNAME.json"

cp "$ksFOLDER"/centos-7-"$vmPurpose".cfg "$tmpFOLDER"/"$ksNAME"
cp "$confFOLDER"/vmTemplate.json "$tmpFOLDER"/"$vmHOSTNAME"

sed -i "s/__vmHOSTNAME/$vmHOSTNAME/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmCPU/$vmCPU/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmRAM/$vmRAM/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmDISK/$vmDISK/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmOSTYPE/$vmOSTYPE/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmVLAN/$vmVLAN/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmNOTES/$vmNOTES/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcDATACENTER/$vcDATACENTER/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcCLUSTER/$vcCLUSTER/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcHOST/$vcHOST/g" "$tmpFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcDATASTORE/$vcDATASTORE/g" "$tmpFOLDER"/"$vmHOSTNAME"
#sed -i "s/__vcFOLDER/$vcFOLDER/g" "$tmpFOLDER"/"$vmHOSTNAME"

if [[ "$vmNETWORK" = "static" ]]; then

	sed -i "s/__IPADDR/$vmIP/g" "$tmpFOLDER"/"$ksNAME"
	sed -i "s/__NETMASK/$vmNETMASK/g" "$tmpFOLDER"/"$ksNAME"
	sed -i "s/__GATEWAY/$vmGATEWAY/g" "$tmpFOLDER"/"$ksNAME"
	sed -i "s/__NAMESERVERS/$vmNAMESERVERS/g" "$tmpFOLDER"/"$ksNAME"
	sed -i "s/#static\ //g" "$tmpFOLDER"/"$ksNAME"

else

	sed -i "s/#dhcp\ //g" "$tmpFOLDER"/"$ksNAME"
	
fi

sed -i "s/__vmHOSTNAME/$vmHOSTNAME/g" "$tmpFOLDER"/"$ksNAME"

if [[ "$ksREMOTE" = 1  ]]; then

	scp "$tmpFOLDER"/"$ksNAME" "$ksREMOTEPATH"

fi

cp "$profFOLDER"/centos-7.json "$tmpFOLDER"/"$prFILENAME"

sed -i "s/__KICKSTART/$ksNAME/g" "$tmpFOLDER"/"$prFILENAME"

"$binFOLDER"/packer build -var-file="$tmpFOLDER/$vmHOSTNAME" -var-file="$confFOLDER"/vCenter.conf "$tmpFOLDER"/"$prFILENAME"

rm "$tmpFOLDER/$vmHOSTNAME" "$tmpFOLDER"/"$prFILENAME" "$tmpFOLDER"/"$ksNAME"
