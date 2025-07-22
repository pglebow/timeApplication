#!/bin/bash
yum update -y
yum install java-17-amazon-corretto -y

cd /home/ec2-user
aws s3 cp s3://YOUR_BUCKET/time-api.jar time-api.jar
nohup java -jar time-api.jar > app.log 2>&1 &