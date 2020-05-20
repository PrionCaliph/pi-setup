#!/bin/bash

CYAN='\033[1;36m'
CLEAR='\033[0m'
RED='\033[1;31m'
YELLOW='\033[1;33m'

#expand fileysys
expFS () {
	sudo raspi-config --expand-rootfs
        echo "${CYAN}Filesys expanded${CLEAR}"
	
}
#Set hostname
changeHN () {
	HOSTNAME="biblio" 
	sudo raspi-config nonint do_hostname $HOSTNAME
	echo "${CYAN}Hostname changed to $HOSTNAME${CLEAR}"
 }
#autologin to console
autologin () {
	sudo raspi-config nonint do_boot_behaviour B2
	echo "${CYAN}Autologin to console enabled${CLEAR}"
}
#set gpu mem
gpu () {
	MEM=16
    sudo raspi-config nonint do_memory_split 16
	echo "${CYAN}GPU memory set to $MEM MB${CLEAR}"
 }

#change passwd
pass () {
	newpass="74757475"
	echo "pi:$newpass" | sudo chpasswd
    echo "${CYAN}Password changed${CLEAR}"
}

#change locale
#change timezone
timezone () {
    TIMEZONE="America/New_York"
    sudo timedatectl set-timezone $TIMEZONE > /dev/null
    echo "${CYAN}Timezone chnaged to $TIMEZONE${CLEAR}"
}

#install uwt and usability-misc
whonixRep () {
    HOMEPATH=/home/$(echo ${SUDO_USER:-${USER}})
    cd $HOMEPATH
    echo "${CYAN}Setting up Whonix repos...${CLEAR}"
    wget https://www.whonix.org/patrick.asc
    sudo chown ${SUDO_USER:-${USER}}):$(echo ${SUDO_USER:-${USER}}
    sudo apt-key --keyring /etc/apt/trusted.gpg.d/whonix.gpg add ~/patrick.asc
    echo "deb https://deb.whonix.org buster main contrib non-free" | sudo tee /etc/apt/sources.list.d/whonix.list
    sudo apt update -qq
    echo "${CYAN}Whonix repos set up${CLEAR}"
}

installPack () {
    
    sudo apt install -y --install-recommends $prog
    
}
installingPack () {
    echo "${CYAN}Installing $prog ...${CLEAR}"
}
verifyIns () {
    var=""
    good="Status: install ok installed"
    var=$(dpkg -s $prog |grep Status)
    if [ "$var" = "$good" ]; then echo "${CYAN}$prog installed:${CLEAR}" && echo "\t$var"
    else echo "${RED}$prog did NOT install:${CLEAR}" && echo "\t$var"
    fi
    
}
upd_upg () {
    echo "${CYAN}Updating and upgrading${CLEAR}"
    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y
    echo "${CYAN}Done updating and upgrading${CLEAR}"
}
enterReboot () {
    echo "${YELLOW}Press enter to reboot${CLEAR}"
    if read response; then
    sudo reboot
    fi
}

expFS
changeHN
autologin
gpu
pass
#timezone

whonixRep

for num in 1 2 3 4
do
    case $num in
    1)
        prog=uwt
        installingPack $prog
        installPack $prog && verifyIns $prog
        ;;
    2)
        prog=usability-misc
        installingPack $prog
        installPack $prog && verifyIns $prog
        ;;
    3)
        prog=tor
        installingPack $prog
        installPack $prog && verifyIns $prog
        ;;
    4)
        prog=calibre
        installingPack $prog
        installPack $prog && verifyIns $prog
        ;;
    esac
done

upd_upg

var=$(lsblk --output=FSSIZE  /dev/mmcblk0p2 | grep G | tr -dc '0-9')
echo "${CYAN}Filesys will be expanded to: ${CLEAR}$var GB"

var=$(cat /boot/config.txt |grep gpu | tr -dc '0-9')
echo "${CYAN}GPU memory will be changed to: ${CLEAR}$var MB"

echo "${CYAN}Autologin to console will be enabled${CLEAR}"

echo "${CYAN}Password will be changed${CLEAR}"

var=$(cat /etc/hostname)
echo "${CYAN}Hostname will be changed to: ${CLEAR}$var"


for num in 1 2 3 4 5
do
    case $num in
    1)
        prog=uwt
        verifyIns $prog
        ;;
    2)
        prog=usability-misc
        verifyIns $prog
        ;;
    3)
        prog=tor
        verifyIns $prog
        ;;
    4)
        prog=calibre
        verifyIns $prog
        ;;
    5)
        prog=adduser
        verifyIns $prog
        ;;
    esac
done
    

enterReboot
