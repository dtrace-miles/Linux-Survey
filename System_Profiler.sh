#!/usr/bin/env bash

# >> APPENDS TO END OF FILE
# awk '/search_pattern/ { action_to_take_on_matches; another_action; }' file_to_parse
#if  [[ -e checks if file exists

OUTPUTFILE=~/System_Profile.xml
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" >> $OUTPUTFILE
echo "<System_Profile>" >> $OUTPUTFILE

check_distro(){
    if [[ -e /etc/redhat-release ]]
    then
      DISTRO=$(cat /etc/redhat-release)
    elif [[ -e /usr/bin/lsb_release ]]
    then
      DISTRO=$(lsb_release -d | awk -F ':' '{print $2}' | awk '$1=$1')
    elif [[ -e /etc/issue ]]
    then
      DISTRO=$(cat /etc/issue)
    else
      DISTRO=$(cat /proc/version)
    fi
    echo -e "<distro>"$DISTRO"</distro>" >> $OUTPUTFILE
    echo $DISTRO
    }



check_ram_total(){
	RAMTOTAL=$(grep MemTotal /proc/meminfo | awk -F ':' '{print $2}' | awk '$1=$1')
	echo -e "<ram_total>"$RAMTOTAL"</ram_total>" >> $OUTPUTFILE
	echo $RAMTOTAL
}

check_ram_free(){
	RAMFREE=$(grep MemAvailable /proc/meminfo | awk -F ':' '{print $2}' | awk '$1=$1')
	if [[ $RAMFREE ]]
	then
		echo -e "<ram_free>"$RAMFREE"</ram_free>" >> $OUTPUTFILE
	else
		echo -e "<ram_free>0 kB</ram_free>" >> $OUTPUTFILE
		echo "No RAM free"
	fi
}

check_swap_total(){
	SWAPTOTAL=$(grep SwapTotal /proc/meminfo | awk -F ':' '{print $2}' | awk '$1=$1')
	if [[ $SWAPTOTAL ]]
	then 
		echo -e "<swap_total>"$SWAPTOTAL"</swap_total>" >> $OUTPUTFILE
		echo $SWAPTOTAL
	else
		echo -e "<swap_total>No swap active</swap_total>" >> $OUTPUTFILE
    	echo "No swap present/active"
	fi
}

check_swap_free(){
	SWAPFREE=$(grep SwapFree /proc/meminfo | awk -F ':' '{print $2}' | awk '$1=$1')
	if [[ $SWAPFREE ]]
	then
		echo -e "<swap_free>"$SWAPFREE"</swap_free>" >> $OUTPUTFILE
	else
		echo -e "<swap_free>0 kB</swap_free>" >> $OUTPUTFILE
		echo "No swap present/active"
	fi
}

#Gather distro info
echo "<Distribution_Info>" >> $OUTPUTFILE
check_distro

echo "</Distribution_Info>" >> $OUTPUTFILE

#Gather hardware info
echo "<Hardware>" >> $OUTPUTFILE
#Gather memory info
echo "<Memory>" >> $OUTPUTFILE
check_ram_total
check_ram_free
check_swap_total
check_swap_free
echo "</Memory>" >> $OUTPUTFILE
echo "</Hardware>" >> $OUTPUTFILE

#close XML root element
echo "</System_Profile>" >> $OUTPUTFILE
