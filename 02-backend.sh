LOGPATH="/var/log/expense-shell"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
FILENAME="$LOGPATH/$SCRIPTNAME-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
N="\e[0m"

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

useradd expense &>> $FILENAME
VALIDATE $? "Adding expense user"

mkdir -p /app &>> $FILENAME
VALIDATE $? "Creating app dir"

rm -rf /tmp/* &>> $FILENAME
VALIDATE $? "removing files in tmp dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "getting app code"

rm -rf /app/* &>> $FILENAME
VALIDATE $? "removing files in app dir"

cd /app 
VALIDATE $? "get into the app dir"

unzip /tmp/backend.zip &>> $FILENAME
VALIDATE $? "get the code into the app dir"

npm install  &>> $FILENAME
VALIDATE $? "npm installation"

cp $PWD/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copying service file"

systemctl daemon-reload  &>> $FILENAME
VALIDATE $? "daemon reload"
systemctl start backend  &>> $FILENAME
VALIDATE $? "start backend service"
systemctl enable backend &>> $FILENAME
VALIDATE $? "enable backend service"
