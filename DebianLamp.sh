#!/bin/bash -xv
##to debug #!/bin/bash -xv

echo "Lamp installer!" > InfoCurrentInstall.txt
echo "Today, $(date), we are installing on $(hostname)" >> InfoCurrentInstall.txt
echo "________________________________________" >> InfoCurrentInstall.txt

MYSQLROOTPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
PHPMYADMINTPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)


echo "MySql root password: $MYSQLROOTPASSWORD" >> InfoCurrentInstall.txt
echo "PhpMyAdmin root password: $PHPMYADMINTPASSWORD" >> InfoCurrentInstall.txt


export DEBIAN_FRONTEND=noninteractive

ERRORS=""

echo "				Updating..."
apt-get update
#apt-get upgrade -y --show-upgraded

echo -e "\n"
echo "				Installing Ssh, fail2ban, Expect and Debconf for automatic installations"
apt-get -y install ssh expect debconf-utils fail2ban iptables aptitude

echo -e "\n"
echo "				Installing Lamp"

echo "					- Apache & Curl"
apt-get install -y curl apache2

echo "						- Enabling headers and rewrite"
a2enmod headers
a2enmod rewrite

echo "						...restarting and checking"
service apache2 restart
if [ $? -ne 0 ]; then
	MSG="Please Check the Apache installation, there is some $(tput bold)$(tput setaf 1)Problem$(tput sgr0)"
	echo $MSG
	ERRORS="$ERRORS ApacheInstallation"
else
	echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
	echo "Apache installed" >> InfoCurrentInstall.txt
fi


#Courtesy of: https://rbgeek.wordpress.com/2014/08/07/automated-installation-of-lamp-stack-on-ubuntu-server/
#and https://gist.github.com/sheikhwaqas/9088872
echo "					- MySql"
echo "mariadb-server mysql-server/root_password password $MYSQLROOTPASSWORD" | debconf-set-selections
echo "mariadb-server mysql-server/root_password_again password $MYSQLROOTPASSWORD" | debconf-set-selections 
apt-get -y install mariadb-server mariadb-client
echo PURGE | debconf-communicate mariadb-server


#http://us.informatiweb.net/tutoriels/153--debian-ubuntu-install-a-complete-web-server-with-apache-php-mysql-and-phpmyadmin.html
#https://dev.mysql.com/doc/refman/5.0/en/charset-applications.html

echo "						...beginning basic securing config system-wide."
#Courtesy of: https://gist.github.com/Mins/4602864
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQLROOTPASSWORD\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
 
echo "$SECURE_MYSQL"
aptitude -y purge expect 

echo "						...restarting and checking"
service mysql restart
if [ $? -ne 0 ]; then
	MSG="Please Check the MySql installation, there is some $(tput bold)$(tput setaf 1)Problem$(tput sgr0)"
	echo $MSG
	ERRORS="$ERRORS MySqlInstallation"
else
	echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
	echo "MySql installed and hardened" >> InfoCurrentInstall.txt
fi


echo "						- Apache"
#php5-mysql
#php-apc for some uses
apt-get install -y php5 php5-mysqlnd libapache2-mod-php5 php5-mcrypt php5-curl libssh2-php git

echo "						- PhpMyAdmin"
echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
#Admin mysql
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQLROOTPASSWORD" | debconf-set-selections
#Phpmysql pass
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMINTPASSWORD" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMINTPASSWORD" | debconf-set-selections
apt-get -y install phpmyadmin
echo PURGE | debconf-communicate phpmyadmin

	echo "Php installed" >> InfoCurrentInstall.txt

echo "________________________________________" >> InfoCurrentInstall.txt

exit 0
