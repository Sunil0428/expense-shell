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

dnf module disable nodejs -y &>> $FILENAME
VALIDATE $? "Disabling existing nodejs"

dnf module enable nodejs:20 -y &>> $FILENAME
VALIDATE $? "Enabling nodejs 20"

dnf install nodejs -y &>> $FILENAME
VALIDATE $? "Installing nodejs 20"

EXPENSEUSERID=$(id expense -u)

if [ $? -ne 0 ]
then
    useradd expense &>> $FILENAME
    VALIDATE $? "Adding expense user"
else
    echo -e " $Y expene user is already there in the system $N"
fi

mkdir -p /app &>> $FILENAME
VALIDATE $? "Creating app dir"

rm -rf /tmp/* &>> $FILENAME
VALIDATE $? "removing files in tmp dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "getting app code"

rm -rf /app/* &>> $FILENAME
VALIDATE $? "removing files in app dir"

cd /app   &>> $FILENAME
VALIDATE $? "get into the app dir"

unzip /tmp/backend.zip &>> $FILENAME
VALIDATE $? "get the code into the app dir"

npm install  &>> $FILENAME
VALIDATE $? "npm installation"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copying service file"

systemctl daemon-reload  &>> $FILENAME
VALIDATE $? "daemon reload"
systemctl start backend  &>> $FILENAME
VALIDATE $? "start backend service"
systemctl enable backend &>> $FILENAME
VALIDATE $? "enable backend service"

dnf install mysql -y  &>> $FILENAME
VALIDATE $? "installing mysql"

mysql -h 54.235.31.231 -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>> $FILENAME
VALIDATE $? "running the backend sql in mysql server"

systemctl restart backend
VALIDATE $? "restart backend"