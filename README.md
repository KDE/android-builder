# KDE on Android Docker Image

For building Qt applications on Android, some extra steps are required in comparison to building them directly on Linux. Specifically, one requires a proper build environment for the cross-compilation step. This Docker script enables you to start without the hassle of first setting up the NDK, SDK, Qt-for-Android, environment variables etc. 

This image provides an Ubuntu/Wily with the following extras:
* installed Android NDK
* installed Android SDK
* installed Qt for Android with Linux host
* installed kdesrc-build
* user ''kdeandroid'' with the following environment
 * all needed variables for ECM-CMake Toolchain are set
 * command "cmakeandroid" that provides a convenience call to CMake with the toolchain enabled
* the image provides two users
 * kdeandroid: default user for a developer
 * jenkins: default user for CI system

## Proposed Workflow for Image Creation
Create the image
```
cd image
docker build -t kde-android-sdk .
```

Create the container instance for the needed project, see information about volumes.
```
docker create -ti --name myproject kde-android-sdk bash
```
If you want to access the local filesystem to access the source code, consider specifying a docker volume (--volume /localpath:/dockerpath).
See [Docker Volumes Documentation](https://docs.docker.com/userguide/dockervolumes/) for more information.

Start the container for our project.
```
docker start -i myproject
```

