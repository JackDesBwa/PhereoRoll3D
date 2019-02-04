#!/bin/sh

# build.sh.conf should define...
#
# QTBIN1= # Path to Qt bin/ directory for normal version
# NDK1= # Path to Android NDK for normal version
# JDK1= # Path to JDK for normal version
#
# QTBIN2= # Path to Qt bin/ directory for retro version
# NDK2= # Path to Android NDK for retro version
# JDK2= # Path to JDK for retro version
# 
# SDK= # Path to Android SDK
# 
# KEYSTORE= # Path to keystore file
# KEYSTORE_ALIAS= # Alias in keystore file
# KEYSTORE_PASS= # Keystore password
source ./build.sh.conf

mkdir -p build
cd build

m() {
	QTBIN=$1
	NDK=$2
	JDK=$3
	APK=$4

	export ANDROID_HOME=$SDK
	export ANDROID_SDK_ROOT=$SDK
	export ANDROID_NDK_ROOT=$NDK
	export PATH=$JDK/bin:$PATH

	echo -ne "\033[1m" # Bold
	echo -n "Execute qmake"
	echo -e "\033[0m" # Normal
	$QTBIN/qmake ../PhereoRoll3D.pro

	echo -ne "\033[1m" # Bold
	echo -n "Execute make clean"
	echo -e "\033[0m" # Normal
	$NDK/prebuilt/linux-x86_64/bin/make clean -j8

	echo -ne "\033[1m" # Bold
	echo -n "Execute make"
	echo -e "\033[0m" # Normal
	$NDK/prebuilt/linux-x86_64/bin/make -j8

	echo -ne "\033[1m" # Bold
	echo -n "Execute make install"
	echo -e "\033[0m" # Normal
	$NDK/prebuilt/linux-x86_64/bin/make INSTALL_ROOT=./android-build install

	RETRO=0
	echo $APK | grep retro > /dev/null
	[ $? == 0 ] && RETRO=1

	if [ $RETRO == 1 ]
	then
		echo -ne "\033[1m" # Bold
		echo -n "Change files to RETRO ones"
		echo -e "\033[0m" # Normal
		cp ../android/retro/* ../android/
	fi

	echo -ne "\033[1m" # Bold
	echo -n "Execute androiddeployqt"
	echo -e "\033[0m" # Normal
	$QTBIN/androiddeployqt --input ./android-libPhereoRoll3D.so-deployment-settings.json --output ./android-build --android-platform android-26 --jdk $JDK --verbose --gradle --sign $KEYSTORE $KEYSTORE_ALIAS --storepass "$KEYSTORE_PASS"

	echo -ne "\033[1m" # Bold
	echo -n "Move result"
	echo -e "\033[0m" # Normal
	OUT=./android-build/build/outputs/apk/android-build-release-signed.apk
	[ ! -f $OUT ] && OUT=./android-build/build/outputs/apk/release/android-build-release-signed.apk
	mv $OUT ../$APK

	echo -ne "\033[1m" # Bold
	echo -n "Clean up"
	echo -e "\033[0m" # Normal
	rm -rf * .qmake.stash

	if [ $RETRO == 1 ]
	then
		git checkout ../android
	fi
}

m $QTBIN1 $NDK1 $JDK1 PhereoRoll3D.apk
m $QTBIN2 $NDK2 $JDK2 PhereoRoll3D_retro.apk

cd ..
rmdir build
