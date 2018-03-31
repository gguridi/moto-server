# Moto Dockerfile

This container uses the [moto](https://github.com/spulec/moto) library to seamlessly emulate an AWS environment.

It runs the [moto standalone server](https://github.com/spulec/moto#stand-alone-server-mode) to create the service, adding extra functionality on the top of it.

The image is based on alpine so it aims to have low impact in your system.

## Usage

### Install

Pull `gguridi/moto` from the Docker repository:

    docker pull gguridi/moto

### Run

Each image can be used with one service at a time. To run multiple AWS services we will need to run several docker instances passing to each of them which service we want to enable.

The basic image run would be:

    docker run -p local:port gguridi/moto service:port

For instance, if we want to run a S3 service (the list of services can be obtained from the moto repository):

    docker run -p 4000:5000 gguridi/moto s3:5000

By default the container will run in the foreground, returning the logs of what the server is receiving. To run it in the background we must specify the detached option:

    docker run -p 4000:5000 -d gguridi/moto s3:5000

#### S3

If we want to synchronise a local folder to have it available automatically as S3 content, we can just map an internal container folder and the scripts will take care of it.

    docker run -p 4000:5000 -v /source-dir:/opt/moto/s3 gguridi/moto s3:5000

The container will automatically create the direct subfolder as bucket, and the rest of the path as prefix/file inside the s3 service.

Files inside the s3 folder will automatically be added/updated/removed from the s3 service. Currently the files must change from inside the docker container for inotify to receive the event. Changes made in the host are not propagated inside the docker container (or at least inotify doesn't receive them).
