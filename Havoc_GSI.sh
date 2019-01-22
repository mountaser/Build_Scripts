#!/bin/bash

#Startup
date="$(date +%y%m%d)"
. build/envsetup.sh
export LC_ALL=C
sudo chmod 777 ./vendor/havoc/build/tools/changelog.sh

#If Statments 
echo "==================================="
read -p "Build Official ? y? n?" BF
if [ $BF = y ]
then
export HAVOC_BUILD_TYPE=Official
echo "==================================="
echo "Official Build"
echo "==================================="
elif [ $BF = n ]
then
echo "==================================="
echo "Unofficial Build"
echo "==================================="
fi

read -p "Havoc Version ?" HV
echo ""
echo "==================================="
echo "1= ARM64 AB"
echo "2= ARM64 Aonly"
echo "3= ARM Aonly"
echo "==================================="
read -p "Inter the build type ?" BT

if [ $BT = 1 ]
then
lunch treble_arm64_bvN-userdebug
elif [ $BT = 2 ]
then
lunch treble_arm64_avN-userdebug
elif [ $BT = 2 ]
then
lunch treble_arm_avN-userdebug
fi

#Fore the upload folder
if [ $BT = 1 ]
then
BTN="arm64-ab"
elif [ $BT = 2 ]
then
BTN="arm64-aonly"
elif [ $BT = 2 ]
then
BTN="arm-aonly"
fi


echo "==================================="
echo "Build Type" $BTN
echo "==================================="

#CCache
read -p "use CCache ? y? n?" CC
if [ $CC = y ]
then
export USE_CCACHE=1
export CCACHE_COMPRESS=1
echo "==================================="
echo "CCache On"
echo "==================================="
elif [ $CC = n ]
then
echo "==================================="
echo "CCache Off"
echo "==================================="
fi

#Make Clean
read -p "Make Clean ? y? n?" MK
if [ $MK = y ]
then
make clean
make clobber
echo "==================================="
echo "Clean Build"
echo "==================================="
elif [ $MK = n ]
then
echo "==================================="
echo "Dirty Build"
echo "==================================="
fi

#Make
make WITHOUT_CHECK_API=true BUILD_NUMBER=$date -j24 systemimage

mkdir release
mv $OUT/system.img ~/release/Havoc-OS-v$HV-$date-GSI-$BTN-Official.img

#Zip
xz -c -T 24 ~/release/Havoc-OS-v$HV-$date-GSI-$BTN-Official.img > ~/release/Havoc-OS-v$HV-$date-GSI-$BTN-Official.img.xz

#upload if official
if [ $BF = y ]
then
echo "==================================="
read -p "Inter sourceforge Password" SFP
echo "==================================="
echo -e "Uploading to official sourceforge"
echo "==================================="
sshpass -p $SFP scp ~/release/Havoc-OS-v$HV-$date-GSI-$BTN-Official.img.xz maintainers@frs.sourceforge.net:/home/pfs/project/havoc-os/$BTN
wait
echo "==================================="
echo -e "Uploaded file successfully"
echo "==================================="
fi
