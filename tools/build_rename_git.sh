#!/bin/bash

#
# This file is part of the Companion project
# Copyright (c) 2018 Bitfocus AS
# Authors: William Viker <william@bitfocus.io>, Håkon Nessjøen <haakon@bitfocus.io>
#
# This program is free software.
# You should have received a copy of the MIT licence as well as the Bitfocus
# Individual Contributor License Agreement for companion along with
# this program.
#
# You can be released from the requirements of the license by purchasing
# a commercial license. Buying such a license is mandatory as soon as you
# develop commercial activities involving the Companion software without
# disclosing the source code of your own applications.
#


function parse_git_dirty() {
	git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo ""
}

# gets the current git branch
function parse_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

# get last commit hash prepended with @ (i.e. @8a323d0)
function parse_git_hash() {
	git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/\1/"
}

function parse_git_count() {
	git log|egrep "^commit"|wc -l|awk '{print $1}'
}

function release() {
	cat package.json |grep \"version\"|cut -f4 -d\"
}

if [[ "$(parse_git_branch)" == "master" ]]; then
	GIT_BRANCH=$(release)-$(parse_git_hash)-$(parse_git_count)
else
	GIT_BRANCH=$(release)-$(parse_git_branch)-$(parse_git_hash)
fi

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
	echo OSX
	mv -vf electron-output/Companion*.zip electron-output/companion-${GIT_BRANCH}-osx.zip
elif [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
	echo LINUX
	mkdir electron-linux-output
	cp electron-output/*.tar.gz electron-linux-output/companion-${GIT_BRANCH}-linux.tar.gz
elif [[ "$TRAVIS_OS_NAME" == "win64" ]]; then
	echo WINDOWS
	mv -f electron-output/*.exe electron-output/companion-${GIT_BRANCH}-win64.exe
elif [[ "$TRAVIS_OS_NAME" == "armv7l" ]]; then
	echo ARM
	mv -f electron-output/*.tar.gz electron-output/companion-${GIT_BRANCH}-armv7l.tar.gz
fi

echo DONE
