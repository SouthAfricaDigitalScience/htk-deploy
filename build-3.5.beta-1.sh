#!/bin/bash -e
# This is the build file for HTK
# The user name and password for the download of the code are kept in environment variables on the build server.
# You can't have them, Curious George :-p

. /etc/profile.d/modules.sh

module add ci
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
DECODE_SOURCE_FILE=HDecode-${VERSION}.tar.gz

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
#  Download HTK the source file
echo "Checking ${NAME} source"
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget --user ${LICENSE_USER} --password  ${LICENSE_PASS} http://htk.eng.cam.ac.uk/ftp/software/HTK-${VERSION}.tar.gz -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

echo "Checking HDecode source "
if [ ! -e ${SRC_DIR}/${DECODE_SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${DECODE_SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${DECODE_SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget --user ${LICENSE_USER} --password  ${LICENSE_PASS} http://htk.eng.cam.ac.uk/ftp/software/hdecode/${DECODE_SOURCE_FILE} -O ${SRC_DIR}/${DECODE_SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${DECODE_SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${DECODE_SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${DECODE_SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${DECODE_SOURCE_FILE}
fi

echo "unpacking HTk"
# This goes into ${WORKSPACE}/htk
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
tar xzf ${SRC_DIR}/${DECODE_SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
cd ${WORKSPACE}/htk

# now, we build it all :)
HTK_BITS=(HTKLib HLMLib HLMTools HTKTools)
for bit in ${HTK_BITS[@]} ; do
  cd $bit
  echo "Building ${bit}"
  make -f MakefileCPU install
  cd ${WORKSPACE}/htk
done

echo "Building HDecode"

cd ${WORKSPACE}/htk/HTKLVRec
make -f MakefileCPU
make -f MakefileCPU install

cd ${WORKSPACE}/htk

echo "Done - we have libs in"

find . -name  "lib"
echo "Containing "
find  . -name "lib" -exec ls {} \;

echo "We have in bin :"
ls bin.cpu
