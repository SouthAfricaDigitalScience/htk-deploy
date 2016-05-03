#!/bin/bash -e
# Check build file for HTK
. /etc/profile.d/modules.sh
module load ci
# no checks yet - this should include the demo bits, but it looks like the data is missing.
# TODO
echo $?

# Runing the tutorial at http://www1.icsi.berkeley.edu/Speech/docs/HTKBook
echo "Creating a small word network from sample grammar"
cd ${WORKSPACE}/htk/HTKTools
./HParse ../../gram wdnet
# TODO

# Put stuff in ${SOFT_DIR}
echo "Installing to ${SOFT_DIR}"
# Build 30 died with mkdir: cannot create directory ‘/apprepo/generic/u1404/x86_64/htk/3.4.1/bin’: No such file or directory
# so, apparently, we need to make this dir ourselves - smh
mkdir -vp ${SOFT_DIR}
cd ${WORKSPACE}/htk
make install
echo "Installing HDecode"
make install-hdecode

# The libs are not put anywhere - not sure if this is a problem.
cd ${WORKSPACE}
echo "making modules"
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       HTK_VERSION       $VERSION
setenv       HTK_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(HTK_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(HTK_DIR)/lib

MODULE_FILE
) > modules/$VERSION

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/$VERSION ${LIBRARIES_MODULES}/${NAME}
