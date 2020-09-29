#!/bin/bash
docker run -e PRO_SPEC_T=dev --name lime -p 10000:10000 -v `pwd`/../src:/project -w /project/Release -d --rm  lizongti/lime:latest ./Server