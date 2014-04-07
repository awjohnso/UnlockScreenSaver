#!/bin/bash

oldFile="/private/etc/pam.d/screensaver"
bakFile="/private/etc/pam.d/screensaver.bak"
tmpFile="/private/tmp/screensaver"

if [ -e "$oldFile" ] && [ ! -e $bakFile ]; then
	/bin/cp $oldFile $bakFile
fi

isMod=`/bin/cat $oldFile | /usr/bin/egrep -ic "#"`
if [ $isMod -eq 2 ]; then
	/bin/echo "File already changed."
else
	/bin/echo "File needs to be changed."
	/bin/cat $oldFile  | /usr/bin/sed -e "s/account    required       pam_group.so no_warn deny group=admin,wheel ruser fail_safe/# account    required       pam_group.so no_warn deny group=admin,wheel ruser fail_safe/" > $tmpFile
	/bin/cp $tmpFile $oldFile
	/bin/chmod 644 $oldFile
	/usr/sbin/chown root:wheel $oldFile
	/bin/rm $tmpFile
	isMod=`/bin/cat $oldFile | /usr/bin/egrep -ic "#"`
	if [ $isMod -eq 2 ]; then
		/bin/echo "File changed successfully."
	else
		/bin/echo "File didn't get changed."
	fi
fi

exit 0

