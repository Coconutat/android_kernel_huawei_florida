#!/bin/bash
#设置环境

# Special Clean For Huawei Kernel.
if [ -d include/config ];
then
    echo "Find config,will remove it"
	rm -rf include/config
else
	echo "No Config,good."
fi

echo " "
echo "***Setting environment...***"
# 交叉编译器路径
export PATH=$PATH:/home/coconutat/github/android_kernel_huawei_florida/aarch64-linux-android-4.9/bin
export CROSS_COMPILE=aarch64-linux-android-

export GCC_COLORS=auto
export ARCH=arm64
if [ ! -d "out" ];
then
	mkdir out
fi

#输入内核版本号
printf "Please enter Kernel version number: "
read v
echo " "
echo "Setting EXTRAVERSION"
export EV=EXTRAVERSION=_Kirin659_$v

date="$(date +%Y.%m.%d-%I:%M)"

#构建内核部分
echo "***Building Kernel...***"
make ARCH=arm64 O=out $EV merge_hi6250_mod_defconfig
# 定义编译线程数
make ARCH=arm64 O=out $EV -j256 2>&1 | tee kernel_log-${date}.txt

#打包内核

if [ -f out/arch/arm64/boot/Image.gz ];
then
	echo "***Packing kernel...***"
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x00400000 --cmdline "loglevel=4 coherent_pool=512K page_tracker=on slub_min_objects=12 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=enforcing buildvariant=user" --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x10000000 --os_version 9 --os_patch_level 2019-05-05 --output Kirin659_V"$v"_${date}.img
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x00400000 --cmdline "loglevel=4 coherent_pool=512K page_tracker=on slub_min_objects=12 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=permissive buildvariant=user" --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x10000000 --os_version 9 --os_patch_level 2019-05-05 --output Kirin659_V"$v"_PM_${date}.img
	cp out/arch/arm64/boot/Image.gz Image.gz 
	echo " "
	echo "***Sucessfully built kernel...***"
	echo " "
	exit 0
else
	echo " "
	echo "***Failed!***"
	exit 0
fi