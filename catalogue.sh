#!/bin/bash
DATE=$(date +%F:%H:%M:%S)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
VALIDATE() {
    if [ $1 -ne 0 ]
    then
         echo -e "$2 $R FAILURE $N"
    else
        echo -e "$2 $G SUCCESS $N"
    fi 
}
if [ $USERID -ne 0 ]
then
    echo -e "$R Please run the script as root user $N"
    exit 1
fi
yum module disable nodejs -y &>>"$LOGFILE"
VALIDATE $? "Disable nodejs"
yum module enable nodejs:20 -y &>>"$LOGFILE"
VALIDATE $? "Enable nodejs:20"
yum install nodejs -y &>>"$LOGFILE"
VALIDATE $? "Installing nodejs:20"
useradd roboshop &>>"$LOGFILE"
if [ $? -ne 0 ]
then
    echo -e "$Y User already exists $N"
else
    echo -e "roboshop $G user created $N"
fi
mkdir -p /app &>>"$LOGFILE"
if [ $? -ne 0 ]
then
    echo -e "$Y Directory already exists $N"
else
    echo -e "/app $G Directory created $N"
fi
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>"$LOGFILE"
cd /app
rm -rf *
unzip /tmp/catalogue.zip &>>"$LOGFILE"
VALIDATE $? "Unzipping artifact"
npm install &>>"$LOGFILE"
VALIDATE $? "Installing dependencies"
cp /root/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>"$LOGFILE"
VALIDATE $? "Copy Catalogue service"
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
systemctl status catalogue &>>"$LOGFILE"
cp /root/roboshop-shell/mongo.repo /etc/yum.repos.d/mongodb-org-7.0.repo &>>"$LOGFILE"
VALIDATE $? "Copying mongodb repos"
yum install mongodb-mongosh -y &>>"$LOGFILE"
VALIDATE $? "Installing mongosh"
mongosh --host <MONGODB-IP> </app/schema/catalogue.js &>>"$LOGFILE"
VALIDATE $? "Loading DB schema"
