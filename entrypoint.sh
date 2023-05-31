#!/bin/sh

set -e

# Create basic config for s3cmd
echo "[default]
check_ssl_certificate = True
check_ssl_hostname = True
guess_mime_type = True
host_base = ${AWS_ENDPOINT}
access_key = ${AWS_ACCESS_KEY_ID}
secret_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.s3cfg

echo "Uploading file to ${LOCAL_FILE} to ${REMOTE_FILE}"

if [[ ! -z "$INCLUDE_SHA256" ]]; then
    echo "Generating SHA256"
    cat ${LOCAL_FILE} | sha256sum | awk '{printf $1}' > ${LOCAL_FILE}.sha256
    if [ ${AWS_ENDPOINT} != "" ]; then
      s3cmd put --host=${AWS_ENDPOINT} ${LOCAL_FILE}.sha256 s3://${AWS_BUCKET}/${REMOTE_FILE}.sha256 $*
    else
      s3cmd put ${LOCAL_FILE}.sha256 s3://${AWS_BUCKET}/${REMOTE_FILE}.sha256 $*
    fi
fi

if [ ${AWS_ENDPOINT} != "" ]; then
s3cmd put --host=${AWS_ENDPOINT} ${LOCAL_FILE} s3://${AWS_BUCKET}/${REMOTE_FILE} $*
else
s3cmd put ${LOCAL_FILE} s3://${AWS_BUCKET}/${REMOTE_FILE} $*
fi
