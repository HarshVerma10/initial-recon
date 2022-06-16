#!/bin/bash

# BANNER
clear
		
	echo "checking Tools....................." ;sleep 2
	not_install=()
	for x in $(cat tools.txt) 
	do
		if [ -f /usr/bin/$x ];
		then 
			echo $x:"Found"& sleep 0.5
		else 
			echo $x:"Not Found" & sleep 0.5  
			not_install+=( $x )
		fi
	done
	
	
	if (( ${#not_install[@]}==0 ));
	then 
		echo "Good"

	else
		echo " "
		echo "install these binary files in /usr/bin : ${not_install[@]} "
		echo "Exiting !!!!!!!"
		exit 1	
	fi
clear
figlet -c Initial Recon -f banner/pagga.tlf
echo " "

#Main Code
read -p "Enter the location of output file (for current directory './') : " loc
cd $loc
read -p "Enter the Domain (abc.com): " domain
mkdir $domain  2>/dev/null
cd $domain
x=1
while [ $x = 1 ]
do
	# Subfinder configuration
	subfinder -d $domain -silent| tee -a subfinder  &

	# Amass Configuration
	amass enum -d $domain -config ~/Tools/Amass/config.ini -o amass.txt 
	x=0
done;


sort amass.txt subfinder | uniq | tee -a subdomains 

rm amass.txt subfinder
# Printing subdomain file and checking for http and https and saving in file name hosts
cat subdomains | httprobe | tee -a hosts
echo "Your Subdomains are Enumerated !!!"
read -r -p "Do you wish to Enumerate more? (Y/N): " choice

case $choice in
	y|Y|yes|Yes)
		# For Directory Enumeration
		x=1
		while [ $x = 1 ]
		do
			# Checking through Waybackurls and putting in file named waybackurls
			cat hosts | waybackurls | tee -a waybackurls &
			
			# Checking with gau all subdomains from subdomain file and putting them in file named gau
			gau --providers ./subdomains --verbose | tee -a gau  &2>errors_gau.txt &
			
			# Doing gospider search
			gospider -S hosts -u web: -t 10 -a | tee -a gospider  &2>errors_gospider.txt &
			
			# Running meg
			echo "/" > paths
			meg -L -c 200
			x=0
			
		done &
		;;
	n|N|no|NO)
		echo "Exiting................"	
		;;
	*) 
	echo "Plz enter valid choice"
		;;
esac