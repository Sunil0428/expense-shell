LOGPATH="/var/log/expense-shell"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
FILENAME="$LOGPATH/$SCRIPTNAME-$TIMESTAMP.log"

R="\033[1;31m"
G="\033[1;32m"
Y="\033[1;33m"
N="\033[0m"

CHECKUSER()
    if [ $1 -ne 0 ]
    then
        echo -e "$R Please use the root user access to run this script $N"
        exit 1
    fi

VALIDATE()
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is $G SUCCESS $N" | tee -a $FILENAME
    else
        echo -e  "$2 is $R FAILED $N" | tee -a $FILENAME
    fi


USERID=$(id -u)

CHECKUSER $USERID

mkdir -p $LOGPATH

dnf install nginx -y 
VALIDATE $? "install nginx"

systemctl enable nginx
VALIDATE $? "enable nginx"

systemctl start nginx
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing the default nginx code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "download expense code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "copying expense conf"

systemctl restart nginx
VALIDATE $? "restart nginx"