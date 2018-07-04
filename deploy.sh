FILE=$1
ROOT=`pwd`
NAME="${FILE%%.*}"
SERVICE="./$NAME.service"
TIMER="./$NAME.timer"

SYSTEMCTL=`command -v systemctl`

if [ ! -f $FILE ]; then
	echo "File not found!"
fi

ABSPATH=`readlink -f $FILE`

echo $ABSPATH
echo $NAME
echo $SERVICE

if [ -z "$SYSTEMCTL" ]; then
	apt-get install systemd
fi

/bin/cat <<EOF >$SERVICE

[Unit]
Description=Log2IPTables Service

[Service]
WorkingDirectory=$ROOT
ExecStart=$ABSPATH -x 1 -f /var/log/auth.log -e ssh-bruteforce

[Install]
WantedBy=multi-user.target

EOF


/bin/cat <<EOF >$TIMER

[Unit]
Description=Log2IPTables Timer

[Timer]
OnBootSec=2h
OnUnitActiveSec=2h

[Install]
WantedBy=log2iptables.service

EOF

cp log2iptables.service /etc/systemd/system/
cp log2iptables.timer /etc/systemd/system/timers.target.wants/

systemctl enable log2iptables.service
systemctl start log2iptables.service
systemctl start log2iptables.timer

echo "Successful running!"
