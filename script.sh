#!/usr/bin/env bash

MASON_NAME=geojsonvt
MASON_VERSION=3.0.0
MASON_LIB_FILE=lib/libgeojsonvt.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geojson-vt-cpp/archive/v${MASON_VERSION}.tar.gz \
        1cda3b57410b4cc6875ef044564790012b9aca67

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geojson-vt-cpp-${MASON_VERSION}
}

function mason_compile {
    # setup mason
    rm -rf .mason
    ln -s ${MASON_DIR:-~/.mason} .mason

    # build
    INSTALL_PREFIX=${MASON_PREFIX} ./configure
    CXXFLAGS="-fPIC ${CFLAGS:-} ${CXXFLAGS:-}" make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/lib/libgeojsonvt.a
}

mason_run "$@"
