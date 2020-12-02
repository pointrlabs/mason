#!/usr/bin/env bash

MASON_NAME=aws-sdk-cpp
MASON_VERSION=20201201
GITSHA=236f75622b400bf444f7302a6222bfb353bac766
MASON_LIB_FILE=lib/libaws-app-sdk-core.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/aws/aws-sdk-cpp/archive/${GITSHA}.tar.gz \
        5eb7ac8f059e5f92950a742ef50b6b0f6c993938

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GITSHA}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.7.2
    CMAKE_VERSION=3.15.2
    LLVM_VERSION=10.0.0
    ${MASON_DIR}/mason install clang++ ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix clang++ ${LLVM_VERSION})
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
}

function mason_compile {
    mkdir -p build
    cd build

    ${MASON_CMAKE}/bin/cmake ../ \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}" \
        -DCMAKE_INSTALL_MESSAGE="NEVER" \
        -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
        -DCMAKE_C_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
        -DCMAKE_CXX_COMPILER="${MASON_LLVM}/bin/clang++" \
        -DCMAKE_C_COMPILER="${MASON_LLVM}/bin/clang" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_TESTING=OFF

    VERBOSE=1 make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    echo "-isystem ${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -laws-cpp-sdk-core"
}

function mason_static_libs {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
