#!/usr/bin/env bash

if [ "$(uname -s)" != 'Linux' ]; then
	echo "This script runs only in linux!"
	exit 1

fi

# Default arch type is source when pushing to ppa
if [ $# -lt 8 ]; then                                                                                                                                                                                                                     
    echo "usage: $0 <name> <version> <url|source_directory> <email> \"<maintainer>\" \"<small_description>\" \"<description>\" \"<homepage>\" [--arch=[amd64|i386]] [--push]"
    exit 1
fi

# Variables
name=$1
version=$2
url=$3
email=$4
maintainer="$5"
small_description="$6"
description="$7"
homepage="$8"
project="${name}_${version}"

source ./create_linux_dist.sh
