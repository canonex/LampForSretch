# LampForStretch
Non Interactive Bash Debian Stretch Linux Lamp Installer,
easily spelled NIBDSLLI.

## How to:
1. Install Debian Stretch.
   - if building a server consider using [Debian netinstall ](https://www.debian.org/distrib/netinst)
   - in tasksel let only "Standard system utilities" selected.

2. Become root, copy/download/get/clone this scripts in your computer execute install.sh as root.  
Some operation may take a while, be patient.

## What you should get:
 - a file, InfoCurrentInstall.txt,  in the same directory of the script with passwords, logins, bla bla
 - very basic configuration for security and very basic configuration for common tasks (have a look in DebianLampConf.sh)
 - ssh (only new protocols enabled). Fail2Ban (extended bantime), Apache ( production mode ), MariaDb (already with mysql_secure_installation), Php (extended memory upload options), PhpMyAdmin, Git, curl and dependencies
 - headers and rewrite enabled
 - php.ini date.timezone option on Europe Rome: please configure your position [Php Timezones](http://php.net/manual/en/timezones.php)


Please have a look at the code:
is commented and, more or less, self explaining.

End
