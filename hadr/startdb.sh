#!/bin/bash

# funcation: used to start or switch hadr server.
# note: this script can be used in Chinese environment. 
# If you are in English environment, please modify related Chinese characters 

# check hostname.
# In default,wls1 is primary,wls2 is standby.
_pri=wls1
_std=wls2

_hos=`hostname`

# 数据库名
_dbname=sample

# check hadr db role (This value is among three values (standard, primary, standby) in running process, else it is null.)
_ros=(STANDARD PRIMARY STANDBY " ")

# obtain current hadr role
_rol=`#su - db2inst1 -c "db2 get db cfg for $_dbname |grep -i hadr|grep 数据库角色|awk -F = '{print $2}'|sed -e 's/ //g'"`

# e.g for english env
# _rol=`#su - db2inst1 -c "db2 get db cfg for $_dbname |grep -i hadr|grep 'database role'|awk -F = '{print $2}'|sed -e 's/ //g'"`

# db resource
_src="$_dbname-rs:wls"

# db startup and stop status (online offline failed and other)
# 3 kinds of status
_sts=(Online Offline Failed)

# current status
_sta=`lssam|grep $_src|grep -v grep |awk  '{print $2}'|sed -e 's/ //g'|sort -u`

# status num
_num=`lssam|grep $_src|grep -v grep |awk  '{print $2}'|sed -e 's/ //g'|sort -u|wc -l`

# start db
startDb() {
	if [ "x$_rol"="x" ]
	then
		echo "startup stardard db on "$_hos"
		# su - db2inst1 -c "db2start"
	fi
}

# stop db
stopDb() {
	if [ "$_rol"="${_ros[0]}"]
	then
		echo "shutdown stardard db on "$_hos"
		# su - db2inst1 -c "db2stop"
	fi
}

# startup hadr on standby host
strStandby() {
	echo "startup standy db on "$_hos"
	# su - db2inst1 -c "db2 deactivate database $_dbname"
	# su - db2inst1 -c "db2 start hadr on database $_dbname as standby"
}

# start primary
strPrimary() {
	echo "startup primary db on "$_hos"
	# su - db2inst1 -c "db2 deactivate database $_dbname"
	# su - db2inst1 -c "db2 start hadr on database $_dbname as primary"
}

# take over
takeOver() {
	  case "$_rol" in
		STANDARD)
			echo "where database instance has been running,please start up hadr database."
			;;
		PRIMARY)
			echo "This is the primary database,Please issue the command on standby."
			;;
		STANDBY)
			echo "Ready to take over hadr db on standby."
			# su - db2inst1 -c "db2 takeover hadr on database $_dbname"
			;;
		*)
			echo "Database don't startup."
			;;
		esac	
}


# stop hadr
stopHadr() {
	echo "shutdown hadr db on "$_hos"
	# su - db2inst1 -c "db2 DEACTIVATE DATABASE $_dbname"
	# su - db2inst1 -c "db2 STOP HADR ON DATABASE $_dbname"
}


#ssh connection
rshConn() {
	# if the connected host is primary host,then need to connect the standby to startup hadr db
	if [ "$_hos"="$_pri" ] 
	then
		rsh "$_hos" #'su - db2inst1 -c "db2 get db cfg for $_dbname|grep -i hadr"'
		strStandby
	fi
}


#echo _sta is "$_sta"

#echo _num is $_num

#if $_num is 1,then it's must be not startup.May be offline or failed.
for i in "$_sta"
do 
	#echo "$i"
	if [ "$i"!="${_sts[0]}" ]
	then
		if [ "$i"="${_sts[1]}" ]
		then
			if [ $_num -eq 1 ]
			then
				echo "Hadr dont start up" 
				
				#The current connected host is the primary node
				if [ "$_hos"="$_pri" ]
				then
					echo "Please startup standby database first"
					
					#if current role is primary,then connect to standby to issue
					if [ "$_rol"="${_ros[1]}" ]
					then
						echo "connect to  $_hos to startup standby hadr db"
						rshConn	
					fi
				else
					echo "startup standby on $_hos directly"
					strStandby
				fi
			else 
				if [ "$i"="${_sts[2]}" ]
				then
					echo status is ${_sts[2]}
					echo "please hadr on standy"
				else
					echo "Hadr has started up"
				fi
			fi 
		fi
	fi	
done 


# usage for script
usage() {
   echo "Usage:`basename $0`" 
   echo
   echo "-------------------------------------------------------------------"
   echo
   echo "               1|start standard db"
   echo
   echo "               2|start standby db and then primary db"
   echo
   echo "               3|take over hadr db"
   echo
   echo "               4|stop hadr db"
   echo
   echo "               5|stop standard db"
   echo
   echo "               6|check db role"
   echo
   echo "               7|exit"
   echo
   echo "-------------------------------------------------------------------"
   echo

}


# choice
while :
do
echo -n "Enter choice Number [1 2 3 4 5 6 7 or a b c d e f g] : " && read CHOICE
case $CHOICE in
		a|1) echo "start standard db"
			startDb
			;; 
		b|2) echo "starting standby database"
         	 	echo "starting primary database"
			;;
		c|3) echo "taking over hadr db"
			takeOver
			;;
		d|4) echo "stop hadr db"
			stopHadr
			;;
		e|5) echo "stop standard db"
			stopDb
			;; 
		f|6) echo "check db role"
			echo "$_rol"
			;;
		g|7) echo "exit"
			exit;;			
		h|*) echo
			usage
			;;
esac
done
