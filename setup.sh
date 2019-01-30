#!/bin/sh

#check if invoked with sudo/root rights or not
#https://stackoverflow.com/questions/18215973/how-to-check-if-running-as-root-in-a-bash-script/28776100#28776100
usercheck=$(id -u)
if test $usercheck -ne 0; then
    echo ""
    echo "######################## Warning ###############################"
    echo ""
    echo "Please run the script as root or with root privileges (sudo)."
    echo "Script will exit now."
    echo ""
    echo "################################################################"
    echo ""
    #successfully finished, therefore exit 0, exit 1 would indicate an error
    exit 0
fi

echo ""
echo "######################## Warning ###############################"
echo ""
echo " Before executing the script, make sure that you:"
echo ""
echo " 1. added 'contrib non-free' to /etc/apt/sources.list"
echo " 2. system have installed latest updates"
echo " (apt-get update && apt-get dist-upgrade)."
echo ""
echo "################################################################"
echo ""

read -r -p "Press Enter to continue or Ctrl+C to exit." key

#https://serverfault.com/questions/16204/how-to-make-bash-scripts-print-out-every-command-before-it-executes

set -v

#### install missing packages ####
#firmware for GPU and microcode for CPU

apt-get update
apt-get dist-upgrade
apt-get install firmware-misc-nonfree intel-microcode

#### install systemd services ####

## for touchscreen and keyboard/touchpad

cp ./systemd/after_boot.sh ./systemd/after_resume.sh /usr/local/bin/
cp ./systemd/after_boot.service ./systemd/after_resume.service /etc/systemd/system/

chmod a+x /usr/local/bin/after_boot.sh
chmod a+x /usr/local/bin/after_resume.sh

systemctl enable after_resume.service
systemctl enable after_boot.service

#just in case, if old .service files were present
#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sect-managing_services_with_systemd-unit_files

systemctl daemon-reload

#### install grub conf changes ####

## for enabling surface dock Ethernet and str (suspend-to-ram)

#replace line "GRUB_CMDLINE_LINUX_DEFAULT="quiet"" with GRUB_CMDLINE_LINUX_DEFAULT="usbcore.quirks=045e:07c6:k mem_sleep_default=deep quiet" and create a backup of the original file *_orig
#https://likegeeks.com/sed-linux/#Modifying-Lines

sed -i_orig '/GRUB_CMDLINE_LINUX_DEFAULT/c GRUB_CMDLINE_LINUX_DEFAULT="usbcore.quirks=045e:07c6:k mem_sleep_default=deep quiet"' /etc/default/grub

#https://wiki.debian.org/Grub#Configuring_GRUB_v2

update-grub

#### enable suspend-then-hibernate, so after 24h automatically go from suspend -> hibernate ####
#https://askubuntu.com/questions/1072504/lid-closed-suspend-then-hibernate

#not yet implemented in the script, was not working atm, seems to conflict with the type-cover systemd service

#### install firmware-atheros + board-2.bin for QCA6174 ####

apt-get update
apt-get install firmware-atheros

#md5sum ./firmware/board-2.bin
#bc52aa5640b27fa50f9d4d144f81e169

#remove board bins from debian package
rm /lib/firmware/ath10k/QCA6174/hw3.0/board-2.bin
rm /lib/firmware/ath10k/QCA6174/hw3.0/board.bin

cp ./firmware/board.bin /lib/firmware/ath10k/QCA6174/hw3.0

set +v

read -r -p "Finished. Press Enter to exit and then please reboot system." key

