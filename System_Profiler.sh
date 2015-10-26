#!/usr/bin/env bash

# >> APPENDS TO END OF FILE
# awk '/search_pattern/ { action_to_take_on_matches; another_action; }' file_to_parse
#if  [[ -e checks if file exists

OUTPUTFILE=~/System_Profile.xml
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" >> $OUTPUTFILE
echo "<System_Profile>" >> $OUTPUTFILE

get_distro_name(){
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

get_processor_vendor(){
	CPUVENDOR=$(grep vendor_id /proc/cpuinfo | awk -F ':' '{print $2}' | awk '$1=$1' | uniq)
	echo -e "<processor_vendor>"$CPUVENDOR"</processor_vendor>" >> $OUTPUTFILE
	echo $CPUVENDOR
}

get_processor_arch(){
	CPUARCH=$(lscpu | grep Architecture | awk -F ':' '{print $2}' | awk '$1=$1')
	echo -e "<processor_architecture>"$CPUARCH"</processor_architecture>" >> $OUTPUTFILE
	echo $CPUARCH
}

get_processor_max_freq_mhz(){
	CPUMAXFREQ=$(lscpu | grep "CPU max" | awk -F ':' '{print $2}' | awk '$1=$1')
	echo -e "<processor_max_frequency_mhz>"$CPUMAXFREQ"</processor_max_frequency_mhz>" >> $OUTPUTFILE
	echo $CPUMAXFREQ
}

get_processor_min_freq_mhz(){
	CPUMINFREQ=$(lscpu | grep "CPU min" | awk -F ':' '{print $2}' | awk '$1=$1')
	echo -e "<processor_min_frequency_mhz>"$CPUMINFREQ"</processor_min_frequency_mhz>" >> $OUTPUTFILE
	echo $CPUMINFREQ
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
	echo $RAMFREE
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
	if [[ -n $SWAPTOTAL ]]
	then
		echo -e "<swap_free>"$SWAPFREE"</swap_free>" >> $OUTPUTFILE
		echo $SWAPFREE
	else
		echo -e "<swap_free>No swap active</swap_free>" >> $OUTPUTFILE
		echo "No swap present/active"
	fi
}

#Gather distro info
echo "<Distribution_Info>" >> $OUTPUTFILE
get_distro_name
echo "</Distribution_Info>" >> $OUTPUTFILE

#Gather hardware info
echo "<Hardware>" >> $OUTPUTFILE
echo "<Processor>" >> $OUTPUTFILE
get_processor_vendor
get_processor_arch
get_processor_max_freq_mhz
get_processor_min_freq_mhz
echo "</Processor>" >> $OUTPUTFILE
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
