#!/bin/bash

set -ex

# debugging ...
if [ -z "${RECIPE_DIR}" ]; then
    RECIPE_DIR=$PWD
fi

if [[ ${target_platform} =~ osx-.* ]]; then
  if [[ ! -f ${BUILD_PREFIX}/bin/llvm-objcopy ]]; then
    echo "no llvm-objcopy"
    exit 1
  fi
  ln -s ${BUILD_PREFIX}/bin/llvm-objcopy ${BUILD_PREFIX}/bin/x86_64-apple-darwin19.6.0-objcopy
  chmod +x ${BUILD_PREFIX}/bin/x86_64-apple-darwin19.6.0-objcopy
  ln -s ${BUILD_PREFIX}/bin/llvm-objcopy ${BUILD_PREFIX}/bin/objcopy
  chmod +x ${BUILD_PREFIX}/bin/objcopy
  unset CC CXX
fi

if [[ $(uname) == Linux ]]; then
  ulimit -s 32768 || true
fi

export CFG_GLIBC_VER="2.17.0"

case "${target_platform}" in
  *linux-64*|*osx-64*) CFG_ARCH="x86";;
  *aarch64*|*arm64*) CFG_ARCH="arm";;
  *ppc64le*) CFG_ARCH="powerpc";;
  *s390x*) CFG_ARCH="s390";;
  *)
      echo "unsupported target architecture ${target_platform}"
      exit 1
      ;;
esac

export CFG_ARCH

${RECIPE_DIR}/build_scripts/build.sh

# pushd ./build/gcc-final
# make -k check || true
# popd

exit 0
