#!/bin/bash

	# Set up some variables: Location of file to be modded. Location of the 
	# backupfile, and location of the temporary file.
oldFile="/private/etc/pam.d/screensaver"
bakFile="/private/etc/pam.d/screensaver.bak"
tmpFile="/private/tmp/screensaver"

	# If the backupfile doesn't exist, most likely the change hasn't been made.
	# So backup the file just in case.
if [ -e "$oldFile" ] && [ ! -e $bakFile ]; then
	/bin/cp $oldFile $bakFile
fi

	# Now, check the file to see if it was actually modded. The change is made by 
	# commenting out the last line which reads: 
	# account    required       pam_group.so no_warn deny group=admin,wheel ruser fail_safe
isMod=`/bin/cat $oldFile | /usr/bin/egrep -ic "#"`
if [ $isMod -eq 2 ]; then
	/bin/echo "File has already been changed."
else
	/bin/echo "File needs to be changed."
		# Make the change with Sed. Basically add a # in front of the last line.
		# Pipe the command to the temporary file.
	/bin/cat $oldFile | /usr/bin/sed -e "s/account    required       pam_group.so no_warn deny group=admin,wheel ruser fail_safe/# account    required       pam_group.so no_warn deny group=admin,wheel ruser fail_safe/" > $tmpFile
		# Copy the temporary file to replace the non modified file.
	/bin/cp $tmpFile $oldFile
		# Properly adjust ownership and permissions on the file, just in case.
	/bin/chmod 644 $oldFile
	/usr/sbin/chown root:wheel $oldFile
		# Cleanup: Remove the temporary file.
	/bin/rm $tmpFile
		# Double check to see if the file was successfully changed.
	isMod=`/bin/cat $oldFile | /usr/bin/egrep -ic "#"`
	if [ $isMod -eq 2 ]; then
		/bin/echo "File changed successfully."
	else
		/bin/echo "File didn't get changed."
		exit 1
	fi
fi

exit 0
