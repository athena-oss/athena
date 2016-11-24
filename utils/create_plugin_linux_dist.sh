#!/usr/bin/env bash

if [ "$(uname -s)" != 'Linux' ]; then
	echo "This script runs only in linux!"
	exit 1

fi

# Default arch type is source when pushing to ppa
if [ $# -lt 5 ]; then
    echo "usage: $0 <name> <version> <email> \"<maintainer>\" \"<description>\" [--arch=[amd64|i386]] [--push]"
    exit 1
fi

# Variables
name="athena-plugin-$1"
version=$2
url="https://github.com/athena-oss/plugin-$1/archive/v${version}.tar.gz"
email=$3
maintainer="$4"
small_description="Athena $1 Plugin"
description="$5"
homepage="https://github.com/athena-oss/plugin-$1"
project="${name}_${version}"

source ./create_linux_dist.sh
