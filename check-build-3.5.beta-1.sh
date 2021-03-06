#!/bin/bash -e
# Check build file for HTK
. /etc/profile.d/modules.sh
module add ci
cd ${WORKSPACE}/htk/samples/HTKDemo/
# no checks yet - this should include the demo bits, but it looks like the data is missing.
# TODO
echo $?

# Runing the tutorial at http://www1.icsi.berkeley.edu/Speech/docs/HTKBook
echo "Creating a small word network from sample grammar"
cd ${WORKSPACE}/
htk/bin.cpu/HParse gram wdnet
# TODO

# Put stuff in ${SOFT_DIR}
echo "Installing to ${SOFT_DIR}"
mkdir -p ${SOFT_DIR}/bin ${SOFT_DIR}/lib
# bin.CPU is because we're using the CPU makefiles. We could parametrise this later
cp -rvf ${WORKSPACE}/htk/bin.cpu/* ${SOFT_DIR}/bin
LIBDIRS=(HLMLib HTKLib)
for libdir in ${LIBDIRS[@]} ; do
  cp -v ${WORKSPACE}/htk/${libdir}/lib/* ${SOFT_DIR}/lib
done
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
setenv       HTK_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(HTK_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(HTK_DIR)/lib

MODULE_FILE
) > modules/$VERSION

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/$VERSION ${LIBRARIES_MODULES}/${NAME}
