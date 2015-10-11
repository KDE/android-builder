FROM ubuntu:wily

LABEL Description="KDE on Android SDK"
MAINTAINER Andreas Cord-Landwehr <cordlandwehr@kde.org>

ENV ADIR /opt/android
RUN mkdir -p $ADIR

RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ wily main universe restricted\n\
deb-src [arch=armhf]  http://ports.ubuntu.com/ wily main universe restricted\n\
\n\
deb [arch=armhf] http://ports.ubuntu.com/ wily-updates main universe restricted\n\
deb-src [arch=armhf] http://ports.ubuntu.com/ wily-updates main universe restricted\n\
\n\
deb [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily main universe restricted\n\
deb-src [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily main universe restricted\n\
\n\
deb [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily-updates main universe restricted\n\
deb-src [arch=i386,amd64] http://archive.ubuntu.com/ubuntu wily-updates main universe restricted\n\
" > /etc/apt/sources.list

# enable verbose apt-get output
RUN echo 'Debug::pkgProblemResolver "true";' > /etc/apt/apt.conf.d/debug
RUN dpkg --add-architecture i386 && apt update && apt-get install -y \
  ant \
  build-essential \
  cmake \
  curl \
  expect \
  git \
# required for running kdesrc-build
  libxml-simple-perl \
  libjson-perl \
  openjdk-7-jdk \
  openjdk-7-jre \
  qt5-qmake \
  sudo \
# virtual framebuffer to provide X window for the Qt installer
  xvfb \
# required i386 architecture libraries
  libgcc1:i386 \
  libc6:i386 \
  zlib1g:i386

RUN adduser kdeandroid --gecos "" --disabled-password && echo "kdeandroid   ALL=NOPASSWD:ALL" >> /etc/sudoers && chown -R kdeandroid:kdeandroid $ADIR

USER kdeandroid
RUN echo "[url \"git://anongit.kde.org/\"]\n\
   insteadOf = kde:\n\
[url \"ssh://git@git.kde.org/\"]\n\
   pushInsteadOf = kde:\n\
"  > /home/kdeandroid/.gitconfig

# get SDK
COPY accept-sdk-license.sh $ADIR/accept-sdk-license.sh
RUN sudo chown kdeandroid:kdeandroid $ADIR/accept-sdk-license.sh && chmod +x $ADIR/accept-sdk-license.sh
RUN echo "Download SDK..." && \
curl http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz -o $ADIR/android-sdk.tgz && \
# unpack SDK
echo "SDK: unpacking..." && \
tar xfl $ADIR/android-sdk.tgz -C $ADIR/ && \
echo "SDK: updating..." && \
$ADIR/accept-sdk-license.sh $ADIR && \
rm $ADIR/accept-sdk-license.sh && \
rm $ADIR/android-sdk.tgz && \
echo "SDK: done."

# get NDK
RUN echo "Download NDK..." && \
curl http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin -o $ADIR/android-ndk.bin && \
echo "NDK: unpacking..." && \
chmod +x $ADIR/android-ndk.bin && \
cd $ADIR && \
./android-ndk.bin && \
cd / && \
rm $ADIR/android-ndk.bin && \
echo "NDK: done."

#get Qt for Android
RUN echo "Qt Installer: downloading..." && \
 curl http://master.qt.io/archive/qt/5.5/5.5.0/qt-opensource-linux-x64-android-5.5.0-2.run -o $ADIR/qt-installer.run && \
 chmod +x $ADIR/qt-installer.run

COPY qtinstallerconfig.qs $ADIR/qtinstallerconfig.qs
RUN Xvfb :1 -screen 0 1024x768x16 &> /tmp/xvfb.log & \
 sleep 2 && \
 DISPLAY=:1 $ADIR/qt-installer.run --script $ADIR/qtinstallerconfig.qs -v || true && \
 echo "Qt Installer: done."

# cleanup
RUN sudo apt-get remove -y\
    xvfb \
    expect \
    curl && \
 sudo apt-get autoremove -y && \
 rm $ADIR/qt-installer.run && \
 rm $ADIR/qtinstallerconfig.qs

RUN echo "\n\
export ADIR=$ADIR\n\
export ANDROID_NDK=$ADIR/android-ndk-r10e\n\
export ANDROID_SDK_ROOT=$ADIR/android-sdk-linux\n\
export Qt5_android=$ADIR/Qt5.5.0/5.5/android_armv7/\n\
export PATH=$ADIR/android-sdk-linux/platform-tools/:$PATH\n\
export ANT=/usr/bin/ant\n\
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/\n\
\n\
function cmakeandroid {\n\
    cmake \$@ -DCMAKE_INSTALL_PREFIX=$ADIR/kde/install -DCMAKE_PREFIX_PATH=\"$ADIR/Qt5.5.0/5.5/android_armv7/;$ADIR/kde/install\" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$ADIR/kde/install/share/ECM/toolchain/Android.cmake\n\
}\n\
" >> /home/kdeandroid/.bashrc

# get KDESRC build and android configurations
RUN git clone git://anongit.kde.org/scratch/cordlandwehr/kdesrc-conf-android.git $ADIR/kdesrc-conf-android && \
mkdir -p $ADIR/extragear/kdesrc-build && \
git clone git://anongit.kde.org/kdesrc-build $ADIR/extragear/kdesrc-build && \
ln -s $ADIR/extragear/kdesrc-build/kdesrc-build $ADIR/kdesrc-build && \
ln -s $ADIR/kdesrc-conf-android/kdesrc-buildrc $ADIR/kdesrc-buildrc

RUN cd $ADIR && ./kdesrc-build extra-cmake-modules

RUN echo "Configuration finished, finalizing Docker image..."
