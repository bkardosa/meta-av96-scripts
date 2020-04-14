#!/bin/bash -

######################################################
# Check if script is sourced as expected
#
_verify_env() {
    local  __resultvar=$1
    if [ "$0" = "$BASH_SOURCE" ]; then
        echo "###################################"
        echo "[ERROR] YOU MUST SOURCE the script"
        echo "###################################"
        if [[ "$__resultvar" ]]; then
            eval $__resultvar="ERROR_SOURCE"
        fi
        return
    fi
    # check that we are not root!
    if [ "$(whoami)" = "root" ]; then
        echo -e "\n[ERROR] do not use the BSP as root. Exiting..."
        if [[ "$__resultvar" ]]; then
            eval $__resultvar="ERROR_ROOT"
        fi
        return
    fi
    # check that we are where we think we are!
    local oe_tmp_pwd=$(pwd)
    # need to take care of build system available
    if [[ ! -d $oe_tmp_pwd/layers/openembedded-core ]] && [[ ! -d $oe_tmp_pwd/layers/poky ]]; then
        echo "PLEASE launch the envsetup script at root tree of your oe sdk"
        echo ""
        local oe_tmp_root=$oe_tmp_pwd
        while [ 1 ];
        do
            oe_tmp_root=$(dirname $oe_tmp_root)
            if [ "$oe_tmp_root" == "/" ]; then
                echo "[WARNING]: you try to launch the script outside oe sdk tree"
                break;
            fi
            if [[ -d $oe_tmp_root/layers/openembedded-core ]] || [[ -d $oe_tmp_root/layers/poky ]]; then
                echo "Normally at this location: $oe_tmp_root"
                break;
            fi
        done
        if [[ "$__resultvar" ]]; then
            eval $__resultvar="ERROR_OE"
        fi
        return
    else
        # Fix build system to use for init: default would be openembedded-core one
        [ -d $oe_tmp_pwd/layers/poky ] && _BUILDSYSTEM=layers/poky
        [ -d $oe_tmp_pwd/layers/openembedded-core ] && _BUILDSYSTEM=layers/openembedded-core
    fi
    if [[ "$__resultvar" ]]; then
        eval $__resultvar="NOERROR"
    fi
}

######################################################
# Main
# --
#

#----------------------------------------------
# Make sure script has been sourced
#
_verify_env ret
case $ret in
    ERROR_OE | ERROR_ROOT | ERROR_SOURCE)
        if [ "$0" != "$BASH_SOURCE" ]; then
            return 2
        else
            exit 2
        fi
        ;;
    *)
        ;;
esac

DISTRO=openstlinux-weston
MACHINE=stm32mp1-av96
META_LAYER_ROOT=layers/

BUILD_DIR="build-${DISTRO//-}-$MACHINE"

if [ ! -f "$BUILD_DIR/conf/bblayers.conf" ]; then
	mkdir -p $BUILD_DIR/conf
	cp layers/meta-arrow/scripts/files/bblayers.conf $BUILD_DIR/conf/
fi

source layers/meta-st/scripts/envsetup.sh
