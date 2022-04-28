#!/bin/bash

set -e

. ${RECIPE_DIR}/build_scripts/build_env.sh

rm -rf "${WDIR}/build/ltrace-target"
mkdir -p "${WDIR}/build/ltrace-target"
pushd "${WDIR}/build/ltrace-target"
    cp -r "${WDIR}"/ltrace/* .

    CONFIG_SHELL="/bin/bash"   \
    LDFLAGS="${TARGET_LDFLAG}" \
    bash ./configure           \
        --build=${HOST}        \
        --host=${CFG_TARGET}   \
        --prefix=/usr          \
        --with-gnu-ld

    echo "Building ltrace ..."
    make

    echo "Installing ltrace ..."
    make DESTDIR="${WDIR}/gcc_built/${CFG_TARGET}/debug-root" install

popd

