#!/bin/bash


if [ "$1" == "-h" ]; then
  	echo "*************************************************************************"
  	echo "run the script as follow:"
  	echo "./expSchema.sh <ORACLE SID> <EXPORT MODE> <shema_name1,schema_name2,...>"
  	echo "EXPORT MODE might be: NODATA or DATA"
  	echo "DATA: rows will be exported"
  	echo "NODATA: only metadata will be exported"
  	echo "schema_name: A list of schemas to be exported delimited by comma" 
		echo "**************************************************************************"  	
	exit 0
fi


if [ $# -lt 3 ]; then
  	echo "Usage: `basename $0` <ORACLE SID> <EXPORT MODE> <shema_name1,schema_name2,...>"
  	echo "To get help run: ./expSchema.sh -h"
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



case $2 in
	"NODATA") DPTYPE="METADATA_ONLY";;
	"DATA") DPTYPE="ALL";;
	*) echo "Bad argument for export mode, run ./exportSchema.sh -h"; exit  	 666;;
esac


SCHEMA_TO_EXPORT=$3

#if sid exist in oratab we may set the environment

ORAENV_ASK=NO
. oraenv > /dev/null

#set the vars for create Oracle DP dir
DPDATE=`date +%Y%m%d_%H%M%S`
DPDIR="DP_"$DPDATE
#DPDIR="DP_"`date +%Y%m%d_%H%M%S`
DPPATH=`pwd`
DPFILE="expSchema_"$DPTYPE"_"$DPDATE".dmp"
DPLOG="expSchema_"$DPTYPE"_"$DPDATE".log"
DPSCHEMAS=$3

echo $DPDATE,$DPDIR,$DPPATH,$DPFILE,$DPLOG,$DPSCHEMAS,$DPTYPE

#create the 

sqlplus / as sysdba <<EOF > /dev/null
WHENEVER SQLERROR EXIT 666
create directory $DPDIR as '$DPPATH';
exit;
EOF

if [ "$?" -ne "0" ]; then
	echo "Error whilr create $DPDIR Oracle directory"
	echo "Check if Oracle owner has proper rights on $DPPATH "
	echo "Abort..."
	exit 666
fi
echo ""
echo "***********************************"
echo "Will start an EXPORT with the following parameters:"
echo "DataPump Dir: $DPDIR"
echo "DataPump path: $DPPATH"
echo "Dumpfile: $DPFILE"
echo "DataPump log: $DPLOG"
echo "Schemas to export: $DPSCHEMAS"
echo "Export type: $DPTYPE"
echo "***********************************"
echo ""

echo "Enter Y if you want to continue..."
read carset
if [ "$carset" != "Y" ]; then
	echo "Your choise was to abort...."
	exit 666
fi

expdp "'/ as sysdba'" DIRECTORY=$DPDIR DUMPFILE=$DPFILE LOGFILE=$DPLOG SCHEMAS=$DPSCHEMAS CONTENT=$DPTYPE

if [ "$?" -ne "0" ]; then
	echo "*********************************"
	echo "Error on export..."
	echo "Check the file $DPLOG in $DPPATH"
	echo "*********************************"
else
	echo "*********************************"
	echo "Export OK, the file is $DPFILE in $DPPATH"
	echo "removing datapump directory $DPDIR..."
	echo "*********************************"	 	
fi


sqlplus / as sysdba <<EOF > /dev/null
WHENEVER SQLERROR EXIT 666
drop directory $DPDIR ;
exit;
EOF


if [ "$?" -ne "0" ]; then
	echo "*********************************"
	echo "Error while removing $DPDIR"
	echo "*********************************"
else
	echo "*********************************"
	echo "$DPDIR directory removed"	
	echo "*********************************"
fi	
