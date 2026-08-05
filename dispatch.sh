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
yum install golang -y &>>"$LOGFILE"
VALIDATE $? "Installing Golanguage"
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
curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>"$LOGFILE"
VALIDATE $? "downloading artifact"
cd /app &>>"$LOGFILE"
rm -rf * &>>"$LOGFILE"
unzip /tmp/dispatch.zip &>>"$LOGFILE"
VALIDATE $? "unzipping artifact"
go mod init dispatch &>>"$LOGFILE"
go get &>>"$LOGFILE"
go build &>>"$LOGFILE"
VALIDATE $? "install dependencies"
cp /root/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>>"$LOGFILE"
VALIDATE $? "Copy dispatch service"
systemctl daemon-reload &>>"$LOGFILE"
systemctl enable dispatch 
systemctl start dispatch