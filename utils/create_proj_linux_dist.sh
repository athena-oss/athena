#!/usr/bin/env bash

if [ "$(uname -s)" != 'Linux' ]; then
	echo "This script runs only in linux!"
	exit 1

fi

# Default arch type is source when pushing to ppa
if [ $# -lt 6 ]; then
    echo "usage: $0 <name> <version> <email> \"<maintainer>\" \"<small_description>\" \"<description>\" [--arch=[amd64|i386]] [--push]"
    exit 1
fi

# Variables
name="$1"
version=$2
url="https://github.com/athena-oss/$1/archive/v${version}.tar.gz"
email=$3
maintainer="$4"
small_description="$5"
description="$6"
homepage="https://github.com/athena-oss/$1"
project="${name}_${version}"

source ./create_linux_dist.sh
