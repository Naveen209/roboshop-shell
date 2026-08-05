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
    echo -e "$R Please run the script as root cart $N"
    exit 1
fi
dnf module disable mysql -y &>>"$LOGFILE"
VALIDATE $? "Disable mysql"
cp /root/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>>"$LOGFILE"
VALIDATE $? "Copying mysql repos"
dnf install mysql-community-server -y &>>"$LOGFILE"
VALIDATE $? "Installing mysql"
systemctl enable mysqld &>>"$LOGFILE"
VALIDATE $? "Enable mysql"
systemctl start mysqld &>>"$LOGFILE"
VALIDATE $? "Starting mysql"
mysql -uroot -pRoboShop@1 -e "show databases;" &>>"$LOGFILE"
if [ $? -ne 0 ]
then
    echo "Root password not configured. Setting password..."
    if mysql_secure_installation --help | grep -q "set-root-pass"
    then
        mysql_secure_installation --set-root-pass RoboShop@1 &>>"$LOGFILE"
        VALIDATE $? "Setting MySQL Root Password"
    else
        TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
        mysql --connect-expired-password \
        -u root \
        -p"${TEMP_PASS}" \
        -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" &>>"$LOGFILE"

        VALIDATE $? "Setting MySQL Root Password"
    fi
else
    echo -e "MySQL Root Password Already Set... $Y SKIPPING $N"
fi
