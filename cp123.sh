#!/bin/bash 

if [ "$#" -eq 0 -o "$1" = "-h" -o "$1" = "--help" ]
then
	echo 
	echo "cp123.sh: Copy one file to multiple directories."
	echo "Usage: cp123.sh FILE DIR1 [DIR2 DIR3 ...]"
	echo "Author: Yi Xianfu, yixf1986@gmail.com"
	echo "Date: 2011-09-27"
	echo
	exit 0
fi

FILE=$1
shift
DIRS=$*

if [ ! -f $FILE ]
then
	echo "No such file: $FILE"
	echo
	echo "Usage: cp123.sh FILE DIR1 [DIR2 DIR3 ...]"
	echo
	exit 1
fi

for DIR in $DIRS
do 
	if [ -d $DIR ]
	then
	/bin/cp $FILE $DIR
else
	echo "No such directory: $DIR ... Skipping"
	echo
	echo "Usage: cp123.sh FILE DIR1 [DIR2 DIR3 ...]"
	echo
	fi
done

