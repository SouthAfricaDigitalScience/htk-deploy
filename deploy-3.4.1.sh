#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
cd ${WORKSPACE}/htk
echo "All tests have passed, will now clean and reconfigure to build into ${SOFT_DIR}"

make distclean

echo "setting 64bit in CFLAGS"
sed -i  's/-m32/-m64/g' configure
./configure  --prefix=${SOFT_DIR} \
             --disable-x \
             --enable-hdecode

# For some wierd reason, HLMTools' makefile doesn't have 4 tabs at the last target
echo "Fixing HLMTools Makefile"
sed -i 's/        /\t/g' HLMTools/Makefile

echo "Building all standard tools"
make all

echo "Building HDecode"
make hdecode

echo "Installing"
mkdir -vp ${SOFT_DIR}
make install
make install hdecode
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
setenv       HTK_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(HTK_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(HTK_DIR)/lib
MODULE_FILE
) > modules/$VERSION


mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/$VERSION ${LIBRARIES_MODULES}/${NAME}
