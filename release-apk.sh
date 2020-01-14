#!/bin/bash
cd $(dirname $0)
unset GIT_WORK_TREE
unset GIT_DIR
ver=$(($(date +%s%N)/1000000))
flutter build apk --release
cp build/app/outputs/apk/release/app-release.apk ~/upload/