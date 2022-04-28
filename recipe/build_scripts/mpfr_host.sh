#!/bin/bash

set -e

. ${RECIPE_DIR}/build_scripts/build_env.sh

EXTRA_CONFIG="--enable-thread-safe"
case "${HOST}" in
    *darwin*) EXTRA_CONFIG="--disable-thread-safe";;
esac

rm -rf "${WDIR}/build/mpfr-host"
mkdir "${WDIR}/build/mpfr-host"
pushd "${WDIR}/build/mpfr-host"

    CC="${HOST}-gcc"                    \
    CFLAGS="-pipe ${HOST_CFLAG}"        \
    LDFLAGS="${HOST_LDFLAG}"            \
    bash "${WDIR}/mpfr/configure"       \
        --build=${HOST}                 \
        --host=${HOST}                  \
        --prefix="${WDIR}/buildtools"   \
        --with-gmp="${WDIR}/buildtools" \
        --disable-shared                \
        --enable-static                 \
        ${EXTRA_CONFIG}

    echo "Building mpfr ..."
    make

    echo "Checking mpfr ..."
    make -s check

    echo "Installing mpfr ..."
    make install

popd

# clean up ...
rm -rf "${WDIR}/build/mpfr-host"

