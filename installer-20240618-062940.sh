#!/bin/bash
###############################################################################
#
# Illumina DRAGEN ORA Helper Installer
# Copyright 2024
# Script Version 2.0.0
#
###############################################################################

set -e

INV="\033[7m"
BRN="\033[33m"
RED="\033[31m"
GREEN="\033[32m"
END="\033[0m\033[27m"

function on_error() {
    printf "$RED
It looks like you had an issue trying to install Ora.
Feel free to contact Illumina's customer services.
$END"
}
trap on_error ERR



# OS/Distro Detection
if [ -f /etc/debian_version ]; then
    OS=Debian
elif [ -f /etc/redhat-release ]; then
    OS=RedHat
elif [ -f /etc/system-release ]; then
    OS=`cut -d " " -f 1 /etc/system-release`
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
else
    OS=$(uname -s)
fi


echo ""
echo -e "$GREEN === Welcome to Illumina ORA setup for $OS === $END"
echo ""
sleep 2


echo "== Downloading OraHelper Suite =="
echo
echo -e "${BRN}curl -kL \"https://webdata.illumina.com/downloads/software/ora/oraHelperSuite/oraHelperSuite-20240618-062940.tgz\" | tar xz${END}"
curl -kL "https://webdata.illumina.com/downloads/software/ora/oraHelperSuite/oraHelperSuite-20240618-062940.tgz" | tar xz

if [ ! -e oraHelperSuite/refbin ] ; then
  echo
  echo "* Downloading reference data *"
  echo
  curl -kL "https://webdata.illumina.com/downloads/software/ora/refbin-v2.0.gz" | zcat > oraHelperSuite/refbin
fi


if [ $OS = Debian ]; then

    echo ""
    mv -f oraHelperSuite/oraFuse-ubuntu oraHelperSuite/oraFuse
    rm oraHelperSuite/oraFuse-centos oraHelperSuite/orad_macos oraHelperSuite/orad_windows.exe

elif [ $OS = RedHat -o $OS = Amazon ]; then
    echo ""
    mv -f oraHelperSuite/oraFuse-centos oraHelperSuite/oraFuse
    rm oraHelperSuite/oraFuse-ubuntu oraHelperSuite/orad_macos oraHelperSuite/orad_windows.exe

elif [[ $OS == Darwin ]] || [[ $OS == MINGW* ]] ; then

    echo -e "${RED}* Sorry, OraHelper is available only on Linux systems. For MacOS / Windows please download the DRAGEN ORA standalone decompression software orad ${END}"
    exit 1
    
    # echo ""

    # # Deleting all non-mac/windows executables
    # rm oraHelperSuite/orad oraHelperSuite/oraFuse* oraHelperSuite/ora-ldpreload.so oraHelperSuite/oraHelper

    # if [[ $OS == Darwin ]] ; then
    #     mv oraHelperSuite/orad_macos oraHelperSuite/orad
    #     rm oraHelperSuite/orad_windows.exe
    # else
    #     mv oraHelperSuite/orad_windows.exe oraHelperSuite/orad.exe
    #     rm oraHelperSuite/orad_macos
    # fi

    # # Special final message without oraFuse for MacOS
    # echo "=== ORA successfully installed ==="
    # echo ""
    # echo "Please note that on MacOS and Windows, only orad is installed. The Ora LD-Preload solution, oraFuse and oraHelper are only available on Linux."
    # echo ""
    # echo "* You can now add the oraHelperSuite directory to your PATH and try orad: *"
    # echo ""
    # echo "    export PATH=$(pwd)/oraHelperSuite:\$PATH"
    # echo "    orad file.fastq.ora"
    # echo ""
    # exit 0

else

    echo -e "${RED}* Sorry, BaseMount does not currently support this linux distribution: $OS ${END}"
    exit 1

fi


echo ""
echo "== Installing oraFuse libraries =="
echo ""

if [ $OS = Debian ]; then

    echo "This is only needed for the oraFuse tool, requires sudo access for installation, and you may decide to run it later."
    echo -e "${BRN}sudo apt update && sudo apt install fuse openssl libcurl3-gnutls${END}"
    read -p "Should I run this command for you now (Y/n)? " -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
        ( apt update && apt install fuse openssl libcurl3-gnutls ) || true # Don't stop if fail
    fi

else #if [ $OS = RedHat -o $OS = Amazon ]; then

    echo "This is only needed for the oraFuse tool, requires sudo access for installation, and you may decide to run it later."
    echo -e "${BRN} yum install fuse fuse-libs libcurl openssl${END}"
    yum install fuse fuse-libs libcurl openssl 

fi



echo ""
echo ""
echo -e "${GREEN}=== ORA tools successfully installed ===${END}"
echo ""
echo "* You can now add the oraHelperSuite directory to your PATH and try orad or oraHelper: *"
echo ""
echo "    export PATH=$(pwd)/oraHelperSuite:\$PATH"
echo "    orad file.fastq.ora"
echo "    oraHelper bwa -i file.fastq.ora"
echo ""
