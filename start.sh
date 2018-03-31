#!/bin/bash -e

MOTO_REGION=${MOTO_REGION:-us-west-1}
MOTO_ACCESSKEY=${MOTO_ACCESSKEY:-accesskey}
MOTO_SECRETKEY=${MOTO_SECRETKEY:-secretkey}

aws configure set default.region $MOTO_REGION
aws configure set aws_access_key_id $MOTO_ACCESSKEY
aws configure set aws_secret_access_key $MOTO_SECRETKEY

for SERVICE in "$@"
do
  NAME=`echo $SERVICE | awk -F ":" '{print $1}'`
  PORT=`echo $SERVICE | awk -F ":" '{print $2}'`

  case "$SERVICE" in
    s3)
      (sleep 5; ./start_s3.sh $PORT) &
      ;;
  esac

  echo "Starting service $NAME in port $PORT..."
  if [[ "$SERVICE" != "${@: -1}" ]]; then
    exec moto_server -H 0.0.0.0 $NAME -p$PORT &
  else
    exec moto_server -H 0.0.0.0 $NAME -p$PORT
  fi
done
