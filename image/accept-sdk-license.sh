#!/usr/bin/expect -f

set timeout 1800

# spawn update command and let's wait for password question
spawn $env(ADIR)/android-sdk-linux/tools/android update sdk --no-ui --all --filter tools,platform-tools,build-tools-23.0.1,android-22,sys-img-armeabi-v7a-android-22
expect {
  "Do you accept the license '*'*" {
        exp_send "y\r"
        exp_continue
  }
  eof
}
