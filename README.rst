chkpwd_buddy
====================

About chkpwd_buddy
--------------------
chkpwd_buddy is a bash script that tries to discover current
user password by brute-forcing it using a list of common
passwords.

It checks all the list's passwords using unix_chkpwd
(the same `PAM`_ component used by `pam_unix`_, which, in turn,
is used by login, xscreensaver etc.).

Beware, most systems will log all the failed password checks.

Author: Marco Bellaccini - marco.bellaccini(at!)gmail.com

License: `Creative Commons CC0 1.0`_

Password Lists
--------------------
You can get some good password lists `here`_.

Of course, you can make your custom lists
(just list the passwords one-per-line).


Usage example
--------------------
Get a password list:

	foouser\@foohost:~$ wget \https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/10_million_password_list_top_1000.txt

Check that the script is executable:

	foouser\@foohost:~$ chmod u+x chkpwd_buddy.sh

Run the script:

	foouser\@foohost:~$ ./chkpwd_buddy.sh 10_million_password_list_top_1000.txt

Wait for the result (some seconds in this case):

	SUCCESS: foouser password is "music" (and is in "10_million_password_list_top_1000.txt")!

.. _PAM: http://www.linux-pam.org/
.. _pam_unix: http://www.linux-pam.org/Linux-PAM-html/sag-pam_unix.html
.. _Creative Commons CC0 1.0: https://creativecommons.org/publicdomain/zero/1.0/legalcode
.. _here: https://github.com/danielmiessler/SecLists/tree/master/Passwords
