#!/bin/bash
set -e

unset LANG #remove? or just install locales...

source /etc/environment
dpkg --add-architecture i386

echo "deb [arch=armhf] http://ports.ubuntu.com/ vivid main universe restricted
deb-src [arch=armhf]  http://ports.ubuntu.com/ vivid main universe restricted

deb [arch=armhf] http://ports.ubuntu.com/ vivid-updates main universe restricted
deb-src [arch=armhf] http://ports.ubuntu.com/ vivid-updates main universe restricted

deb [arch=i386,amd64] http://archive.ubuntu.com/ubuntu vivid main universe restricted
deb-src [arch=i386,amd64] http://archive.ubuntu.com/ubuntu vivid main universe restricted

deb [arch=i386,amd64] http://archive.ubuntu.com/ubuntu vivid-updates main universe restricted
deb-src [arch=i386,amd64] http://archive.ubuntu.com/ubuntu vivid-updates main universe restricted
" > /etc/apt/sources.list

echo 'Debug::pkgProblemResolver "true";' > /etc/apt/apt.conf.d/debug

apt update
apt-get install \
  ant \
  build-essential \
  cmake \
  curl \
  expect \
  openjdk-7-jdk \
  openjdk-7-jre \
  -y

# install required i386 libraries
dpkg --add-architecture i386
apt-get install zlib1g:i386 libgcc1:i386 libc6:i386 -y

# create user 'kdeandroid' and change to it
adduser kdeandroid --gecos "" --disabled-password
su - kdeandroid
echo "kdeandroid   ALL=NOPASSWD:ALL" >> /etc/sudoers

cat << EOF > /home/kdeandroid/.gitconfig
[url "git://anongit.kde.org/"]
   insteadOf = kde:
[url "ssh://git@git.kde.org/"]
   pushInsteadOf = kde:
EOF

# get SDK & NDK
echo "Download SDK..."
su - kdeandroid -c "curl http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz > android-sdk.tgz"
echo "Download NKD..."
su - kdeandroid -c "curl http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin > android-ndk.bin"

# unpack SDK
echo "SDK: unpacking..."
su - kdeandroid -c "tar xfl /home/kdeandroid/android-sdk.tgz"
cat << EOF > /home/kdeandroid/accept-sdk-license.sh
#!/usr/bin/expect -f

set timeout 1800

# spawn update command and let's wait for password question
spawn /home/kdeandroid/android-sdk-linux/tools/android update sdk --no-ui --filter tools,platform-tools,build-tools-22.0.1,android-22
expect {
  "Do you accept the license '*'*" {
        exp_send "y\r"
        exp_continue
  }
  eof
}
EOF
chown kdeandroid:kdeandroid /home/kdeandroid/accept-sdk-license.sh
chmod +x /home/kdeandroid/accept-sdk-license.sh
echo "SDK: updating..."
su - kdeandroid -c "/home/kdeandroid/accept-sdk-license.sh"
rm /home/kdeandroid/accept-sdk-license.sh
echo "SDK: done."

# unpack NDK
echo "NDK: unpacking..."
chmod +x /home/kdeandroid/android-ndk.bin
su - kdeandroid -c /home/kdeandroid/android-ndk.bin
rm /home/kdeandroid/android-ndk.bin
echo "NDK: done."

#get Qt for Android
echo "Qt Installer: downloading..."
su - kdeandroid -c "curl http://master.qt.io/archive/qt/5.5/5.5.0/qt-opensource-linux-x64-android-5.5.0-2.run > /home/kdeandroid/qt-installer.run"
chmod +x /home/kdeandroid/qt-installer.run
# we need virtual framebuffer provide a window for the GUI
apt-get install xvfb -y
Xvfb :1 -screen 0 1024x768x16 &> /tmp/xvfb.log &
ps aux | grep X
DISPLAY=:1 /home/kdeandroid/qt-installer.run --script /root/qtinstallerconfig.qs -v || true
chown -R kdeandroid:kdeandroid /home/kdeandroid/Qt5.5.0
apt-get remove xvfb -y
rm /home/kdeandroid/qt-installer.run
echo "Qt Installer: done."
echo "Configuration finished, finalizing Docker image..."

