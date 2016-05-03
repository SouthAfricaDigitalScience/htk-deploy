#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
cd ${WORKSPACE}/
echo "All tests have passed, will now build into ${SOFT_DIR}"
mkdir -p ${SOFT_DIR}/bin ${SOFT_DIR}/lib
cp -rvf ${WORKSPACE}/htk/bin.cpu/* ${SOFT_DIR}/bin
LIBDIRS=(HLMLib HTKLib)
for libdir in ${LIBDIRS[@]} ; do
  cp -v ${WORKSPACE}/htk/${libdir}/lib/* ${SOFT_DIR}/lib
done

cd ${WORKSPACE}

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
