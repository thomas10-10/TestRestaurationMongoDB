#!/bin/bash
bucketS3=$1
urlPushStatusCake=$2
mkdir -p $0.dir
cd ./$0.dir/
lastFile=`/usr/local/bin/aws s3 ls s3://${bucketS3}/ | tail -n1 | awk '{print $4}'`
/usr/local/bin/aws s3 cp s3://{bucketS3}/$lastFile ./
( time mongorestore --host localhost:27017 --gzip  --archive=./$lastFile ) > rapport.txt 2>&1
rm -rf ./$lastFile
sudo systemctl stop mongodb
sudo rm -rf /var/lib/mongodb/*
sudo systemctl start mongodb
cat rapport.txt | grep documents > rapport_resume.txt
if (( `cat rapport.txt |grep documents |grep -v '0 documents' | wc -l` > 2 )) && (( `cat rapport.txt |grep documents | wc -l` > 6 ))
	then echo ok > rapport_status.txt ; curl '${urlPushStatusCake}'
else echo nok > rapport_status.txt
fi
