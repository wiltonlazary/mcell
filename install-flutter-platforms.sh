#!/bin/bash
cd $(dirname $0)
unset GIT_WORK_TREE
unset GIT_DIR
rm -rf .packages build .dart_tool &> /dev/null
flutter channel master
flutter upgrade --force
flutter config --enable-web
flutter pub get
flutter build apk --debug
flutter upgrade