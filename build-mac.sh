#!/bin/bash

#########################################

function build_mac
{

./configure \
--prefix=$PREFIX \
--enable-neon  \
--enable-hwaccels  \
--enable-gpl   \
--disable-postproc \
--disable-debug \
--enable-small \
--enable-static \
--enable-indev=avfoundation \
--enable-audiotoolbox \
--enable-videotoolbox \
--disable-doc \
--enable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-doc \
--disable-symver \
--extra-cflags="-Os -fpic" \
--extra-ldflags="$ADDI_LDFLAGS"

make clean
make -j16
make install

echo "============================ Build Mac success =========================="
}

pushd ../FFmpeg

PREFIX=$(pwd)/FFmpeg-Mac/

build_mac

mkdir -p ../FFmpeg-Dig/projects/Mac/FFmpeg-Mac/

cp -rf  FFmpeg-Mac/* ../FFmpeg-Dig/projects/Mac/FFmpeg-Mac/

popd
