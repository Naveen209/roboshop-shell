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
#Configure Erlang Repo
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>"$LOGFILE"
VALIDATE $? "Configuring Erlang Repository"

# Configure RabbitMQ Repo
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>"$LOGFILE"
VALIDATE $? "Configuring RabbitMQ Repository"

# Install RabbitMQ
dnf install rabbitmq-server -y &>>"$LOGFILE"
VALIDATE $? "Installing RabbitMQ"

# Enable RabbitMQ
systemctl enable rabbitmq-server &>>"$LOGFILE"
VALIDATE $? "Enabling RabbitMQ"

# Start RabbitMQ
systemctl start rabbitmq-server &>>"$LOGFILE"
VALIDATE $? "Starting RabbitMQ"

rabbitmqctl list_users | grep -w roboshop &>/dev/null &>>"$LOGFILE"

if [ $? -ne 0 ]
then
    rabbitmqctl add_user roboshop roboshop123 &>>"$LOGFILE"
else
    echo "$Y User already exists $N"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>"$LOGFILE"
VALIDATE $? "Setting permissions RabbitMQ"
