FROM python:3.5.5-slim

RUN pip install moto[server]
RUN pip install awscli

RUN apt-get update && apt-get install -y \
    inotify-tools

WORKDIR /opt/moto
ADD *.sh ./
RUN chmod +x *.sh

EXPOSE 5000

ENTRYPOINT ["./start.sh"]
