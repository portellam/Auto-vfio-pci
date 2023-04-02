#!/bin/bash sh

#
# Filename:         deploy-vfio.bash
# Description:      Effortlessly deploy a VFIO setup (PCI passthrough).
# Author(s):        Alex Portell <github.com/portellam>
# Maintainer(s):    Alex Portell <github.com/portellam>
#

# <remarks> Using </remarks>
# <code>
    cd bin
    source bashlib-all
    source vfiolib-all
# </code>

# <code>
function Main
{
    # <remarks> Gather arguments. </remarks>
    SetScriptDir || return $?
    IsSudoUser || return $?
    if ! SetOptions $@; then GetUsage; return $?; fi

    # <remarks> Exit early. </remarks>
    if $bool_uninstall_vfio; then
        Setup_VFIO
        return $?
    fi

    # <remarks> Extras </remarks>
    AddUserToGroups
    Allocate_CPU
    Allocate_RAM
    Virtual_KVM
    RAM_Swapfile
    LibvirtHooks
    # GuestVideoCapture     # currently failing.
    GuestAudioLoopback
    # GuestAudioStream      # currently failing.
    Modify_QEMU

    # <remarks> Main setup </remarks>
    case true in
        $bool_parse_IOMMU_from_file )
            Parse_IOMMU "FILE" || return $?
            ;;

        $bool_parse_IOMMU_from_internet )
            Parse_IOMMU "DNS" || return $?
            ;;

        $bool_parse_IOMMU_from_local | * )
            Parse_IOMMU "LOCAL" || return $?
            ;;
    esac

    Select_IOMMU $@ || return $?
    Setup_VFIO
    return $?
}
# </code>

while [[ $? -eq 0 || $? -eq $int_code_partial_completion || $? -eq $int_code_skipped_operation ]]; do
    Main $@
    break
done

exit $?