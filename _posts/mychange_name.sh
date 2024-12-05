#!/bin/bash
if [ $# -gt 1 ]
then
    mydate=$1
    shift
    for filename in $*
    do
    	newfilename=`echo $filename | sed 's/\.html/.md/' | sed "s/^/$mydate-/" | sed 's/_/-/g' `
    	mv $filename $newfilename
    done

else
	echo "$0 date_patern files...."
fi
