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
#su - kdeandroid -c "git clone git://anongit.kde.org/xutils.git /home/plasmamobile/xutils"
echo "kdeandroid   ALL=NOPASSWD:ALL" >> /etc/sudoers

cat << EOF > /home/kdeandroid/.gitconfig
[url "git://anongit.kde.org/"]
   insteadOf = kde:
[url "ssh://git@git.kde.org/"]
   pushInsteadOf = kde:
EOF

# get SDK & NDK
su - kdeandroid -c "curl http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz > android-sdk.tgz"
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
rm /home/kdeandroid/android-accept-licenses.sh
echo "SDK: done."

# unpack NDK
echo "NDK: unpacking..."
chmod +x /home/kdeandroid/android-ndk.bin
su - kdeandroid -c /home/kdeandroid/android-ndk.bin
echo "NDK: done."

