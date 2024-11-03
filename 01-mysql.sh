LOGPATH="/var/log/expense-shell/"
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

mysql --version  &>> $FILENAME

if [ $? -ne 0 ]
then
    echo -e "$R mysql is not there in the system, hence installing $N" | tee -a $FILENAME
    dnf install mysql -y &>>FILENAME
    VALIDATE $? "Installing mysql"
else
    echo -e "$R mysql alrdy there in the system, nothing to do $N" | tee -a $FILENAME
fi

systemctl enable mysqld &>>FILENAME
VALIDATE $? "enabling mysql"

systemctl start mysqld &>>FILENAME
VALIDATE $? "staring mysql"

mysql -h 54.235.31.231 -u root -pExpenseApp@1 &>>FILENAME

if [ $? -ne 0 ]
then
    echo -e "$R mysql root password is setting $N" | tee -a $FILENAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "setting mysql root password"
else    
    echo -e "$R mysql root password is alrdy set $N" | tee -a $FILENAME
fi


