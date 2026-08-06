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
    if [ $? -ne 0 ]
    then
         echo -e "$2 $R FAILURE $N "
    else
        echo -e "$2 $G SUCCESS $N "
    fi 
}
if [ $USERID -ne 0 ]
then
    echo -e "$R Please run the script as root user $N"
    exit 1
fi
yum install python3 python3-pip -y &>>"$LOGFILE"
VALIDATE $? "Installing Python"
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
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>"$LOGFILE"
VALIDATE $? "Downloading artifact"
cd /app &>>"$LOGFILE"
rm -rf *
unzip /tmp/payment.zip &>>"$LOGFILE"
VALIDATE $? "Unzipping artifact"
pip3 install -r requirements.txt &>>"$LOGFILE"
VALIDATE $? "Installing dependencies"
cp /root/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>"$LOGFILE"
VALIDATE $? "Copying payment services"
systemctl daemon-reload &>>"$LOGFILE"
systemctl enable payment &>>"$LOGFILE"
systemctl start payment
systemctl status payment &>>"$LOGFILE"
