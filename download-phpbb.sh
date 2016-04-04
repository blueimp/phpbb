#!/bin/sh

#
# Downloads and extracts the latest stable phpBB version.
# Extracts the downloaded package in the given or the current directory.
#
# Requires curl, jq and tar with bzip2 support.
#
# Usage: ./get-phpbb.sh [dir]
#

# Exit immediately if a command exits with a non-zero status:
set -e

# URL to the official list of phpBB versions:
VERSIONS_URL=https://version.phpbb.com/phpbb/versions.json
# Base URL for the release downloads:
RELEASE_BASE_URL=https://www.phpbb.com/files/release/

# Retrieve the latest stable version:
VERSION=$(curl -sL $VERSIONS_URL |
  jq -r '.stable["'${BASE_VERSION:-3.1}'"].current')

# Download and extract the phpBB package into the given directory:
curl -L $RELEASE_BASE_URL/phpBB-$VERSION.tar.bz2 | tar xvj -C "${1:-$PWD}"
