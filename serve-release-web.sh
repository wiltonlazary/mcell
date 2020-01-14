#!/bin/bash
unset GIT_WORK_TREE
unset GIT_DIR
./release-web.sh
cd build/web/
http-server -p 8081 #--ssl