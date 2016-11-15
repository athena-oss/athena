#!/usr/bin/env bash

function retrieve_from_url()
{
	cd $3/usr/local/lib
	curl -sL "$4" | \
	tar xz && [ ${PIPESTATUS[0]} -eq 0 ] && \
	cd - && \
	ln -s "../lib/${1}-${2}/$1" "$3/usr/local/bin/$1"
}

if [ $# -lt 2 ]; then
	echo "usage: $0 <version> <url|source_directory>"
	exit 1
fi

version=$1
url=$2
name="athena"
project="${name}_${version}"
description="An automation platform with a plugin architecture that allows you to easily create and share services"

mkdir -p $project/usr/local/lib
mkdir -p $project/usr/local/bin
mkdir -p $project/DEBIAN

cat >$project/DEBIAN/control <<EOF
Package: $name
Version: $version
Section: base
Priority: optional
Architecture: i386
Maintainer: Rafael Pinto <santospinto.rafael@gmail.com>
Description:
 $description
EOF

if [ -d "$url" ]; then
	cp -R "$url" "$project/usr/local/lib/"
	ln -s "../lib/$name/$name" "$project/usr/local/bin/$name"
elif [[ "$url" =~ "http"* ]] || [[ "$url" =~ "git@"* ]]; then
	retrieve_from_url "$name" "$version" "$project" "$url"
else
	echo "URL is neither a directory or an url that starts with 'git@' or 'http'."
	exit 1
fi
if [ $? -eq 0 ]; then
	dpkg-deb --build $project
	exit $?
fi
echo "Failed to create debian package!"
exit 1
