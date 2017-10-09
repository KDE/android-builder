FROM rabits/qt:5.9-android

LABEL Description="Qt Android CI"
MAINTAINER Aleix Pol Gonzalez

USER root
RUN apt-get -qq update && apt-get install -qq openssh-server && dpkg-reconfigure openssh-server && mkdir -p /var/run/sshd && apt-get -qq clean

RUN useradd -d /home/jenkins/ --user-group --create-home -G video jenkins
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
