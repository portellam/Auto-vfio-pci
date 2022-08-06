#!/bin/bash sh

# check if sudo/root #
if [[ `whoami` != "root" ]]; then
    echo -e "$0: WARNING: Script must be run as Sudo or Root! Exiting."
    exit 0
fi

# NOTE: necessary for newline preservation in arrays and files #
SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char

# system files #
str_file1="/etc/default/grub"
str_file2="/etc/initramfs-tools/modules"
str_file3="/etc/modules"
str_file4="/etc/modprobe.d/pci-blacklists.conf"
str_file5="/etc/modprobe.d/vfio.conf"

# system file backups #
str_oldFile1=$(pwd)"/etc_default_grub.old"
str_oldFile2=$(pwd)"/etc_initramfs-tools_modules.old"
str_oldFile3=$(pwd)"/etc_modules"

# debug logfiles #
str_logFile0=`find . -name *hugepages*log*`
str_logFile1=`find . -name etc_default_grub.log`
str_logFile2=`find . -name etc_initramfs-tools_modules.log`
str_logFile3=`find . -name etc_modules.log`
str_logFile4=`find . -name etc_modprobe.d_pci-blacklists.conf.log`
str_logFile5=`find . -name etc_modprobe.d_vfio.conf.log`
str_logFile6=`find . -name grub-menu.log`

# prompt #
echo -en "$0: Uninstalling VFIO setup... "

# clear logfiles #
if [[ -e $str_logFile0 ]]; then rm $str_logFile0; fi
if [[ -e $str_logFile1 ]]; then rm $str_logFile1; fi
if [[ -e $str_logFile2 ]]; then rm $str_logFile2; fi
if [[ -e $str_logFile3 ]]; then rm $str_logFile3; fi
if [[ -e $str_logFile4 ]]; then rm $str_logFile4; fi
if [[ -e $str_logFile5 ]]; then rm $str_logFile5; fi
if [[ -e $str_logFile6 ]]; then rm $str_logFile6; fi

## 1 ##     # /etc/default/grub
if [[ -e $str_file1 ]]; then
    mv $str_file1 $str_oldFile1

    # find GRUB line and comment out #
    while read -r str_line1; do

        # match line #
        if [[ $str_line1 == *"GRUB_CMDLINE_LINUX_DEFAULT"* && $str_line1 != "#GRUB_CMDLINE_LINUX_DEFAULT"* ]]; then
            str_line1="#"$str_line1             # update line
        fi

        echo -e $str_line1  >> $str_file1       # append to new file

    done < $str_oldFile1

    #echo -e "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"" >> $str_file1
    echo -e "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash acpi=force apm=power_off iommu=1,pt amd_iommu=on intel_iommu=on rd.driver.pre=vfio-pci pcie_aspm=off kvm.ignore_msrs=1 default_hugepagesz=1G hugepagesz=1G hugepages= modprobe.blacklist= vfio_pci.ids=\"" >> $str_file1
fi

if [[ -e $str_oldFile1 ]]; then rm $str_oldFile1; fi

## 2 ##     # initramfs-tools
#bool_readLine=true

# if [[ -e $str_file2 ]]; then
#     mv $str_file2 $str_oldFile2

#     while read -r str_line1; do
#         if [[ $str_line1 == *"# START #"* || $str_line1 == *"portellam/VFIO-setup"* ]]; then
#             bool_readLine=false
#         fi

#         if [[ $bool_readLine == true ]]; then
#             echo -e $str_line1 >> $str_file2
#         fi

#         if [[ $str_line1 == *"# END #"* ]]; then
#             bool_readLine=true
#         fi
#     done < $str_oldFile2
# fi

if [[ -e $str_file2 ]]; then rm $str_file2; fi
if [[ -e $str_oldFile2 ]]; then rm $str_oldFile2; fi

declare -a arr_file2=(
"# NOTE: Generated by 'portellam/VFIO-setup'
# START #
#
# List of modules that you want to include in your initramfs.
# They will be loaded at boot time in the order below.
#
# Syntax:  module_name [args ...]
#
# You must run update-initramfs(8) to effect this change.
#
# Examples:
#
# raid1
# sd_mod
#
# Example: Reboot hypervisor (Linux) to swap host graphics (Intel, AMD, NVIDIA) by use-case (AMD for Win XP, NVIDIA for Win 10).
# NOTE: If you change this file, run 'update-initramfs -u -k all' afterwards to update.
# NOTE: In terminal, execute \"lspci -nnk\" or review the logfiles.
\n# Soft dependencies and PCI kernel drivers:\t(NOTE: repeat for each driver)\n# EXAMPLE:\n#\tsoftdep 'DRIVER_NAME' pre: vfio-pci\n#\t'DRIVER_NAME'\n
#
\n# NOTE: Do not change the following lines, unless you know what you are doing!
vfio
vfio_iommu_type1
vfio_virqfd
#
\n# GRUB command line and PCI hardware IDs:
options vfio_pci ids=
vfio_pci ids=
vfio_pci
#
# END #")

for str_line1 in ${arr_file2[@]}; do
    echo -e $str_line1 >> $str_file2
done

## 3 ##     # /etc/modules
# bool_readLine=true

# if [[ -e $str_file3 ]]; then
#     mv $str_file3 $str_oldFile3

#     while read -r str_line1; do
#         if [[ $str_line1 == *"# START #"* || $str_line1 == *"portellam/VFIO-setup"* ]]; then
#             bool_readLine=false
#         fi

#         if [[ $bool_readLine == true ]]; then
#             echo -e $str_line1 >> $str_file3
#         fi

#         if [[ $str_line1 == *"# END #"* ]]; then
#             bool_readLine=true
#         fi
#     done < $str_oldFile3
# fi

if [[ -e $str_file3 ]]; then rm $str_file3; fi
if [[ -e $str_oldFile3 ]]; then rm $str_oldFile3; fi

declare -a arr_file3=(
"# NOTE: Generated by 'portellam/VFIO-setup'
# START #
#
# /etc/modules: kernel modules to load at boot time.
#
# This file contains the names of kernel modules that should be loaded
# at boot time, one per line. Lines beginning with \"#\" are ignored.
#
# Example: Reboot hypervisor (Linux) to swap host graphics (Intel, AMD, NVIDIA) by use-case (AMD for Win XP, NVIDIA for Win 10).
# NOTE: If you change this file, run 'update-initramfs -u -k all' afterwards to update.
# NOTE: In terminal, execute \"lspci -nnk\" or review the logfiles.
#
\n# NOTE: Do not change the following lines, unless you know what you are doing!
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
kvm
kvm_intel
apm power_off=1
#
\n# GRUB kernel parameters:
vfio_pci ids=
#
# END #")

for str_line1 in ${arr_file3[@]}; do
    echo -e $str_line1 >> $str_file3
done

## 4 ##     # /etc/modprobe.d/pci-blacklist.conf
if [[ -e $str_file4 ]]; then rm $str_file4; fi
if [[ -e $str_oldFile4 ]]; then rm $str_oldFile4; fi
echo -e "# NOTE: Generated by 'portellam/VFIO-setup'\n#\n# START #\n# EXAMPLE:\tblacklist 'DRIVER_NAME'\n\n# END #" >> $str_file4       

## 5 ##     # /etc/modprobe.d/vfio.conf
if [[ -e $str_file5 ]]; then rm $str_file5; fi

declare -a arr_file5=(
"# NOTE: Generated by 'portellam/VFIO-setup'
# START #
#
# NOTE: If you change this file, run 'update-initramfs -u -k all' afterwards to update.
# NOTE: In terminal, execute \"lspci -nnk\" or review the logfiles.
\n# Soft dependencies:\t(NOTE: repeat for each driver)\n# EXAMPLE:\n#\tsoftdep 'DRIVER_NAME' pre: vfio-pci\n
#
\n# PCI hardware IDs:
options vfio_pci ids=
# END #")

    for str_line1 in ${arr_file5[@]}; do
        echo -e $str_line1 >> $str_file5       
    done

if [[ -e $str_oldFile5 ]]; then rm $str_oldFile5; fi

echo -e " Complete.\n"
sudo update-grub                    # update GRUB
sudo update-initramfs -u -k all     # update INITRAMFS
echo
IFS=$SAVEIFS                        # reset IFS     # NOTE: necessary for newline preservation in arrays and files
exit 0