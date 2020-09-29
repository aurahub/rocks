#!/bin/bash

# garantee CMAKE_RPOJECT_DIR exists 
[[ -z "${CMAKE_RPOJECT_DIR}" ]] && export CMAKE_RPOJECT_DIR=/project

# garantee CMAKE_BINARY_DIR exists 
[[ -z "${CMAKE_BINARY_DIR}" ]] && export CMAKE_BINARY_DIR=/project

# garantee CMAKE_BUILD_DIR exists 
[[ -z "${CMAKE_BUILD_DIR}" ]] && export CMAKE_BUILD_DIR=/build

# customized CMAKE args
[[ -z "${CMAKE_EXTRA_ARGS}" ]] && export CMAKE_EXTRA_ARGS="-DCMAKE_BUILD_TYPE=RELWITHDEBINFO"

# customized MAKE args
[[ -z "${CMAKE_MAKE_ARGS}" ]] && export CMAKE_MAKE_ARGS=-j`cat /proc/cpuinfo | grep processor | wc -l`

# customized extra command
[[ -z "${CMAKE_EXTRA_CMD}" ]] && export CMAKE_EXTRA_CMD='rm -rf /build'

# clear build directory
rm -rf ${CMAKE_BUILD_DIR} && mkdir -p ${CMAKE_BUILD_DIR} && cd ${CMAKE_BUILD_DIR}

# cmake
cmake -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
    -DCMAKE_COLOR_MAKEFILE=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DEXECUTABLE_OUTPUT_PATH=${CMAKE_BINARY_DIR} -DLIBRARY_OUTPUT_PATH=${CMAKE_BINARY_DIR} \
    -G "Unix Makefiles" ${CMAKE_EXTRA_ARGS} ${CMAKE_RPOJECT_DIR}

# make 
make ${CMAKE_MAKE_ARGS} && ${CMAKE_EXTRA_CMD}
