#!/bin/bash
unset GIT_WORK_TREE
unset GIT_DIR

#flutter run -d chrome
#flutter build apk --release
#flutter build apk --debug
flutter run -d emulator-5554 --pid-file /tmp/flutter.pid