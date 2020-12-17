#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -e

if [ "$DEVKITPRO" = "" ]
then
  echo "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>/devkitpro"
fi

export SWITCH_UTILS=$DIR/third_party/switch-utils
(
cd $SWITCH_UTILS
make
)

(
cd third_party/mojoAL
if [ ! -e mojoal.o ]
then
$DEVKITPRO/devkitA64/bin/aarch64-none-elf-gcc -march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIE -g -Wall -O2 -ffunction-sections mojoal.c -I$DEVKITPRO/portlibs/switch/include/SDL2 -c -o mojoal.o
fi
#$DEVKITPRO/devkitA64/bin/aarch64-none-elf-ar rcs libmojoal.a mojoal.o
)

mkdir -p build
cd build


cmake -DOPENAL_LIBRARY=$DIR/third_party/mojoAL/mojoal.o \
      -DOPENAL_INCLUDE_DIR=$DIR/third_party/mojoAL/AL \
      -DCMAKE_TOOLCHAIN_FILE=${SWITCH_UTILS}/cmake/Toolchain-cross-Switch.cmake  \
      ..
make VERBOSE=1
#PATH=$DEVKITPRO/devkitA64/aarch64-none-elf/bin:$PATH make
#-DENABLE_FLUIDSYNTH=OFF -DSDL2_MIXER_LIBRARY=$DEVKITPRO/portlibs/switch/lib/libSDL2_mixer.a -DSDL2_DIR=/opt/devkitpro/portlibs/switch/lib/cmake/SDL2 -DCMAKE_TOOLCHAIN_FILE=${SWITCH_UTILS}/cmake/Toolchain-cross-Switch.cmake -DENABLE_SDL2=ON -DENABLE_OPENGL=OFF -DOPENGL_EGL_INCLUDE_DIR=$DEVKITPRO/portlibs/switch/include -DOPENGL_INCLUDE_DIR=$DEVKITPRO/portlibs/switch/include -DOPENGL_EGL_LIBRARY=$DEVKITPRO/portlibs/switch/lib/libEGL.a  ..

