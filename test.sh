#!/bin/bash



echo "Enter Y if you want to continue..."
read carset
if [ "$carset" != "Y" ]; then
	echo "Your choise was to abort...."
	exit 666
fi

echo "am trevut"
