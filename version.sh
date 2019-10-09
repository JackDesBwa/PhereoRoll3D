#!/bin/sh
# Script to help to update version number at each needed location


# Build version vars

if [ "$1" != "" -a "$2" != "" -a "$3" != "" -a "$4" == "" ]
then
	VERSION_S=$1.$2.$3
	VERSION_C=$(($3 + $2 * 10 + $1 * 10 * 100))

elif [ "$1" != "" -a "$2" != "" -a "$3" == "" ]
then
	VERSION_S=$1.$2
	VERSION_C=$(($2 * 10 + $1 * 10 * 100))
else
	echo "$0 <ver> <subver> [patch]"
	exit 1
fi


# Edit files

sed -i "s/android:versionName=\"[^\"]*\"/android:versionName=\"${VERSION_S}\"/" android/AndroidManifest.xml
sed -i "s/android:versionCode=\"[^\"]*\"/android:versionCode=\"${VERSION_C}\"/" android/AndroidManifest.xml
sed -i "s/android:versionName=\"[^\"]*\"/android:versionName=\"${VERSION_S}\"/" android/retro/AndroidManifest.xml
sed -i "s/android:versionCode=\"[^\"]*\"/android:versionCode=\"${VERSION_C}\"/" android/retro/AndroidManifest.xml
sed -i "s/version: \"[^\"]*\"/version: \"${VERSION_S}\"/" qml/main.qml

echo "Don't forget to change version.json"
