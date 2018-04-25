#!/bin/bash


if [ "$1" == "-h" ]; then
  	echo "Help here"
	exit 666
fi


if [ $# -lt 1 ]; then
  	echo "Usage: `basename $0` <full path and name of the file you want to rotate> "
  	echo "Help here"

	exit 666
fi

#set the oracle sid as first parameter
ORACLE_SID=$1

#check if the sid is in oratab
#the sid is always as <oracle sid>: in oratab

grep -q $ORACLE_SID":" /etc/oratab

if [ "$?" -ne "0" ]; then
	echo "such ORACLE_SID as $ORACLE_SID does not exist in oratab"
	echo "Abort..."
	exit 666
fi	

#if sid exist in oratab we may set the environment

ORAENV_ASK=NO
. oraenv > /dev/null

echo $ORACLE_SID
echo $ORACLE_HOME

#set the vars for create Oracle DP dir
DPDIR="DP_"`date +%Y%m%d_%H%M%S`
DPPATH=`pwd`

sqlplus / as sysdba <<EOF
create directory $DPDIR as '$DPPATH';
exit;
EOF

if [ "$?" -ne "0" ]; then
	echo "Error whilr create $DPDIR Oracle directory"
	echo "Abort..."
	exit 666
fi

sqlplus / as sysdba <<EOF
drop directory $DPDIR ;
exit;
EOF
	



TODAY=`date +%Y%m%d_%H%M%S`
#LOGFILEPATH=$1
#LOGFILEPATHRIGHT=`stat --format=%a ${LOGFILEPATH}`
#LOGFILEPATHOWNER=`stat --format=%u ${LOGFILEPATH}`
WHOAMI=`id -u`
#LOGFILE=`basename ${LOGFILEPATH}`
#LOGDIR=`dirname $1`
#LOGFILETMP="tmp_"${LOGFILE}
#ROTATELOG=${LOGDIR}"/rotateLog_"${LOGFILE}

