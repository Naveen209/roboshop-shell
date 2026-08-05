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
yum install nginx -y &>>"$LOGFILE"
VALIDATE $? "installing nginx"
systemctl enable nginx
systemctl start nginx 
systemctl status nginx &>>"$LOGFILE"
VALIDATE $? "status nginx"
rm -rf /usr/share/nginx/html/* &>>"$LOGFILE"
VALIDATE $? "removing older files"
curl -L -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>"$LOGFILE"
VALIDATE $? "downloading artifact"
cd /usr/share/nginx/html &>>"$LOGFILE"
VALIDATE $? "changing directory"
unzip /tmp/web.zip &>>"$LOGFILE"
VALIDATE $? "unzipping artifact"
cp /root/roboshop-shell/web.conf /etc/nginx/default.d/roboshop.conf &>>"$LOGFILE"
VALIDATE $? "Copy configuration file"
systemctl restart nginx &>>"$LOGFILE"
VALIDATE $? "restart nginx"
systemctl status nginx &>>"$LOGFILE"
VALIDATE $? "status nginx"


