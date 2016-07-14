#!/bin/bash
#####################################################################################
# Script:  runsas.sh
# Author:  Matt Nizol
# Purpose: Run a SAS program, scan the log, and report status to the user.
#
# Modification History:
#
# Date        User          Details
# ---------   --------      ---------------------------------------------------
# 13Aug2015   mnizol        Initial script
# 06Nov2015   mnizol        Allow caller to pass up to 2 options to sas command line
#####################################################################################

scriptdir=$(dirname "$(readlink -f "$0")")
program=$1

if [ -z "$program" ] || [ ! -f $program ]; then
    echo "Please provide a valid SAS program to run."
	echo "Usage: $0 [PROGRAM]"
	exit 1
fi

# Execute the sas program
progdir=$(dirname "$(readlink -f "$program")")
sas -log "${progdir}" -print "${progdir}" $2 $3 $program
echo "$program completed with exit code $?"

# Scan the log
logfile=${program%.sas}.log
inclusion=${scriptdir}/inclusion_patterns.txt
exclusion=${scriptdir}/exclusion_patterns.txt

if [ ! -f $logfile ]; then
	echo "Warning: Cannot locate log file"
elif [ ! -f $inclusion ] || [ ! -f $exclusion ]; then
    echo "Warning: Cannot locate pattern files"
else
	# Grep twice: first apply exclusion patterns, then select final matches
	# using inclusion patterns.
	issues=$(grep -ivE --file=$exclusion $logfile | grep -iE --file=$inclusion)
	
	if [ -z "$issues" ]; then
		echo "Log is clean"
	else
		echo "Log issues:"
		echo "${issues}"
	fi
fi
