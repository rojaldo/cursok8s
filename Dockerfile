FROM ubuntu:25.04
RUN apt update
RUN apt install -y figlet
ENV MESSAGE="Hello, World!"
ENTRYPOINT figlet $MESSAGE