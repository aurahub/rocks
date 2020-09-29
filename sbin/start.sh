#!/bin/bash
docker run -e PRO_SPEC_T=dev --name lime -p 10000:10000 -v `pwd`/../src:/project -w /project/Release -it --rm  lizongti/lime:latest ./Server