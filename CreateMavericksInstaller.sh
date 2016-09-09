#!/bin/bash
#
# This executable converts a Mavericks .app (which allows to upgrade a machine
# from Mac OS 10.6.7+ to Mavericks) into a Mavericks .vmdk (which allows to
# install Mavericks from scratch in a virtual machine).
#
# It has been tested with the following Mac OS versions
# o 10.9 (starting with Developer Preview 4)
# o 10.10
# o 10.11
#
# Note: "IA" below does not stand for Intel Architecture, it stands for Install
# Assistant.
#

# Uncomment the following line to get debug output.
#exec >/tmp/debug 2>&1

set -x
set -e
set -E

# The first argument is the path to the .app bundle (the input of the
# executable).
inputApp="$1"
inputAppB="`basename "$inputApp"`"
inputAppU="${inputAppB// /%20}"

# The second argument is the path to the .vmdk file (the output of the
# executable), which must end with ".vmdk".
outputVmdk="$2"
[ "${outputVmdk: -5}" = .vmdk ]
outputDmg="${outputVmdk:0:${#outputVmdk} - 5}".dmg

# createinstallmedia hardcodes the volume name. The installation succeeds
# regardless of the name, so let us just pick something sensible.
volName="`defaults read "$inputApp"/Contents/Info CFBundleDisplayName`"

tmpDir="`mktemp -d -t 'Create Mavericks Installer'`"
outputMnt="$tmpDir"/output
installMnt="$tmpDir"/install
baseMnt="$tmpDir"/base

cleanup() {
   local status="$?"

   if [ -d "$outputMnt" ]; then
      hdiutil detach "$outputMnt"
   fi

   if [ -d "$baseMnt" ]; then
      hdiutil detach "$baseMnt"
   fi

   if [ -d "$installMnt" ]; then
      hdiutil detach "$installMnt"
   fi

   rm -rf -- "$tmpDir"

   if [ "$status" -ne 0 ]; then
      rm -f "$outputVmdk" "$outputDmg"
   fi
}

# Cleanup on failure.
trap cleanup ERR

# Mount InstallESD.dmg so we can access BaseSystem.dmg inside.
# This fails if the image is already mounted somewhere else.
hdiutil \
   attach "$inputApp"/Contents/SharedSupport/InstallESD.dmg \
   -mountpoint "$installMnt" \
   -nobrowse \
   -noverify \
   -readonly

# Mount BaseSystem.dmg so we can access files inside.
# This fails if the image is already mounted somewhere else.
hdiutil \
   attach "$installMnt"/BaseSystem.dmg \
   -mountpoint "$baseMnt" \
   -nobrowse \
   -noverify \
   -readonly

#
# Determine the size of the disk image.
#
# Between the initial boot and the first reboot, the Mavericks installer writes
# 16.2 MB to the volume, mostly to replace the
#    .IABootFiles/boot.efi
#    .IABootFiles/"$prelinkedKernelB"
#    .IABootFiles/PlatformSupport.plist
#    .IABootFiles/com.apple.Boot.plist
# hard links with actual copies...
#
# So account for that. To err on the side of caution, we further enlarge the
# disk image to keep 30 MB of free space on the volume at the first reboot.
#

addSize() {
   # Use a temp file instead of a shell pipe, to detect when "du" fails.
   BLOCKSIZE=512 du -s "$2" >"$tmpDir"/pipe
   local size="`awk '{ print $1 }' "$tmpDir"/pipe`"
   outputDmgSize=$((outputDmgSize + $1 * size))
}

#
# Determine the location of the prelinked kernel (a.k.a. kernelcache).
#
# There are two possible locations for the prelinked kernel.  The first
# location is used by newer products.  If not found there, fall back to the
# location used by Mac OS versions 10.9 and 10.10.
#

# Newer than Mac OS 10.10:
prelinkedKernel=System/Library/PrelinkedKernels/prelinkedkernel
if [ ! -r "$baseMnt"/"$prelinkedKernel" ]; then
   # Mac OS 10.9 or 10.10:
   prelinkedKernel=System/Library/Caches/com.apple.kext.caches/Startup/kernelcache
fi
prelinkedKernelB="`basename "$prelinkedKernel"`"

# A new booter System/Library/CoreServices/bootbase.efi was introduced in
# Mac OS 10.11 Public Beta 1. Apple recommends we use it going forward, but we
# make an exception for Public Beta 1 to match the behavior of
# createinstallmedia. We can remove this exception after Mac OS 10.11 is
# released.
booter=System/Library/CoreServices/bootbase.efi
if [ -r "$baseMnt"/"$booter" ]; then
   if grep -q -a 'Fri Jun 26 21:04:50 PDT 2015' "$baseMnt"/"$booter"; then
      # Mac OS 10.11 Public Beta 1
      booter=usr/standalone/i386/boot.efi
   fi
else
   booter=System/Library/CoreServices/boot.efi
fi

outputDmgSize=119200
addSize 1 "$inputApp"
for i in \
   "$prelinkedKernel" \
   System/Library/CoreServices/PlatformSupport.plist \
   "$booter" \
   ; do
   addSize 2 "$baseMnt"/"$i"
done

# Create the disk image.
rm -f "$outputDmg"
# Layout: MBRSPUD produces a smaller disk image than SPUD or GPTSPUD.
hdiutil \
   create "$outputDmg" \
   -sectors "$outputDmgSize" \
   -fs HFS+J \
   -volname "$volName" \
   -layout MBRSPUD

# Mount the disk image.
hdiutil \
   attach "$outputDmg" \
   -mountpoint "$outputMnt" \
   -nobrowse \
   -noverify

#
# Copy some files.  The majority of the work (copying the installer .app bundle
# itself) takes place later.
#

copy() {
   mkdir -p "`dirname "$2"`"
   cp -a "$1" "$2"
}

copyRel() {
   copy "$baseMnt"/"$1" "$outputMnt"/"$2"
}

copyRel "$prelinkedKernel" \
        System/Library/Caches/com.apple.kext.caches/Startup/"$prelinkedKernelB"
copyRel System/Library/CoreServices/PlatformSupport.plist \
        System/Library/CoreServices/PlatformSupport.plist
copyRel "$booter" \
        System/Library/CoreServices/boot.efi
copyRel System/Library/CoreServices/SystemVersion.plist \
        System/Library/CoreServices/SystemVersion.plist

#
# Generate some files.
#

f="$outputMnt"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
mkdir -p "`dirname "$f"`"
cat <<EOF >"$f"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Kernel Cache</key>
	<string>/.IABootFiles/$prelinkedKernelB</string>
	<key>Kernel Flags</key>
	<string>container-dmg=file:///$inputAppU/Contents/SharedSupport/InstallESD.dmg root-dmg=file:///BaseSystem.dmg</string>
</dict>
</plist>
EOF

f="$outputMnt"/.IAPhysicalMedia
mkdir -p "`dirname "$f"`"
cat <<EOF >"$f"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AppName</key>
	<string>$inputAppB</string>
</dict>
</plist>
EOF

#
# Hardlink some files.
#

hardlink() {
   mkdir -p "`dirname "$outputMnt"/"$2"`"
   ln "$outputMnt"/"$1" "$outputMnt"/"$2"
}

hardlink System/Library/CoreServices/boot.efi \
   usr/standalone/i386/boot.efi
hardlink System/Library/CoreServices/boot.efi \
   .IABootFiles/boot.efi
hardlink System/Library/Caches/com.apple.kext.caches/Startup/"$prelinkedKernelB" \
   .IABootFiles/"$prelinkedKernelB"
hardlink System/Library/CoreServices/PlatformSupport.plist \
   .IABootFiles/PlatformSupport.plist
hardlink Library/Preferences/SystemConfiguration/com.apple.Boot.plist \
   .IABootFiles/com.apple.Boot.plist
# The target path should probably be .IABootFiles/SystemVersion.plist, but let
# us be bug-compatible with Apple :)
hardlink System/Library/CoreServices/SystemVersion.plist \
   .IABootFilesSystemVersion.plist

#
# Copy the bulky installer .app bundle.
#

cp -a "$inputApp" "$outputMnt"

# Bless the volume.
/usr/sbin/bless \
   -folder "$outputMnt"/.IABootFiles \
   -bootefi "$outputMnt"/.IABootFiles/boot.efi \
   -options 'config="\.IABootFiles\com.apple.Boot"' \
   -label "$volName"

# Delete unnecessary stuff that might have been created by Finder.
chmod u+r "$outputMnt"/.Trashes
rm -rf "$outputMnt"/.{DS_Store,Spotlight-V100,Trashes,fseventsd}

# Synchronize "$outputDmg".
hdiutil detach "$outputMnt"

# Create the virtual disk descriptor.
cat <<EOF >"$outputVmdk"
# Disk DescriptorFile
version=1
encoding="UTF-8"
CID=fffffffe
parentCID=ffffffff
isNativeSnapshot="no"
createType="monolithicFlat"

# Extent description
RW $outputDmgSize FLAT "`basename "$outputDmg"`" 0

# The Disk Data Base 
#DDB

ddb.adapterType = "lsilogic"
#ddb.geometry.cylinders is not used by Mac OS.
#ddb.geometry.heads is not used by Mac OS.
#ddb.geometry.sectors is not used by Mac OS.
#ddb.longContentID will be generated on the first write to the file.
#ddb.uuid is not used by Mac OS.
ddb.virtualHWVersion = "6"
EOF

# Cleanup on success.
trap ERR; cleanup
