#!/bin/bash

#########################################

export NDK=~/Library/Android/sdk/ndk/23.1.7779620 #这里配置先你的 NDK 路径
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64

function build_android
{

./configure \
--prefix=$PREFIX \
--enable-neon  \
--enable-hwaccels  \
--disable-gpl   \
--disable-postproc \
--disable-debug \
--enable-small \
--enable-jni \
--enable-mediacodec \
--enable-decoder=h264_mediacodec \
--enable-static \
--enable-shared \
--disable-doc \
--enable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--enable-avdevice \
--disable-doc \
--disable-symver \
--cross-prefix=$CROSS_PREFIX \
--cross-prefix=${TOOLCHAIN}/bin/aarch64-linux-android$API- \
--target-os=android \
--arch=$ARCH \
--cpu=$CPU \
--cc=$CC \
--cxx=$CXX \
--nm=$NM \
--ar=$AR \
--ranlib=$RNADLIB \
--strip=$STRIP \
--enable-cross-compile \
--sysroot=$SYSROOT \
--extra-cflags="-Os -fpic $OPTIMIZE_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS"

make clean
make -j4
make install

echo "============================ build android arm64-v8a success =========================="

}

rm -rf build/android
mkdir build/android

pushd ../FFmpeg

#arm64-v8a
ARCH=arm64
CPU=armv8-a
API=21
CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++
NM=$TOOLCHAIN/bin/llvm-nm
AR=$TOOLCHAIN/bin/llvm-ar
RNADLIB=${TOOLCHAIN}/bin/llvm-ranlib
STRIP=${TOOLCHAIN}/bin/llvm-strip
SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android$API-
PREFIX=$(pwd)/android/$CPU
OPTIMIZE_CFLAGS="-march=$CPU"

build_android

cp -rf android/* ../FFmpeg-Build-Scripts/build/android

popd
