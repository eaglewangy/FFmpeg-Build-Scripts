#!/bin/bash

export NDK=~/Library/Android/sdk/ndk/23.1.7779620/
export TOOLCHAIN=${NDK}/toolchains/llvm/prebuilt/darwin-x86_64
export SYSROOT=${TOOLCHAIN}/sysroot
export PREFIX=./android/arm64

API=21

CC=${TOOLCHAIN}/bin/aarch64-linux-android$API-clang

# --cross-prefix=${TOOLCHAIN}/bin/llvm- \
# --disable-neon \
# --disable-static \
# --enable-shared \
function build_ffmpeg
{
  ./configure \
  --arch=aarch64 \
  --cpu=armv8-a \
  --prefix=$PREFIX \
  --cross-prefix=${TOOLCHAIN}/bin/aarch64-linux-android$API- \
  --cc=${CC} \
  --cxx=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++ \
  --ar=${TOOLCHAIN}/bin/llvm-ar \
  --ranlib=${TOOLCHAIN}/bin/llvm-ranlib \
  --strip=${TOOLCHAIN}/bin/llvm-strip \
  --nm=${TOOLCHAIN}/bin/llvm-nm \
  --sysroot=$SYSROOT \
  --target-os=linux \
  --enable-cross-compile \
  --disable-doc \
  --enable-pic \
  --enable-neon \
  --enable-yasm \
  --disable-gpl --disable-nonfree --enable-runtime-cpudetect --disable-gray --disable-swscale-alpha --disable-programs --disable-ffmpeg --disable-ffplay --disable-ffprobe --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages --disable-avdevice --enable-avcodec --enable-avformat --enable-avutil --enable-swresample --enable-swscale --disable-postproc --enable-avfilter --enable-network --disable-d3d11va --disable-dxva2 --disable-vaapi --disable-vdpau --disable-videotoolbox --disable-encoders --enable-encoder=png --disable-decoders --enable-decoder=aac --enable-decoder=aac_latm --enable-decoder=flv --enable-decoder=h264 --enable-decoder='mp3*' --enable-decoder=vp6f --enable-decoder=flac --enable-decoder=hevc --enable-decoder=vp8 --enable-decoder=vp9 --disable-hwaccels --disable-muxers --enable-muxer=mp4 --disable-demuxers --enable-demuxer=aac --enable-demuxer=concat --enable-demuxer=data --enable-demuxer=flv --enable-demuxer=hls --enable-demuxer=live_flv --enable-demuxer=mov --enable-demuxer=mp3 --enable-demuxer=mpegps --enable-demuxer=mpegts --enable-demuxer=mpegvideo --enable-demuxer=flac --enable-demuxer=hevc --enable-demuxer=webm_dash_manifest --disable-parsers --enable-parser=aac --enable-parser=aac_latm --enable-parser=h264 --enable-parser=flac --enable-parser=hevc --enable-bsfs --disable-bsf=chomp --disable-bsf=dca_core --disable-bsf=dump_extradata --disable-bsf=hevc_mp4toannexb --disable-bsf=imx_dump_header --disable-bsf=mjpeg2jpeg --disable-bsf=mjpega_dump_header --disable-bsf=mov2textsub --disable-bsf=mp3_header_decompress --disable-bsf=mpeg4_unpack_bframes --disable-bsf=noise --disable-bsf=remove_extradata --disable-bsf=text2movsub --disable-bsf=vp9_superframe --enable-protocols --enable-protocol=async --disable-protocol=bluray --disable-protocol=concat --disable-protocol=crypto --disable-protocol=ffrtmpcrypt --enable-protocol=ffrtmphttp --disable-protocol=gopher --disable-protocol=icecast --disable-protocol='librtmp*' --disable-protocol=libssh --disable-protocol=md5 --disable-protocol=mmsh --disable-protocol=mmst --disable-protocol='rtmp*' --enable-protocol=rtmp --enable-protocol=rtmpt --disable-protocol=rtp --disable-protocol=sctp --disable-protocol=srtp --disable-protocol=subfile --disable-protocol=unix --disable-devices --disable-filters --disable-iconv --disable-audiotoolbox --disable-videotoolbox --disable-linux-perf --disable-bzlib \
  --enable-asm --enable-inline-asm --enable-optimizations --enable-small \
  --extra-cflags="-I${SYSROOT}/usr/include/aarch64-linux-android \
                 -isysroot ${SYSROOT} \
                 -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated -mfloat-abi=softfp -mfpu=neon \
                 -marm -march=armv8-a \
                 -O3 -Wall -pipe -std=c99 \
                 -fPIC \
                 -ffast-math \
                 -fstrict-aliasing -Werror=strict-aliasing \
                 -Wno-psabi -Wa,--noexecstack \
                 -Wl,-Bsymbolic  \
                 -DANDROID -DNDEBUG" \
  --extra-cxxflags="-Wl,-Bsymbolic -O3 -fPIC -Wall" \
  --extra-ldflags=""
}

FF_MODULE_DIRS="compat libavcodec libavfilter libavformat libavutil libswresample libswscale"
FF_ASSEMBLER_SUB_DIRS="aarch64 neon"

function build_so
{
    FF_C_OBJ_FILES=
    FF_ASM_OBJ_FILES=
    for MODULE_DIR in $FF_MODULE_DIRS
    do
        C_OBJ_FILES="$MODULE_DIR/*.o"
        if ls $C_OBJ_FILES 1> /dev/null 2>&1; then
            echo "link $MODULE_DIR/*.o"
            FF_C_OBJ_FILES="$FF_C_OBJ_FILES $C_OBJ_FILES"
        fi

        for ASM_SUB_DIR in $FF_ASSEMBLER_SUB_DIRS
        do
            ASM_OBJ_FILES="$MODULE_DIR/$ASM_SUB_DIR/*.o"
            if ls $ASM_OBJ_FILES 1> /dev/null 2>&1; then
                echo "link $MODULE_DIR/$ASM_SUB_DIR/*.o"
                FF_ASM_OBJ_FILES="$FF_ASM_OBJ_FILES $ASM_OBJ_FILES"
            fi
        done
    done

    echo "FF_C_OBJ_FILES: $FF_C_OBJ_FILES"
    echo "FF_ASM_OBJ_FILES: $FF_ASM_OBJ_FILES"
    echo "FF_DEP_LIBS: $FF_DEP_LIBS"
    echo "FF_EXTRA_LDFLAGS: $FF_EXTRA_LDFLAGS"
    echo "$CC -lm -lz -shared -Bsymbolic --sysroot=$SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FF_EXTRA_LDFLAGS \
        -Wl,-z,notext,-soname,libijkffmpeg.so \
        $FF_C_OBJ_FILES \
        $FF_ASM_OBJ_FILES \
        -o $PREFIX/libijkffmpeg.so"
    $CC -lm -lz -shared -Bsymbolic --sysroot=$SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FF_EXTRA_LDFLAGS \
        -Wl,-z,notext,-soname,libijkffmpeg.so \
        $FF_C_OBJ_FILES \
        $FF_ASM_OBJ_FILES \
        -o $PREFIX/libijkffmpeg.so
}

rm -rf build/android
pushd ../FFmpeg

rm -rf $PREFIX
rm -f config.h

build_ffmpeg

make clean
make -j4
make install

echo "Finish compile ffmpeg"
build_so

cp -rf $PREFIX/../../android ../FFmpeg-Build-Scripts/build
popd