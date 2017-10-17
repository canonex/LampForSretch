#!/bin/bash
##to debug #!/bin/bash -xv

echo ""
echo "                         NIBDJLLI"
echo "Non Interactive"
echo "    Bash"
echo "       Debian Jessie"
echo "           Linux Lamp"
echo "              Installer"
echo ""
echo "      |||||    Please read the following notes!     |||||"
echo ""
echo ""
echo "Continue? (y or n)"

read answer

if echo "$answer" | grep -iq "^y" ;then
    echo "Let's begin..."
else
	echo "Au revoir"
	exit 0
fi
	
if [ "$(whoami)" != "root" ]; then
	echo "      WARNING Please start this script as root."
	exit 1
fi

RELEASE=$(lsb_release -cs)
if [ $RELEASE != "jessie" ]; then
	echo "      WARNING The complete setup has never been tested in $RELEASE"
fi


echo ''"\033[1m   Installing Lamp Server-------------------------------------\033[0m"
sh DebianLamp.sh

echo ''"\033[1m   Basic configuration has started-------------------------------------\033[0m"
sh DebianLampConf.sh

echo "Ending"

exit 0
