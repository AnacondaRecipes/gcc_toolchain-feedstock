#!/bin/bash

# prevent to set variables more then once

if [ -z "${CFG_TARGET}" ]; then

set -e

# we can't use conda's HOST compiler ... see recipe
# so we pick system-compiler instead
# if [ -z "${HOST}" ]; then
   HOST=$(gcc -dumpmachine)
# fi

nuke_dot_in_path() {
    local new
    local p
    local IFS=:
    for p in $PATH; do
        if [ -n "${p}" -a -z "${p%%/*}" ]; then
            new="${new}${new:+:}${p}"
        fi
    done
    PATH="${new}"
}

export WDIR=$PWD

if [ -z "${CFG_ARCH}" ]; then
    export CFG_ARCH="x86"
    export CFG_GLIBC_VER="2.17.0"
fi

unset ARCH_CFLAG
unset ARCH_LDFLAG

case "${CFG_ARCH}" in
    arm*)
        CFG_TARGET="aarch64-conda-linux-gnu"
        ARCH_CFLAG="-mlittle-endian"
        ARCH_LDFLAG="-Wl,-EL"
        ;;
    s390*)
        CFG_TARGET="s390x-conda-linux-gnu"
        ;;
    powerpc*)
        CFG_TARGET="powerpc64le-conda-linux-gnu"
        ARCH_CFLAG="-mlittle-endian"
        ARCH_LDFLAG="-Wl,-EL"
        ;;
    x86*)
        CFG_TARGET="x86_64-conda-linux-gnu"
        ;;
esac

export CFG_TARGET
export ARCH_CFLAG
export ARCH_LDFLAG

export LC_ALL=C
export LANG=C

# make sure path does not contain current dir '.'
nuke_dot_in_path

unset GREP_OPTIONS
export CONFIG_SITE=

mkdir -p "${WDIR}/build"
mkdir -p "${WDIR}/build/tools/bin"
export PATH="${WDIR}/build/tools/bin:${PATH}"

unset MAKEFLAGS
export SHELL="/bin/bash"

echo "Preparing working directories ..."

export ORG_HOST="${HOST}"

# poison name for enforcing cross-build
export HOST="${HOST/-/-build_}"

export PATH="${WDIR}/gcc_built/bin:${WDIR}/buildtools/bin:${PATH}"

CLANG_CFLAGS=
OSX_CFLAGS=
OSX_LDFLAGS=
if ${HOST}-gcc --version 2>&1 | grep clang; then
    CLANG_CFLAGS=" -Qunused-arguments"
fi
case "${HOST}" in
    *darwin*)
        OSX_CLFAGS=" -fno-common"
        OSX_LDFLAGS=" -framework CoreFoundation"
        ;;
esac

export HOST_CFLAG="-O2 -g -I${WDIR}/buildtools/include ${CLANG_CFLAGS} ${OSX_CFLAGS}"
export HOST_LDFLAG="-L${WDIR}/buildtools/lib ${OSX_LDFLAGS}"

# the prefix flags ..
export TARGET_LDFLAG="-Wl,-rpath,${WDIR}/gcc_built/lib -Wl,-rpath-link,${WDIR}/gcc_built/lib -L${WDIR}/gcc_built/lib"

for d in CFLAGS LDFLAGS CPPFLAGS CXXFLAGS; do
    eval export ${d}=
    eval export DEBUG_${d}=
    eval export ${d}_USED=
    eval export DEBUG_${d}_USED=
done


for d in ADDR2LINE AR AS CC CPP CXX CXXFILT ELFEDIT GCC GCC_AR GCC_NM GCC_RANLIB \
         GPROF GXX LD LD_GOLD NM RANLIB READELF SIZE STRINGS STRIP \
         CMAKE_PREFIX_PATH CMAKE_ARGS OBJCOPY OBJDUMP \
         host_alias build_aliasa \
         CC_FOR_BUILD CXX_FOR_BUILD LD_FOR_BUILD CPP_FOR_BUILD; do
    eval export ${d}=
    eval unset ${d}
done

export BUILD=
export HOST=$HOST

fi
