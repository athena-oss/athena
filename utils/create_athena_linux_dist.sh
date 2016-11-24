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

# Variables
name="athena"
version=$1
url=$2
email=$3
maintainer="$4"
small_description="An automation platform."
description="An automation platform with a plugin architecture that allows you to easily create and share services."
homepage="https://github.com/athena-oss/athena"
project="${name}_${version}"

source ./create_linux_dist.sh
