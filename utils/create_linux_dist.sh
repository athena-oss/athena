#!/usr/bin/env bash

if [ "$(uname -s)" != 'Linux' ]; then
	echo "This script runs only in linux!"
	exit 1

fi

# Validate all build dependencies
declare -a build_deps=("tar" "curl" "dh_make" "dpkg-buildpackage" "dput" "lsb_release" "awk")
for((i=0; i<${#build_deps[@]}; i++))
do
	if ! which "${build_deps[i]}" 1>/dev/null 2>/dev/null; then
		echo "${build_deps[i]} is not installed!"
		exit 1
	fi
done

# Consts
dependencies="bsdmainutils (>=9)"
ppa_name="athena"
standalone=0

# Create empty project folder
if [ -d Debian ] ; then
	rm -rf Debian
fi

mkdir -p Debian/$name
cd Debian/$name

# Getting the files
mkdir -p files/usr/share

if [ -d "$url" ]; then
	cp -R "$url" "files/usr/share"
elif [[ "$url" =~ "http"* ]] || [[ "$url" =~ "git@"* ]]; then
	cd files/usr/share
	mkdir $name
	curl -sL "$url" | tar xz -C $name --strip-components=1
	if [ ${PIPESTATUS[0]} -ne 0 ]; then
		echo "Problem occurred fetching url '$url'"
		exit 1
	fi
	chmod -R +w $name
	cd -
else
	echo "URL is neither a directory or an url that starts with 'git@' or 'http'."
	exit 1
fi

# When building the athena package
if [ "$name" = "athena" ]; then
	mkdir -p files/usr/bin
	touch "files/usr/share/${name}/plugins/base/athena.lock"
	ln -s "../share/${name}/$name" "files/usr/bin/$name"
elif [[ "$name" =~ athena-plugin-* ]]; then
	# When building the plugins package
	mkdir -p "files/usr/share/athena/plugins"
	ln -s "../../${name}" "files/usr/share/athena/plugins/${name//athena-plugin-/}"
	dependencies="${dependencies}, athena"
else
	standalone=1
	mkdir -p files/usr/bin
	ln -s "../share/${name}/$name" "files/usr/bin/$name"
fi

# Create debian/ folder with example files (.ex)
cd ..
DEBFULLNAME="$maintainer" dh_make \
	--yes \
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

if [ $standalone -eq 0 ]; then
	# Make sure the folder is writeable for athena.lock
	cat >debian/postinst <<EOF
	#!/bin/sh
	chmod 777 /usr/share/${name}
EOF

	# Make sure all the user generated files are removed before uninstall
	cat >debian/prerm <<EOF
	#!/bin/sh
	user=\$(logname)
	find /usr/share/${name} -group \$user -exec rm -rf {} \;

	if [ -d "/usr/share/${name}/vendor" ]; then
		rm -rf "/usr/share/${name}/vendor"
	fi
EOF
fi

# Select files to be copied
echo "$name/files/usr/* usr" > debian/install

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

######## START Convert CHANGELOG.md to debian/changelog
# Update the distro
distro_name=$(lsb_release -a 2>/dev/null | grep Codename | awk '{ print $2}')
sed -i "s/unstable;/${distro_name};/" debian/changelog
cat debian/changelog | grep ${distro_name} > debian/changelog.tmp
echo "" >> debian/changelog.tmp

# Update changelog
changelog_file="${name}/files/usr/share/${name}/CHANGELOG.md"
cat "$changelog_file" | sed "s/- /   /g" | sed "s/^## /  /g" | sed "s/### /   /g" >> debian/changelog.tmp
echo "" >> debian/changelog.tmp
cat debian/changelog | grep $email >> debian/changelog.tmp

mv debian/changelog.tmp debian/changelog
######## END Convert CHANGELOG.md to debian/changelog

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
	dput ppa:athena-oss/$ppa_name ${project}_${arch}.changes
fi
