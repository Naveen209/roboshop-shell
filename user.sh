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
         exit 1
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
if id roboshop &>/dev/null
then
    echo -e "$Y User already exists $N"
else
    useradd roboshop &>>"$LOGFILE"
    echo -e "roboshop $G user created $N"
fi

if [ -d /app ]
then
    echo -e "$Y Directory already exists $N"
else
    mkdir /app &>>"$LOGFILE"
    echo -e "/app $G Directory created $N"
fi
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>"$LOGFILE"
VALIDATE $? "Downloading artifact"
cd /app
VALIDATE $? "Changing directory"
rm -rf * &>>"$LOGFILE"
unzip /tmp/user.zip &>>"$LOGFILE"
VALIDATE $? "Unzipping artifact"
npm install &>>"$LOGFILE"
VALIDATE $? "Installing dependencies"
cp /root/roboshop-shell/user.service /etc/systemd/system/user.service &>>"$LOGFILE"
VALIDATE $? "Copy user service"
systemctl daemon-reload
systemctl enable user
systemctl start user
systemctl status user &>>"$LOGFILE"
cp /root/roboshop-shell/mongo.repo /etc/yum.repos.d/mongodb-org-7.0.repo &>>"$LOGFILE"
VALIDATE $? "Copying mongodb repos"
yum install mongodb-mongosh -y &>>"$LOGFILE"
VALIDATE $? "Installing mongosh"
mongosh --host <MONGODB-IP> </app/schema/user.js &>>"$LOGFILE"
VALIDATE $? "Loading DB schema"
