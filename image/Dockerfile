FROM ubuntu:vivid

LABEL Description="KDE on Android SDK"
MAINTAINER Andreas Cord-Landwehr <cordlandwehr@kde.org>

COPY insidesetup.sh /root/insidesetup.sh
COPY qtinstallerconfig.qs /root/qtinstallerconfig.qs

RUN bash /root/insidesetup.sh
