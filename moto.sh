#!/bin/sh -e

MOTO_REGION=${MOTO_REGION:-us-west-1}
MOTO_ACCESSKEY=${MOTO_ACCESSKEY:-accesskey}
MOTO_SECRETKEY=${MOTO_SECRETKEY:-secretkey}

aws configure set default.region $MOTO_REGION
aws configure set aws_access_key_id $MOTO_ACCESSKEY
aws configure set aws_secret_access_key $MOTO_SECRETKEY

MOTO_URL="http://localhost:5000"

create_bucket() {
    local BUCKET=$1
    aws --endpoint-url $MOTO_URL s3api create-bucket --bucket $BUCKET --region $MOTO_REGION
}

delete_bucket() {
    local BUCKET=$1
    aws --endpoint-url $MOTO_URL s3 rb delete-bucket --bucket $BUCKET --region $MOTO_REGION
}

# S3 synchronisation
S3_FOLDER="/opt/moto/s3/"
if [ -d $S3_FOLDER ]; then
    for DIRECTORY in "$S3_FOLDER"*/ ; do
        BUCKET=$(basename $DIRECTORY)
        create_bucket $BUCKET
        aws --endpoint-url $MOTO_URL s3 cp $DIRECTORY s3://$BUCKET --recursive
    done
fi

# S3 watching changes
inotifywait -m -e modify -e move -e create -e delete -r "$S3_FOLDER" | while read path eventlist eventfile
do
    if [ "$path" == "$S3_FOLDER" ] && [ "$eventlist" == "CREATE,ISDIR" ]; then
        create_bucket $eventfile
    fi
    if [ "$path" == "$S3_FOLDER" ] && [ "$eventlist" == "DELETE,ISDIR" ]; then
        delete_bucket $eventfile
    fi
    if [ "$path" != "$S3_FOLDER" ] && [ "$eventlist" == "CREATE,ISDIR" ]; then
        echo "ignoring folder creation... only files trigger sync"
    fi
    if [ "$path" != "$S3_FOLDER" ] && [ "$eventlist" == "DELETE,ISDIR" ]; then
        echo "ignoring folder deletion... only files trigger sync"
    fi
    if [ "$path" != "$S3_FOLDER" ] && [ "$eventlist" == "CREATE" ] || [ "$eventlist" == "MODIFY" ] || [ "$eventlist" == "MOVED_TO" ]; then
        prefix=${path#"$S3_FOLDER"}
        aws --endpoint-url $MOTO_URL s3 cp $path/$eventfile s3://$prefix
    fi
    if [ "$path" != "$S3_FOLDER" ] && [ "$eventlist" == "DELETE" ] || [ "$eventlist" == "MOVED_FROM" ]; then
        prefix=${path#"$S3_FOLDER"}
        aws --endpoint-url $MOTO_URL s3 rm s3://$prefix$eventfile
    fi
done
