#!/bin/bash

eval `$ANDROID_SDK_ROOT/tools/emulator64-arm -avd myandroid22 -no-skin -no-audio -no-window`

sleep 1s

$ANDROID_SDK_ROOT/platform-tools/adb shell ps

echo "=== Emulator started ==="
