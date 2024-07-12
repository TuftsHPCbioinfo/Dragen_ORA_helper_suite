FROM ubuntu:22.04

COPY installer-20240618-062940.sh /opt/
RUN bash /opt/installer-20240618-062940.sh

