LOGPATH="/var/log/expense-shell/"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
FILENAME="$LOGPATH/$SCRIPTNAME-$TIMESTAMP.log"

echo $FILENAME