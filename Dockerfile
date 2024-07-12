FROM ubuntu:22.04

COPY installer-20240618-062940.sh /opt/
RUN apt-get update && apt-get -y install curl 
RUN cd /opt/ && bash installer-20240618-062940.sh

ENV PATH=/opt/oraHelperSuite:$PATH

