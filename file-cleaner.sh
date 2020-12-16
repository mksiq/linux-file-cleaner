#!/bin/bash
# Author: Maickel Siqueira
# Description: Script to count an remove empty files and directories, and counting large files.
# version: 0.8
# usage information
usage () {
	cat << PRINT
Usage: ${0} [-c] [-d] [-f] [-s] [-p path]" 
if -p is not selected, default path is current directory
PRINT
	exit ${1}
}
cflag=
dflag=
fflag=
pflag=0
sflag=

while getopts cdfsp: command
do
	case $command in
	## Counts empty files and directories to print count to user
	c)	cflag=1;;
	## Removes empty directories
	d)	dflag=1;;
	## Removes empty files
	f)	fflag=1;;
	## Finds the files over 1 MB in the path
	s)	sflag=1;;
	## Changes the destination path for script use
	p)	pflag=1
		pval="$OPTARG";;
	## Informs user on how to use it
	?)	usage 1 ;;
	esac
done

# Checks if there is no parameter
if [[ $# -eq 0 || $# -gt 6  ]]; then
	usage 2
fi

## If no -p operator sets path to current directory
if [ "$pflag" -eq 0 ]; then
	#check if a value other than operator is the first parameter
	if [[ "${1}" = "-c" || "${1}" = "-s" || "${1}" = "-f" || "${1}" = "-d" || "${1}" = "-p" ]];then
		pval="."
	else
		echo "Invalid operator. If you are trying to change the path use [-p PATH]"
	fi
fi

if [ "$fflag" = 1 ]; then
	number=`find $pval -size 0 -type f -print 2>/dev/null | wc -l`
	echo  "Number of empty files in path \"$pval\" before removal: $number"
	if [ "$number" -ne 0 ]; then
		find $pval -size 0 -type f -exec rm -f {} \;
		echo "$number empty files removed"
	else	
		echo "You have no files to remove"
	fi
fi

if [ ! -z "$dflag" ]; then
        dirCount=0	
	number=`find $pval -type d -empty -print | wc -l` 2>/dev/null
	if [ "$number" -eq 0 ]; then
		echo "You have no directories to remove"
	else
	#While loop do deal with directories after empty directiores have been removed, for example clear a tree of mkdir -p a/b/c
		while [ $number -gt 0 ]
		do	
			number=`find $pval -type d -empty -print | wc -l` 2>/dev/null
			find $pval -type d -empty -exec rmdir {} \; 2>/dev/null
		if [ "$number" -eq 0 ]; then
			echo "You have no more directories to remove"
		else
			dirCount=$(($dirCount+$number))
		fi			
		done
		echo "Number of empty directories in path \"$pval\" before removal: $dirCount"
	fi
fi

if [ ! -z "$cflag" ]; then
	directories=`find $pval -type d -empty | wc -l` 2>/dev/null
	files=`find $pval -type f -size 0 | wc -l` 2>/dev/null
	echo "You have a total of $directories empty directories and a total of $files empty files inside the path \"$pval\""
fi

if [ ! -z "$sflag" ];then
	number=`ls -hLR $pval -hlR | awk '{ print $9,  $5 }' | grep "[M]$" | wc -l 2>/dev/null`
	echo "You have $number files over 1 MB:"
	ls $pval -hlR | awk '{ print $9,  $5 }' | grep "[M]$" | sort -rk2 2>/dev/null
fi
