#!/bin/bash
##to debug #!/bin/bash -xv

echo "Debian Lamp configurator!" >> InfoCurrentInstall.txt
echo "Today, $(date), we are configuring $(hostname)" >> InfoCurrentInstall.txt

echo "						sshd_config"
CURRENT=/etc/ssh/sshd_config
#Backup
cp $CURRENT $CURRENT.old

echo "# Limiting old or weak protocols for better security" >> $CURRENT
echo "Ciphers aes256-ctr,aes256-cbc,3des-cbc" >> $CURRENT
echo "KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >> $CURRENT

/etc/init.d/ssh restart
if [ $? -ne 0 ]; then
	MSG="Please check the Ssh current configuration ( $CURRENT ), there is some $(tput bold)$(tput setaf 1)Problem$(tput sgr0)"
	echo $MSG
	ERRORS="$ERRORS Ssh Configuration"
else
	echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
fi


echo "						fail2ban"
CURRENT=/etc/fail2ban/jail.conf
#Backup
cp $CURRENT $CURRENT.old

#Sed replace in section
sed -i '/\[DEFAULT\]/,/^\[/ s/bantime.*/bantime  = 3600/' $CURRENT
sed -i '/\[ssh-ddos\]/,/^\[/ s/enabled.*/enabled  = true/' $CURRENT

service fail2ban restart
if [ $? -ne 0 ]; then
	MSG="Please check the Fail2Ban current configuration ( $CURRENT ), there is some $(tput bold)$(tput setaf 1)Problem$(tput sgr0)"
	echo $MSG
	ERRORS="$ERRORS Fail2Ban Configuration"
else
	echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
fi


CURRENT="/etc/apache2/apache2.conf"
#Backup
cp $CURRENT $CURRENT.old

echo "						apache2.conf"
echo "ServerTokens Prod" >> $CURRENT
echo "ServerSignature Off" >> $CURRENT

CURRENT="/etc/php5/apache2/php.ini"
#Backup
cp $CURRENT $CURRENT.old

echo "						php.ini"

sed -i "s/max_execution_time.*/max_execution_time = 30/g" $CURRENT
sed -i "s/max_input_time .*/max_input_time = 60/g" $CURRENT
sed -i "s/memory_limit.*/memory_limit = 128M/g" $CURRENT

sed -i "s/post_max_size.*/post_max_size = 24M/g" $CURRENT
sed -i "s/upload_max_filesize.*/upload_max_filesize = 24M/g" $CURRENT
sed -i 's/;date.timezone.*/date.timezone = \"Europe\/Rome\"/g' $CURRENT

service apache2 restart
if [ $? -ne 0 ]; then
	MSG="Please check the Apache current configuration ( $CURRENT ), there is some $(tput bold)$(tput setaf 1)Problem$(tput sgr0)"
	echo $MSG
	ERRORS="$ERRORS Apache Configuration"
else
	echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
fi

echo "						...next"
echo "You can now manually setup phpmyadmin to be allowed only fron internal network:"
echo "192.168.0.0/16, 255.255.255.0 (range 192.168.0.1 - 192.168.255.254)"
echo "editing /etc/apache2/conf-available/phpmyadmin.conf"
echo "and restarting apache"
echo "service apache2 restart"

exit 0
