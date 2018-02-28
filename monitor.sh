LOG_PATH=/home/ec2-user/.pm2/logs
MONITORING_PATH=/home/ec2-user/monitoring
PM2_APP_NAME=app

if [ ! -f $MONITORING_PATH/$PM2_APP_NAME-error-0.log ]; then
  touch $MONITORING_PATH/$PM2_APP_NAME-error-0.log
fi

diff $MONITORING_PATH/$PM2_APP_NAME-error-0.log $LOG_PATH/$PM2_APP_NAME-error-0.log > $MONITORING_PATH/diff

if [ -s $MONITORING_PATH/diff ] && ! grep -q 'Error: Connection lost: The server closed the connection.' $MONITORING_PATH/diff; then
  echo ' Sending email '
  echo Subject: [$NODE_ENV] $PM2_APP_NAME crash alert > $MONITORING_PATH/_email
  echo >> $MONITORING_PATH/_email
  cat $MONITORING_PATH/diff >> $MONITORING_PATH/_email

  /usr/sbin/sendmail sahil.narain@baxi.taxi < $MONITORING_PATH/_email

  rm $MONITORING_PATH/diff
  rm $MONITORING_PATH/_email
fi

cp $LOG_PATH/$PM2_APP_NAME-error-0.log $MONITORING_PATH/$PM2_APP_NAME-error-0.log