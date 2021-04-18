#!/bin/sh

# Script για ευκολη εγκατασταση της GATE και οτι χρεαιζεται για αυτη
# Το εφτιαξα με την βοηθεια ενος αλλου script απο τον Alexandre
# Version 1.0
# Created on: 17 April
# Author: Δημητρης Γκαβακος
#USE AT YOUR OWN RISK!

echo ".-.__      \ .-.  ___  __                                                    "
echo "|_|  '--.-.-(   \/\;;\_\.-._______.-.                                        "
echo "(-)___     \ \ .-\ \;;\(   \       \ \                                       "
echo " Y    '---._\_((Q)) \;;\\ .-\     __(_)                                      "
echo " I           __'-' / .--.((Q))---'    \,            May the force            "
echo " I     ___.-:    \|  |   \'-'_          \              be with you.          "
echo " A  .-'      \ .-.\   \   \ \ '--.__     '\                                  "
echo " |  |____.----((Q))\   \__|--\_      \     '     ||----------------------||  "
echo "    ( )        '-'  \_  :  \-' '--.___\          || Using latest builds. ||  "
echo "     Y                \  \  \       \(_)         || Last update: 17/4/21 ||  "
echo "     I                 \  \  \         \,        || By: D.Gkavakos       ||  "
echo "     I                  \  \  \          \       ||----------------------||  "
echo "     A                   \  \  \          '\                                 "
echo "     |                    \  \__|           '                                "
echo "                           \_:.  \                                           "
echo "                             \ \  \                                          "
echo "                              \ \  \                                         "
echo "                               \_\_|                                         "

function validate_url(){
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

## Check os release
DISTRO=$( cat /etc/*-release | tr [:upper:] [:lower:] | grep -Poi '(debian|ubuntu|red hat|centos|scientific|opensuse)' | uniq -c | sort -r | head -1|  xargs | cut -d" " -f2- )
if [[ -z $DISTRO ]]; then
    DISTRO='unknown'
    echo "Detected Linux distribution: $DISTRO"
    echo "The script has not been done for your distribution, sorry ..."
    return
else
    echo "Detected Linux distribution: $DISTRO"
fi

if [[ $DISTRO =~ "debian" ]] || [[ $DISTRO =~ "ubuntu" ]]; then
    INSTALL_TYPE='apt'
elif [[ $DISTRO =~ "red hat" ]] || [[ $DISTRO =~ "centos" ]] || [[ $DISTRO =~ "scientific" ]]; then
    INSTALL_TYPE='yum'
elif [[ $DISTRO =~ "opensuse" ]]; then
    INSTALL_TYPE='zypper'
fi


wget -q --spider http://google.com
if [ $? -eq 0 ]; then
    echo "Your internet connection has been successfully tested"
else
    echo "Please check your internet connection & restart the script"
    return
fi

## Installation of GATE or not ?
while true; do
    read -p "Do you wish to install GATE and its dependencies [y/n]?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) return;;
        * ) echo "Please answer yes or no.";;
    esac
done

## Installation of GATE require sudo password
if [[ "$EUID" = 0 ]]; then
    echo "You are logged as root"
    echo "The installation can't be processed as root"
    return
else
    sudo -k # make sure to ask for password on next sudo
    if sudo true; then
        echo "correct password"
    else
        echo "wrong password"
    return
    fi
fi

# keep sudo alive
while true; do
  sleep 200
  sudo -n true
  kill -0 "$$" 2>/dev/null || exit
done &

## Verify if there is a version of GATE already installed ?
if which Gate 2>/dev/null
    then
        echo "'Gate' seems to be already installed."
            while true; do
            read -p "Are you sure you want to proceed with the installation [y/n]?" yn
            case $yn in
            [Yy]* ) break;;
            [Nn]* ) return;;
            * ) echo "Please answer yes or no.";;
        esac
   done
fi

## Personalize the GATE installation path.
while true; do
    read -p "Do you want to personalize the installation path [y/n]? (default : usr/local)" yn
    case $yn in
        [Yy]* ) read -p "Enter path: " GPTH
    if [ -d "$GPTH" ]
    then
            echo "$GPTH is valide."
        break
    else
            echo "$GPTH is not valide. Please check the path enter !"
    fi;;
        [Nn]* ) GPTH='/usr/local'; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

## Check free space on Disk (require 13 GBs)
FREE=`df -k --output=avail "$PWD" $GPTH | tail -n1`   # df -k not df -h
if [[ $FREE -lt 13631488 ]]; then               # 13G = 13*1024*1024k
     echo "You need at least 13 GBs of free space to install GATE !"
     echo "less than 13 GBs free in your installation path!"
     return
fi

## Go to the installation directory
cd $GPTH
sudo mkdir GATE
sudo chmod -R 777 GATE
cd $GPTH/GATE

## Download all the files for Gate installation
#root
url_root="https://root.cern/download/root_v6.24.00.source.tar.gz"
if validate_url url_root; then
    echo "Url : $url_root exists..."
    wget https://root.cern/download/root_v6.24.00.source.tar.gz
    tar -xvzf root_v6.24.00.source.tar.gz
    rm root_v6.24.00.source.tar.gz
  else
    echo "Url : $url_root doesn't exists.."
    echo "The link seems to be broken, please contact the author to update the script"
    return
fi

#itk
url_itk="https://github.com/InsightSoftwareConsortium/ITK/releases/download/v5.1.2/InsightToolkit-5.1.2.tar.gz"
if validate_url url_itk; then
    echo "Url : $url_itk exists..."
    wget https://github.com/InsightSoftwareConsortium/ITK/releases/download/v5.1.2/InsightToolkit-5.1.2.tar.gz
    tar -xvzf InsightToolkit-5.1.2.tar.gz
    rm InsightToolkit-5.1.2.tar.gz
else
    echo "Url : $url_itk doesn't exists.."
    echo "The link seems to be broken, please contact the author to update the script"
    return
fi
#geant4
url_geant="http://cern.ch/geant4-data/releases/geant4.10.07.p01.tar.gz"
if validate_url url_geant; then
    echo "Url : $url_geant exists..."
    wget http://cern.ch/geant4-data/releases/geant4.10.07.p01.tar.gz
    tar -xvzf geant4.10.07.p01.tar.gz
    rm geant4.10.07.p01.tar.gz
else
    echo "Url : $url_geant doesn't exists.."
    echo "The link seems to be broken, please contact the author to update the script"
    return
fi
#gate
url_gate=" https://github.com/OpenGATE/Gate/archive/v9.0.zip"
if validate_url url_gate; then
    echo "Url : $url_gate exists..."
    wget  https://github.com/OpenGATE/Gate/archive/v9.0.zip
    unzip v9.0.zip
    rm v9.0.zip
else
    echo "Url : $url_gate doesn't exists.."
    echo "The link seems to be broken, please contact the author to update the script"
    return
fi
#cmake
url_gate=" https://github.com/Kitware/CMake/releases/download/v3.19.8/cmake-3.19.8-Linux-x86_64.sh"
if validate_url url_gate; then
    echo "Url : $url_gate exists..."
    wget  https://github.com/Kitware/CMake/releases/download/v3.19.8/cmake-3.19.8-Linux-x86_64.sh
    mv ~/cmake-3.19.8-Linux-x86_64.sh /opt/
else
    echo "Url : $url_gate doesn't exists.."
    echo "The link seems to be broken, please contact the author to update the script"
    return
fi

## Installation of package requirements
echo "Installing the nice-to-have pre-requisites"
if [ "$INSTALL_TYPE" = "yum" ]; then
sudo yum check-update
# To get Required packages
sudo yum install git cmake gcc-c++ gcc binutils libX11-devel libXpm-devel libXft-devel libXext-devel -y
# To get optional packages
sudo yum install gcc-gfortran openssl-devel pcre-devel mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel fftw-devel cfitsio-devel graphviz-devel avahi-compat-libdns_sd-devel libldap-dev python-devel libxml2-devel gsl-static -y
fi

if [ "$INSTALL_TYPE" = "zypper" ]; then
sudo zypper update -y
# To get Required packages
sudo zypper --non-interactive --quiet install git cmake bash gcc-c++ gcc binutils xorg-x11-libX11-devel xorg-x11-libXpm-devel xorg-x11-devel xorg-x11-proto-devel xorg-x11-libXext-devel
# To get optional packages
sudo zypper --non-interactive --quiet install gcc-fortran libopenssl-devel pcre-devel Mesa glew-devel pkg-config libmysqlclient-devel fftw3-devel libcfitsio-devel graphviz-devel libdns_sd avahi-compat-mDNSResponder-devel openldap2-devel python-devel libxml2-devel krb5-devel gsl-devel libqt4-devel
fi

if [ "$INSTALL_TYPE" = "apt" ]; then
sudo apt-get update
# To get Required packages
sudo apt-get install git cmake build-essential libqt4-opengl-dev qt4-qmake libqt4-dev libx11-dev libxmu-dev libxpm-dev libxft-dev libtbb-dev libnet-dev -y
# To get optional packages
sudo apt-get install gfortran libssl-dev libpcre3-dev xlibmesa-glu-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl0-dev -y
fi

echo -e "\n"
echo 'Installation of pre-requisites done.'
echo -e "\n"
## Installation of CMake
echo "Installation of CMake-3.19.8"
cd /opt/
chmod +x cmake-3.19.8-Linux-x86_64.sh
sudo bash cmake-3.19.8-Linux-x86_64.sh
rm -r /opt/cmake-3.19.8-Linux-x86_64.sh
echo "Installation of CMake-3.19.8 done."
echo -e "\n"
## Installation of ROOT
echo "Installation of root-6.24.00"
mkdir root-6.24.00-build
cd $GPTH/GATE/root-6.24.00-build
cmake ../root-6.24.00
cmake --build . -- -j$(nproc)
source $GPTH/GATE/root-6.24.00-build/bin/thisroot.sh
cd ..
echo "Installation of root-6.24.00 done."
echo -e "\n"
## Installation of Geant4
echo "Installation of Geant4 10.7.p01"
mkdir geant4.10.07.p01-build
mkdir geant4.10.07.p01-install
cd $GPTH/GATE/geant4.10.07.p01-build
cmake -DCMAKE_INSTALL_PREFIX=$GPTH/GATE/geant4.10.07.p01-install -DCMAKE_BUILD_TYPE=Debug -DGEANT4_BUILD_MULTITHREADED=OFF -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_G3TOG4=OFF -DGEANT4_USE_GDML=OFF -DGEANT4_USE_INVENTOR=OFF -DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_QT=ON -DGEANT4_USE_RAYTRACER_X11=OFF -DGEANT4_USE_SYSTEM_EXPAT=OFF -DGEANT4_USE_SYSTEM_ZLIB=OFF -DGEANT4_USE_XM=OFF $GPTH/GATE/geant4.10.07.p01
make -j$(nproc)
make install
source $GPTH/GATE/geant4.10.07.p01-install/bin/geant4.sh
cd ..
echo "Installation of Geant4 10.07.p01 done."
echo -e "\n"
## Installation of ITK
echo "Installation of ITK 5.0.1 "
cd $GPTH/GATE/InsightToolkit-5.0.1
mkdir bin
cd bin
cmake -DITK_USE_REVIEW=ON -DBUILD_EXAMPLES=ON -DBUILD_TESTING=ON -DINSTALL_GTEST=ON -DITKV3_COMPATIBILITY=OFF -DITK_BUILD_DEFAULT_MODULES=ON -DITK_WRAP_PYTHON=OFF ..
make -j$(nproc)
sudo make install
cd ../..
echo "Installation of ITK 5.0.1 done."
echo -e "\n"
## Installation of GATE
echo "Installation of Gate V9.0"
sudo mkdir Gate-9.0-build
sudo mkdir Gate-9.0-install
cd Gate-9.0-build
cmake -DCMAKE_INSTALL_PREFIX=$GPTH/GATE/Gate-9.0-install -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=RELEASE -DGATE_DOWNLOAD_BENCHMARKS_DATA=OFF -DGATE_USE_DAVIS=OFF -DGATE_USE_ECAT7=OFF -DGATE_USE_GEANT4_UIVIS=ON -DGATE_USE_GPU=OFF -DGATE_USE_ITK=ON -DGATE_USE_LMF=OFF -DGATE_USE_OPTICAL=ON -DGATE_USE_RTK=OFF -DGATE_USE_STDC11=ON -DGATE_USE_SYSTEM_CLHEP=OFF -DGATE_USE_XRAYLIB=OFF -DGeant4_DIR=$GPTH/GATE/geant4.10.07.p01-install/lib/Geant4-10.07.1 -DITK_DIR=/usr/local/lib/cmake/ITK-5.0 -DROOTCINT_EXECUTABLE=$GPTH/GATE/root-6.24.00-build/bin/rootcint -DROOT_CONFIG_EXECUTABLE=$GPTH/GATE/root-6.24.00-build/bin/root-config $GPTH/GATE/Gate-9.0
make -j$(nproc)
make install
echo "Installation of Gate V9.0 done."
cd ..

## Export GATE environnment (path variable)
touch gate_env.sh
echo 'source' $GPTH'/GATE/root-6.24.00-build/bin/thisroot.sh' >> gate_env.sh
echo 'source' $GPTH'/GATE/geant4.10.07.p01-install/bin/geant4.sh' >> gate_env.sh
echo 'export PATH=$PATH:'$GPTH'/GATE/Gate-9.0-install/bin' >> gate_env.sh
echo -e "\n" >> ~/.bashrc
echo '# export path variable for GATE' >> ~/.bashrc
echo 'alias gate90'='"source '$GPTH'/GATE/gate_env.sh''"' >> ~/.bashrc
source ~/.bashrc

## verify if Gate is installed and present in $GPTH/GATE/Gate-9.0-install/bin
gate90
if ! which Gate 2>/dev/null
then
    echo "'Gate' was not found in PATH, a problem seems to be appeared during installation."
    echo "Maybe check error message during installation."
    return
else
    echo "'Gate' was successfully installed"
fi

## Installation of Cluster tools or not ?
if [ "$INSTALL_TYPE" = "apt" ]; then
while true; do
    read -p "Do you wish to install the Cluster tools (HTcondor) [y/n]?
Advice if you are not an advanced user : Always answer yes for HTcondor prompt GUI  " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) return;;
        * ) echo "Please answer yes or no.";;
    esac
done
## Installation of Cluster tools for Ubuntu users
#jobsplitter
cd $GPTH/GATE/Gate-9.0/cluster_tools/jobsplitter
make
cp $GPTH/GATE/Gate-9.0/cluster_tools/jobsplitter/gjs $GPTH/GATE/Gate-9.0-install/bin
#filemerger
cd $GPTH/GATE/Gate-9.0/cluster_tools/filemerger
make
cp $GPTH/GATE/Gate-9.0/cluster_tools/filemerger/gjm $GPTH/GATE/Gate-9.0-install/bin
#HTcondor for multicore processing (clustering) (always anwser yes to gui prompt for easy use)
sudo apt-get install htcondor -y
sudo condor_master
if ! hash condor_status 2>/dev/null
then
    echo "'HTcondor' was not found, a problem seems to be appeared during installation."
    echo "Maybe check error message during installation."
else
    echo "HTcondor was successfully installed"
fi
fi
cd
return
