#!/bin/bash
cd $(dirname $0)
unset GIT_WORK_TREE
unset GIT_DIR
ver=$(($(date +%s%N)/1000000))
flutter build web --release #--dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=true #--dart-define=FLUTTER_WEB_USE_SKIA=true
cp web/manifest.json build/web
cp web/favicon.ico build/web

cat web/index.js | sed "s/«ver»/$ver/g" > build/web/index.js
cat web/frame.html | sed "s/«ver»/$ver/g" > build/web/frame.html

cd build/web
cat index.html | sed "s/«ver»/$ver/g" > index.html.tmp
mv -f index.html.tmp index.html 