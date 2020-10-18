#18-10-2020
#Onur Gures

echo "This is an OS environment check program."
echo "----------------------------------------"

#Hostname checker
echo "enter the hostname: "
echo "--------------------"
read correctHostname

configuredHostname=`hostnamectl status |grep "Static hostname"  | awk '{print $3}'`

if [ "$correctHostname" == "$configuredHostname" ]; then
    echo "hostname is correct."
    echo "--------------------"
else
    echo "hostname is not correct"
    echo "-----------------------"
fi

kontrolor=0
firstLineIPetchosts=`cat /etc/hosts | head -n 1 | awk '{print $1}'`
assignedIPs=`ifconfig -a |grep -w inet |grep -v 127.0.0.1 | awk '{print $2}'`
for val in $assignedIPs; do
    if [ "$val" == "$firstLineIPetchosts" ]; then
        let "kontrolor=kontrolor+1"
    fi
done
if [ "$kontrolor" == 0 ]; then
    echo "you must correct /etc/hosts file!" 
    echo "---------------------------------"
else   
    echo "IP configured in the /etc/hosts file is matching one of the interfaces!"
    echo "-----------------------------------------------------------------------"
fi

#/etc/fstab check
tmpParameter=`cat /etc/fstab | grep tmp | awk '{print $4}'`
rootParameter=`cat /etc/fstab | grep -w / | awk '{print $4}'`
ext4Parameters=`cat /etc/fstab | grep ext4 | grep -vw / | grep -vw tmp | awk '{print $4}'`
for val in $ext4Parameters; do
    if [ "$val" != "noatime" ]; then
        echo "there is wrong fs : '$val'"
        echo "please solve the problem." 
        echo "-------------------------"
    fi
done

#CPU frequency check
echo "enter the CPU frequency recommended in Platform Sizing Response (MHz): "
read correctCpuFrequency
configuredCpuFrequency=`cat /proc/cpuinfo | grep "cpu MHz" | head -n 1 | awk '{print $4}' | awk '{printf "%.0f",$1}'`
if [ $((configuredCpuFrequency + 100)) -gt "$correctCpuFrequency" ]; then
    echo "CPU frequency is sufficient"
    echo "---------------------------"
else
    echo "CPU frequency is not sufficient"
    echo "-------------------------------"
fi

#Memory size check
echo "enter the memory size recommended in Platform Sizing Response (GB): "
read correctMemSize
configuredMemSize=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
if [ "$configuredMemSize" -gt $((correctMemSize * 100000 )) ]; then
    echo "Memory is sufficient"
    echo "--------------------"
else
    echo "Memory is not sufficient"
    echo "------------------------"
fi

#check local firewalld is running
echo "Checking if firewalld is stopped/disabled."
echo "------------------------------------------"
currentFirewalldStatusAD=`systemctl status firewalld | grep Active | awk '{print $2}'`
if [ "$currentFirewalldStatusAD" == "inactive" ]; then
    echo "firewalld is inactive."
    echo "--------------------"
else
    echo "firewalld is active!"
    echo "-----------------------"
fi

#systemctl status firewalld | grep Loaded | awk '{print $4}'
currentFirewalldStatusAD=`systemctl status firewalld | grep Loaded | awk '{print $4}'`
if [ "$currentFirewalldStatusAD" == "disabled;" ]; then
    echo "firewalld is disabled."
    echo "--------------------"
else
    echo "firewalld is enabled!"
    echo "-----------------------"
fi

#check if seLinux disabled
#getenforce
currentSeLinuxStatus=`getenforce`
if [ "$currentSeLinuxStatus" == "disabled;" ]; then
    echo "SELinux is disabled"
    echo "-------------------"
else
    echo "SELinux is not disabled!"
    echo "------------------------"
fi


#Check reserved block counts for the partitions
#tune2fs -l /dev/mapper/rhel-opt_nsp |grep "Reserved block count:" | awk '{print $4}'
nfmpPartitions=`mount | grep nfmp | awk '{print $1}'`
for val in $nfmpPartitions; do
    valReservedBlockStatus=`tune2fs -l $val |grep "Reserved block count:" | awk '{print $4}'`
    if [ $((valReservedBlockStatus)) != 0 ]; then
        echo "There's a problem with reservation of block counts for $val!"
    else
        echo "there's no problem with reservation of block counts for $val"
    fi
done

#locale check
#localectl status |grep "System Locale" |awk '{print $3}'
localeStatus=`localectl status |grep "System Locale" |awk '{print $3}'`
if [ "$localeStatus" == "LANG=POSIX" ]; then
    echo "locale is configured correctly."
    echo "-------------------------------"
else
    echo "there's a problem with locale configuration."
    echo "--------------------------------------------"
fi

#available Repository check

#Firewall ports check

#already installed OS packages check, address missing packages