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
yum install redis -y &>>"$LOGFILE"
VALIDATE $? "installing redis"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>"$LOGFILE"
VALIDATE $? "Port binding" 
systemctl enable redis &>>"$LOGFILE"
VALIDATE $? "Enable redis" 
systemctl start redis &>>"$LOGFILE"
VALIDATE $? "Start redis"
systemctl status redis &>>"$LOGFILE"
VALIDATE $? "Status redis" &>>"$LOGFILE"