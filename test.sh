#!/bin/bash



while getopts se: option
do
	case "$option"
	in
		s) ORACLESID=$OPTARG;;
		e) EXPTYPE=$OPTARG;;
		?)	echo "wromg usage"
				exit 666;;
	esac			
done

echo $ORACLESID
echo $EXPTYPE
