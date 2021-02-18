#!/bin/env bash

##### FOLDER CONFIGURATION #####

confFOLDER="./conf"
binFOLDER="./bin"
vmFOLDER="./vm"
ksFOLDER="$confFOLDER/kickstarts"
profFOLDER="$confFOLDER/profiles"
scrFOLDER="$confFOLDER/scripts"
keyFOLDER="$confFOLDER/sshkeys"
tmplFOLDER="$confFOLDER/templates"

##### FILE CONFIGURATION #####

defFILE="defaults.conf"
vcFILE="vcenter.conf"
vmTMPLFILE="vm.json"

##### ENVIRONMENT CONFIGURATION #####

user=`echo $USER`
date=`date "+%F %R"`

##### PURPOSE SPECIFIC CONFIGURATION #####

purDISKmongo=2
purDISKmysql=2
purDISKpsql=2
purDISKk8s=2
purDISKkafka=4
purDISKweb=2

##### OTHER #####

vmPURPOSELIST="generic,mongo,mysql,psql,k8s,kafka,web"
vmOSTYPELIST="centos7,centos8"

##### COLORS #####

cINPUT="\e[32m"
cOUTPUT="\e[34m"
cOTHER="\e[33m"
cWARN="\e[31m"


source "$confFOLDER"/"$defFILE"


clear


echo -e "$cOTHER""VM Builder script"
echo -e "CopyLeft LeMarian\n"
echo -e "$cOUTPUT""Please enter machine specific parameters."

read -p "$(echo -e $cOUTPUT"Hostname: "$cINPUT)" -i "$vmHOSTNAME" -e userInput 
	vmHOSTNAME="$userInput"

vmcFOLDER=""$vmFOLDER"/"$vmHOSTNAME""

if [[ -f "$vmcFOLDER"/"$vmHOSTNAME"  ]]; then
	echo -e "\n$cWARN""Configuration for "$vmHOSTNAME" already exists."
	read -p "$(echo -e "Do you want to reuse that configuration {""$cINPUT"y/n"$cWARN""}? : "$cINPUT)" -i "n" -e userInput

	if [[ "$userInput" == "y"  ]]; then
		screen -S "$vmHOSTNAME" -d -m "$binFOLDER"/packer build -var-file="$vmcFOLDER"/"$vmHOSTNAME" -var-file="$confFOLDER"/"$vcFILE" "$vmcFOLDER"/"$vmHOSTNAME.json"

		#"$binFOLDER"/packer build -var-file="$vmcFOLDER"/"$vmHOSTNAME" -var-file="$confFOLDER"/"$vcFILE" "$vmcFOLDER"/"$vmHOSTNAME.json"

		echo -e "\n"$cOUTPUT"Packer started in screen."
		echo -e "Enter"$cINPUT" \"screen -r "$vmHOSTNAME"\" "$cOUTPUT"to attach to it."
		exit 0
	fi
fi

echo -e "\n"


read -p "$(echo -e $cOUTPUT"OS type {""$cINPUT""$vmOSTYPELIST""$cOUTPUT""}: "$cINPUT)" -i "$vmOSTYPE" -e userInput 
	vmOSTYPE="$userInput"

read -p "$(echo -e $cOUTPUT"Select machine purpose {""$cINPUT""$vmPURPOSELIST""$cOUTPUT""}: "$cINPUT)" -i "generic" -e userInput
	vmPurpose="$userInput"

if [[ ! -f "$ksFOLDER"/"$vmOSTYPE"-"$vmPurpose".cfg ]]; then

	echo -e "$cWARN Kickstart for $cINPUT "$vmPurpose" $cWARN doesn't exists"
	exit 1
fi

if [[ ! -f "$profFOLDER"/"$vmOSTYPE"-"$vmPurpose".json ]]; then

	echo -e "$cWARN Profile for $cINPUT "$vmPurpose" $cWARN doesn't exists"
	exit 1
fi

case "$vmPurpose" in

	"mongo") vmDISK=$(( $vmDISK + $purDISKmongo )) ;;
	"mysql") vmDISK=$(( $vmDISK + $purDISKmysql )) ;;
	"psql")  vmDISK=$(( $vmDISK + $purDISKpsql )) ;;
	"k8s")   vmDISK=$(( $vmDISK + $purDISKk8s )) ;;
	"kafka") vmDISK=$(( $vmDISK + $purDISKkafka )) ;;
	"web")   vmDISK=$(( $vmDISK + $purDISKweb )) ;;

esac

echo -e "\n"

read -p "$(echo -e $cOUTPUT"CPU (Cores): "$cINPUT)" -i "$vmCPU" -e userInput 
	vmCPU="$userInput"

read -p "$(echo -e $cOUTPUT"RAM (GB): "$cINPUT)" -i "$vmRAM" -e userInput 
	vmRAM=$(($userInput*1024))

read -p "$(echo -e $cOUTPUT"Disk (GB): "$cINPUT)" -i "$vmDISK" -e userInput 
	vmDISK=$(($userInput*1024))

read -p "$(echo -e $cOUTPUT"VLAN: "$cINPUT)" -i "$vmVLAN" -e userInput 
	vmVLAN="$userInput"

read -p "$(echo -e $cOUTPUT"Notes: "$cINPUT)" -i "$vmNOTES" -e userInput 
	vmNOTES="$userInput"

read -p "$(echo -e $cOUTPUT"Network configuration (""$cINPUT"d"$cOUTPUT"")hcp,(""$cINPUT"s"$cOUTPUT"")tatic: "$cINPUT)" -i "d" -e userInput

	if [[ "$userInput" = "s" ]]; then

		vmNETWORK="static"

		read -p "$(echo -e $cOUTPUT"IP: "$cINPUT)" -i "$vmIP" -e userInput 
		vmIP="$userInput"

		read -p "$(echo -e $cOUTPUT"Netmask: "$cINPUT)" -i "$vmNETMASK" -e userInput 
		vmNETMASK="$userInput"

		read -p "$(echo -e $cOUTPUT"Gateway: "$cINPUT)" -i "$vmGATEWAY" -e userInput 
		vmGATEWAY="$userInput"

		read -p "$(echo -e $cOUTPUT"Nameservers: "$cINPUT)" -i "$vmNAMESERVERS" -e userInput 
		vmNAMESERVERS="$userInput"

	fi

echo -e "\n$cOUTPUT""Please enter VCenter specific parameters\n"

read -p "$(echo -e $cOUTPUT"Datacenter: "$cINPUT)" -i "$vcDATACENTER" -e userInput 
	vcDATACENTER="$userInput"

read -p "$(echo -e $cOUTPUT"Cluster: "$cINPUT)" -i "$vcCLUSTER" -e userInput 
	vcCLUSTER="$userInput"

read -p "$(echo -e $cOUTPUT"Host: "$cINPUT)" -i "$vcHOST" -e userInput 
	vcHOST="$userInput"

read -p "$(echo -e $cOUTPUT"Datastore: "$cINPUT)" -i "$vcDATASTORE" -e userInput 
	vcDATASTORE="$userInput"

read -p "$(echo -e $cOUTPUT"Folder: "$cINPUT)" -i "$vcFOLDER" -e userInput 
	vcFOLDER="$userInput"

echo -e "\n"
read -p "$(echo -e $cOUTPUT"Use (""$cINPUT"l"$cOUTPUT"")ocal or (""$cINPUT"r"$cOUTPUT"")emote kickstart file?: "$cINPUT)" -i "r" -e userInput

	if [[ "$userInput" = "r" ]]; then

		ksREMOTE=1

		read -p "$(echo -e $cOUTPUT"Remote user: "$cINPUT)" -i "$ksREMOTEUSER" -e userInput
			ksREMOTEUSER="$userInput"

		read -p "$(echo -e $cOUTPUT"Remote server: "$cINPUT)" -i "$ksREMOTESERVER" -e userInput
			ksREMOTESERVER="$userInput"

		read -p "$(echo -e $cOUTPUT"Remote path: "$cINPUT)" -i "$ksREMOTEPATH" -e userInput
			ksREMOTEPATH="$userInput"

	fi


ksNAME="$vmHOSTNAME.cfg"
vmHOSTNAME="$vmHOSTNAME"
vcFOLDER=`echo "$vcFOLDER" | sed 's:\/:\\\/:g'`
vmNOTES=`echo "$vmNOTES" |sed 's:\/:\\\/:g'`

mkdir -p "$vmcFOLDER"

cp "$ksFOLDER"/"$vmOSTYPE"-"$vmPurpose".cfg "$vmcFOLDER"/"$ksNAME"
cp "$tmplFOLDER"/"$vmTMPLFILE" "$vmcFOLDER"/"$vmHOSTNAME"

sed -i "s/__vmHOSTNAME/$vmHOSTNAME/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmCPU/$vmCPU/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmRAM/$vmRAM/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmDISK/$vmDISK/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmVLAN/$vmVLAN/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vmNOTES/$vmNOTES/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcDATACENTER/$vcDATACENTER/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcCLUSTER/$vcCLUSTER/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcHOST/$vcHOST/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcDATASTORE/$vcDATASTORE/g" "$vmcFOLDER"/"$vmHOSTNAME"
sed -i "s/__vcFOLDER/$vcFOLDER/g" "$vmcFOLDER"/"$vmHOSTNAME"

case "$vmOSTYPE" in

	"centos7") sed -i "s/__vmOSTYPE/centos7_64Guest/g" "$vmcFOLDER"/"$vmHOSTNAME";;
	"centos8") sed -i "s/__vmOSTYPE/centos8_64Guest/g" "$vmcFOLDER"/"$vmHOSTNAME";;

esac



if [[ "$vmNETWORK" = "static" ]]; then

	sed -i "s/__IPADDR/$vmIP/g" "$vmcFOLDER"/"$ksNAME"
	sed -i "s/__NETMASK/$vmNETMASK/g" "$vmcFOLDER"/"$ksNAME"
	sed -i "s/__GATEWAY/$vmGATEWAY/g" "$vmcFOLDER"/"$ksNAME"
	sed -i "s/__NAMESERVERS/$vmNAMESERVERS/g" "$vmcFOLDER"/"$ksNAME"
	sed -i "s/__HOSTNAME/$vmHOSTNAME/g" "$vmcFOLDER"/"$ksNAME"
	sed -i "s/#static\ //g" "$vmcFOLDER"/"$ksNAME"

else

	sed -i "s/#dhcp\ //g" "$vmcFOLDER"/"$ksNAME"
	
fi

packerKey=`cat "$keyFOLDER"/"$sshKeyPub" | sed 's:\/:\\\/:g'`

export rootPass=`pwgen -s -1 16`

rootPassEnc=`python -c 'import crypt,os; print(crypt.crypt(os.environ["rootPass"]))' | sed 's:\/:\\\/:g'`

sed -i "s/__HOSTNAME/$vmHOSTNAME/g" "$vmcFOLDER"/"$ksNAME"
sed -i "s/__packerKey/$packerKey/g" "$vmcFOLDER"/"$ksNAME"
sed -i "s/__rootPass/$rootPassEnc/g" "$vmcFOLDER"/"$ksNAME"

if [[ "$ksREMOTE" = 1  ]]; then

	echo -e "$cWARN"
	scp "$vmcFOLDER"/"$ksNAME" "$ksREMOTEUSER"@"$ksREMOTESERVER":"$ksREMOTEPATH"

fi

cp "$profFOLDER"/"$vmOSTYPE"-"$vmPurpose".json "$vmcFOLDER"/"$vmHOSTNAME".json

sed -i "s/__KICKSTART/$ksNAME/g" "$vmcFOLDER"/"$vmHOSTNAME".json

screen -dmS "$vmHOSTNAME" "$binFOLDER"/packer build -var-file="$confFOLDER"/vcenter.conf -var-file="$vmcFOLDER"/"$vmHOSTNAME" "$vmcFOLDER"/"$vmHOSTNAME".json 

#"$binFOLDER"/packer build -var-file="$confFOLDER"/vcenter.conf -var-file="$vmcFOLDER"/"$vmHOSTNAME" "$vmcFOLDER"/"$vmHOSTNAME".json

echo -e "\n"$cOTHER"Packer started"
echo -e "\n"$cOUTPUT"Enter"$cINPUT" \"screen -r "$vmHOSTNAME"\" "$cOUTPUT"to attach to it."
echo -e "\nroot password: ""$cWARN""$rootPass""\n"

