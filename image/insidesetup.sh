#!/bin/bash
set -e

unset LANG #remove? or just install locales...

source /etc/environment
dpkg --add-architecture i386

# main directory for all installations
mkdir -p /opt/android/
export ADIR=/opt/android/

echo "deb [arch=armhf] http://ports.ubuntu.com/ wily main universe restricted
deb-src [arch=armhf]  http://ports.ubuntu.com/ wily main universe restricted

deb [arch=armhf] http://ports.ubuntu.com/ wily-updates main universe restricted
deb-src [arch=armhf] http://ports.ubuntu.com/ wily-updates main universe restricted

deb [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily main universe restricted
deb-src [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily main universe restricted

deb [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily-updates main universe restricted
deb-src [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily-updates main universe restricted
" > /etc/apt/sources.list

echo 'Debug::pkgProblemResolver "true";' > /etc/apt/apt.conf.d/debug

apt update
apt-get install \
  ant \
  build-essential \
  cmake \
  curl \
  expect \
  git \
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
curl http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz > $ADIR/android-sdk.tgz
echo "Download NKD..."
curl http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin > $ADIR/android-ndk.bin

# unpack SDK
echo "SDK: unpacking..."
tar xfl $ADIR/android-sdk.tgz -C $ADIR/
cat << EOF > $ADIR/accept-sdk-license.sh
#!/usr/bin/expect -f

set timeout 1800

# spawn update command and let's wait for password question
spawn $ADIR/android-sdk-linux/tools/android update sdk --no-ui --filter tools,platform-tools,build-tools-22.0.1,android-22
expect {
  "Do you accept the license '*'*" {
        exp_send "y\r"
        exp_continue
  }
  eof
}
EOF
chmod +x $ADIR/accept-sdk-license.sh
echo "SDK: updating..."
$ADIR/accept-sdk-license.sh
rm $ADIR/accept-sdk-license.sh
rm $ADIR/android-sdk.tgz
echo "SDK: done."

# unpack NDK
echo "NDK: unpacking..."
chmod +x $ADIR/android-ndk.bin
$ADIR/android-ndk.bin
rm $ADIR/android-ndk.bin
echo "NDK: done."

#get Qt for Android
echo "Qt Installer: downloading..."
curl http://master.qt.io/archive/qt/5.5/5.5.0/qt-opensource-linux-x64-android-5.5.0-2.run > $ADIR/qt-installer.run
chmod +x $ADIR/qt-installer.run
# we need virtual framebuffer provide a window for the GUI
apt-get install xvfb -y
Xvfb :1 -screen 0 1024x768x16 &> /tmp/xvfb.log &
ps aux | grep X
DISPLAY=:1 $ADIR/qt-installer.run --script /root/qtinstallerconfig.qs -v || true
apt-get remove xvfb -y
rm $ADIR/qt-installer.run
echo "Qt Installer: done."

# set environment variables
cat << EOF >> /home/kdeandroid/.bashrc
export ADIR=$ADIR
export ANDROID_NDK=$ADIR/android-ndk-r10e
export ANDROID_SDK_ROOT=$ADIR/android-sdk-linux
export Qt5_android=$ADIR/Qt5.5.0/5.5/android_armv7/
export ANDROID_API_VERSION=android-22
export PATH=$ADIR/android-sdk-linux/platform-tools/:$PATH
export ANT=/usr/bin/ant
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
EOF

# get KDESRC build and android configurations
git clone git://anongit.kde.org/scratch/cordlandwehr/kdesrc-conf-android.git $ADIR/kdesrc-conf-android
mkdir -p $ADIR/extragear/kdesrc-build
git clone git://anongit.kde.org/kdesrc-build $ADIR/extragear/kdesrc-build
ln -s $ADIR/extragear/kdesrc-build/kdesrc-build $ADIR/kdesrc-build
ln -s $ADIR/kdesrc-conf-android/kdesrc-buildrc $ADIR/kdesrc-buildrc
# required package for running kdesrc-build
apt-get install \
  libxml-simple-perl \
  libjson-perl \
  -y

# give ownership about everything to kdeandroid user
chown -R kdeandroid:kdeandroid $ADIR

echo "Configuration finished, finalizing Docker image..."

