FROM python:3.5.5-slim

RUN pip install moto[server]
RUN pip install awscli

RUN apk update && apk add \
    inotify-tools

WORKDIR /opt/moto
ADD *.sh ./
RUN chmod +x *.sh

EXPOSE 5000

ENTRYPOINT ["./start.sh"]
