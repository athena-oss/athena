#!/usr/bin/env bash

if [ "$(uname -s)" != 'Linux' ]; then
	echo "This script runs only in linux!"
	exit 1

fi

# Default arch type is source when pushing to ppa
if [ $# -lt 4 ]; then
	echo "usage: $0 <version> <url|source_directory> <email> \"<maintainer>\" [--arch=[amd64|i386]] [--push]"
	exit 1
fi

# Validate all build dependencies
declare -a build_deps=("tar" "curl" "dh_make" "dpkg-buildpackage" "dput")
for((i=0; i<${#build_deps[@]}; i++))
do
	if ! which "${build_deps[i]}" 1>/dev/null 2>/dev/null; then
		echo "${build_deps[i]} is not installed!"
		exit 1
	fi
done

# Consts
name="athena"
dependencies="bsdmainutils (>=9)"
homepage="https://github.com/athena-oss/athena"
small_description="An automation platform."
description="An automation platform with a plugin architecture that allows you to easily create and share services"

# Variables
version=$1
url=$2
email=$3
maintainer="$4"
project="${name}_${version}"

# Create empty project folder
if [ -d Debian/$name ] ; then
	rm -rf Debian/$name
fi

mkdir -p Debian/$name
cd Debian/$name

# Getting the files
mkdir -p files/usr/share/lib
mkdir -p files/usr/bin

if [ -d "$url" ]; then
	cp -R "$url" "files/usr/share/lib/"
	location="${name}"
elif [[ "$url" =~ "http"* ]] || [[ "$url" =~ "git@"* ]]; then
	cd files/usr/share/lib
	curl -sL "$url" | tar xz
	if [ ${PIPESTATUS[0]} -ne 0 ]; then
		echo "Problem occurred fetching url '$url'"
		exit 1
	fi
	cd -
	location="${name}-${version}"
else
	echo "URL is neither a directory or an url that starts with 'git@' or 'http'."
	exit 1
fi

touch "files/usr/share/lib/${location}/plugins/base/athena.lock"
ln -s "../share/lib/${location}/$name" "files/usr/bin/$name"

# Create debian/ folder with example files (.ex)
cd ..
DEBFULLNAME="$maintainer" dh_make \
	--copyright apache \
	--native \
	--single \
	--packagename "$project" \
	--email "$email"

# Overriding default control file
cat >debian/control <<EOF
Source: $name
Section: base
Priority: optional
Maintainer: $maintainer <$email>
Build-Depends: debhelper (>=9)
Standards-Version: 3.9.6
Homepage: $homepage

Package: $name
Architecture: any
Depends: $dependencies
Description: $small_description
 $description
EOF

# Getting architecture type
push_to_ppa=0
declare -a opts=()
for((i=1; i<=$#; i++))
do
	case "${!i}" in
		"--arch"*)
			arch=${!i//--arch=/}
			opts+=("-a" "$arch")
			;;
		"--push")
			push_to_ppa=1
			;;
	esac
done

# Defaults
if [ ${#opts[@]} -eq 0 ]; then
	opts+=("-S")
	arch="source"
fi

# Build the .changes and .deb
dpkg-buildpackage "${opts[@]}"

cd ..
# Push to ppa
if [ $push_to_ppa -eq 1 ]; then
	dput ppa:athena-oss/$name ${project}_${arch}.changes
fi
