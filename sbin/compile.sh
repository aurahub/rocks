#!/bin/bash
docker run -v `pwd`/../src:/project -e CMAKE_BINARY_DIR=/project/Release --rm lizongti/lime:cmake