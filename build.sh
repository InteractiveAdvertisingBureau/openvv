#!/bin/bash

export FLEX_HOME=/Applications/Adobe\ Flash\ Builder\ 4.7/sdks/4.5.0
export ANT_HOME=/Applications/Ant
export OVV_LIB=/Users/steve.thorpe/Documents/git/sourcetree/openvv/bin/openvv.swc
export AD_LIB=/Users/steve.thorpe/Documents/git/sourcetree/adunit/src
chmod 777 ./build.sh


# git commit id
git_sha="`git rev-parse HEAD`"
if [ -z $git_sha ]; then  
  echo "Couldn't read git commit id, aborting."  
  exit 1
fi

# are we building against code that's changed since last commit?
git_dirty=`(git diff --shortstat 2> /dev/null | tail -n1) | wc -l`

if [[ $git_dirty -ne 0 ]]; then
  git_sha="${git_sha}-DIRTY"
fi

echo "Building with git_sha=${git_sha}"

# build, passing version to ant, ant will burn this into the code
ant -Dbuild.version="${git_sha}" $@