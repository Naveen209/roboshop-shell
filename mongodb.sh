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
message=
VALIDATE() {
    if [ $USERID -ne 0 ]
    then
         echo -e "$2 $R FAILURE $N "
    else
        echo -e "$2 $G SUCCESS $N "
    fi 
}
cp /c/Devops/repos/roboshop-shell-script/mongo.repo /etc/yum.repos.d/mongodb-org-7.0.repo &>>"$LOGFILE"
VALIDATE $? "Copying mongodb repos"
yum install -y mongodb-org &>>"$LOGFILE"
VALIDATE $? "Installing mongodb"
systemctl enable mongod &>>"$LOGFILE"
VALIDATE $? "Enable mongodb"
systemctl start mongod &>>"$LOGFILE"
VALIDATE $? "Starting mongodb"
systemctl status mongod &>>"$LOGFILE"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>"$LOGFILE"
VALIDATE $? "Port binding"
systemctl restart mongod &>>"$LOGFILE"
VALIDATE $? "Restarting mongodb"
