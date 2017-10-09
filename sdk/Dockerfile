# https://github.com/rabits/dockerfiles/blob/master/5.9-android/Dockerfile
FROM rabits/qt:5.9-android

LABEL Description="Qt Android SDK"
MAINTAINER Aleix Pol Gonzalez

USER root
RUN apt-get -qq update && apt-get install -qq \
    cmake \
    libxml-simple-perl \
    libjson-perl \
    ninja-build \
    build-essential \
    gettext \
    python3 \
    && apt-get -qq clean

USER user

ENV ANDROID_NDK $ANDROID_NDK_ROOT
COPY gitconfig $HOME/.gitconfig
