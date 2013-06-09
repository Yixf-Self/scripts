#!/bin/bash - 

set -o nounset                              # Treat unset variables as an error

USER="yixf"
IP="202.127.22.51"
BAKDIR="/3_archive/Dropbox/Ubuntu_Software/server"

for FILE in .bashrc .vimrc
do
	BAKFILE=`echo $FILE | tr -d .`
	scp $USER@$IP:~/$FILE $BAKDIR/$BAKFILE.`date +%Y%m%d`
done

for SYSFILE in crontab
do
	scp $USER@$IP:/etc/$SYSFILE $BAKDIR/$SYSFILE.`date +%Y%m%d`
done

for F2BFILE in fail2ban.conf jail.conf
do
	scp $USER@$IP:/etc/fail2ban/$F2BFILE $BAKDIR/$F2BFILE.`date +%Y%m%d`
done

for FOLDER in .ssh .vim .vimana
do
	BAKFOLDER=`echo $FOLDER | tr -d .`
	ssh $USER@$IP "cd; tar cfz - $FOLDER" > $BAKDIR/$BAKFOLDER\_`date +%Y%m%d`.tar.gz
done


