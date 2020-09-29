#!/bin/bash
docker run -e PRO_SPEC_T=dev --name lime -p 10022:22 -p 10000:10000 --rm -d lizongti/lime:sshd