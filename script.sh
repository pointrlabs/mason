#!/usr/bin/env bash

MASON_NAME=mesa
MASON_VERSION=10.3.3
MASON_LIB_FILE=lib/libGL.so
MASON_PKGCONFIG_FILE=lib/pkgconfig/gl.pc

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        ftp://ftp.freedesktop.org/pub/mesa/10.3.3/MesaLib-10.3.3.tar.gz \
        4e17d9e024fc7870a8d516666a40c346beb27c05

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/Mesa-10.3.3
}

function mason_compile {
    ./autogen.sh \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-shared \
        --with-gallium-drivers=svga,swrast \
        --disable-dri \
        --enable-xlib-glx \
        --enable-glx-tls \
        --with-llvm-prefix=/usr/lib/llvm-3.4 \
        --without-va

    make install
}

function mason_strip_ldflags {
    shift # -L...
    shift # -luv
    echo "$@"
}

function mason_ldflags {
    mason_strip_ldflags $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
