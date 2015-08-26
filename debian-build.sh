#!/bin/bash -x

set -o errexit
set -o nounset

#
# copied from .travis.yml
#
env_global()
{
        # -- BEGIN Coverity Scan ENV
        # The build command with all of the arguments that you would apply to a manual `cov-build`
        # Usually this is the same as STANDARD_BUILD_COMMAND, exluding the automated test arguments
        COVERITY_SCAN_BUILD_COMMAND="make"
        # Name of the project
        COVERITY_SCAN_PROJECT_NAME="bareos/bareos"
        # Email address for notifications related to this build
        COVERITY_SCAN_NOTIFICATION_EMAIL="coverity@bareos.org"
        # Regular expression selects on which branches to run analysis
        # Be aware of quotas. Do not run on every branch/commit
        COVERITY_SCAN_BRANCH_PATTERN="master"
        # COVERITY_SCAN_TOKEN via "travis encrypt" using the repo's public key
        secure: "EMFCxVpjP2SBZIGqRxwdxcxxdg373w+sXIm109N7ZGMouOFVCeHq4PMBV9m6EyQ6wyb02oa6Re0GfZM9Yvc1vLc+fWpIV7y8kmVLXZhyAhGhLnCKXfirahgJkEIJTqddU/aWroub4oPPkqqNcxNAWYgrwi8jpcBkO50FGxxI9rg="
        COVERITY_SCAN_BUILD_URL="https://scan.coverity.com/scripts/travisci_build_coverity_scan.sh"
        COVERITY_SCAN_BUILD="curl -s $COVERITY_SCAN_BUILD_URL | bash"
        # -- END Coverity Scan ENV
}

env_matrix()
{
#        DB=postgresql
#        DB=mysql
        DB=sqlite3
#        DB=postgresql COVERITY_SCAN=1
}

env()
{
	COVERITY_SCAN=""
#	env_global
	env_matrix
}


before_install()
{
    # install build dependencies
    #   use files instead of shell variables, because travis has some problems supporting variables
    sudo apt-get update
    dpkg-checkbuilddeps 2> /tmp/dpkg-builddeps || true
    sed "s/.*:.*:\s//" /tmp/dpkg-builddeps > /tmp/build_depends
    yes "" | sudo xargs --arg-file /tmp/build_depends apt-get -q --assume-yes install
}

before_script()
{
    # changelog file is required (and normally generated by OBS)
    cp -a platforms/packaging/bareos.changes debian/changelog
    # build Debian packages
    if [ -z "${COVERITY_SCAN}" ]; then fakeroot debian/rules binary; else debian/rules override_dh_auto_configure; eval "$COVERITY_SCAN_BUILD"; fi
    # create Debian package repository
    cd ..
    if [ -z "${COVERITY_SCAN}" ]; then dpkg-scanpackages . /dev/null | gzip > Packages.gz; fi
    if [ -z "${COVERITY_SCAN}" ]; then printf 'deb file:%s /\n' $PWD > /tmp/bareos.list; fi
    if [ -z "${COVERITY_SCAN}" ]; then sudo cp /tmp/bareos.list /etc/apt/sources.list.d/bareos.list; fi
    cd -
    # install Bareos packages
    if [ -z "${COVERITY_SCAN}" ]; then sudo apt-get -qq update; fi
    if [ -z "${COVERITY_SCAN}" ]; then sudo apt-get install -y --force-yes bareos bareos-database-$DB; fi
}

script()
{
    # run test script
    if [ -z "${COVERITY_SCAN}" ]; then sudo -E $PWD/test/all; fi
}

env
before_install
before_script
script
