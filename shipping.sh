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
yum install java-17-openjdk java-17-openjdk-devel maven -y &>>"$LOGFILE"
VALIDATE $? "Installing java-17 & maven"
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
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>"$LOGFILE"
cd /app
VALIDATE $? "Changing directory"
rm -rf *
unzip /tmp/shipping.zip &>>"$LOGFILE"
VALIDATE $? "Unzipping artifact"
mvn clean package &>>"$LOGFILE"
VALIDATE $? "installing dependencies"
mv target/shipping-1.0.jar shipping.jar &>>"$LOGFILE"
VALIDATE $? "Renaming shipping jar file"
cp /root/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>"$LOGFILE"
VALIDATE $? "Copy shipping service"
systemctl daemon-reload 
systemctl enable shipping &>>"$LOGFILE"
VALIDATE $? "enable shipping service"
systemctl start shipping &>>"$LOGFILE"
VALIDATE $? "starting shipping service"
systemctl status shipping &>>"$LOGFILE"
VALIDATE $? "checking shipping service status"
cp /root/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>>"$LOGFILE"
VALIDATE $? "Copying MySQL repo"

yum install mysql-community-client -y &>>"$LOGFILE"
VALIDATE $? "Installing MySQL client"

mysql -h mysql.roboshopservice.store -u root -pRoboShop@1 </app/schema/shipping.sql &>>"$LOGFILE"
VALIDATE $? "Loading schema"

systemctl restart shipping &>>"$LOGFILE"
VALIDATE $? "Restarting shipping service"