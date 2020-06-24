#!/bin/bash
dec2ip() {
    local ip dec=$@
    delim=""
    for e in {3..0}
    do
        ((octet = dec / (256 ** e) ))
        ((dec -= octet * 256 ** e))
        ip+=$delim$octet
        delim=.
    done
    # printf '%s' "$ip"
    ip1="$ip"

}
if [ -e ip2country.csv ]
   then
               echo The file ip2country.csv is localy.
   else
          echo ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
          echo o    Connect to Management Server to get the ip2country.csv file    o
          echo ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
          read -p "Management Server IP : " mng_ip
          read -p "Admin User           : " mng_admin
          scp $mng_admin@$mng_ip:/opt/CPrt-R80/conf/ip2country.csv ./ip2country.csv
fi

echo ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
echo o                   Simulate commands                               o
echo ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
read -r -p "do you like to simulate the commands that will be insert? [y/N] :" response
case "$response" in
[yY][eE][sS]|[yY]) 
	simulate=1
;;
*)
	simulate=0
;;
esac

echo ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
echo o                   Country name                                    o
echo ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

echo Find network with country : $name
echo count CN country name
echo ----------------------------------------------------
more ./ip2country.csv | awk '{print $6 " " $7} ' FS=',' | sort | uniq -c |sed 's/"//g'
read -p "Please insert country : " name
echo Find network with country : $name
dyn_test=""
dyn_name=GEO_"$name"

if  [ "$simulate" -eq "0"  ]; then
	echo "No simulate"
else
	echo "Simulating"
fi

if  [ "$simulate" -eq "0"  ]; then
	dynamic_objects -do $dyn_name > /dev/null
	echo Delete Dynamic Object $dyn_name
fi

printf '%s\n' "dynamic_objects -do $dyn_name"


if  [ "$simulate" -eq "0"  ]; then
	dynamic_objects -n $dyn_name > /dev/null
	echo Add Dynamic Objekt $dyn_name
fi

printf '%s\n' "dynamic_objects -n $dyn_name"


if [ "$name" != "" ]
   then
     more ./ip2country.csv |grep $name > _temp.txt
     declare -i index
     index=0
     for i in $(cat _temp.txt ); do
       ip123=$( echo $i |grep $name  | awk '{print $1}' FS=',' |sed 's/"//g')
       net123=$( echo $i |grep $name  | awk '{print $2}' FS=',' |sed 's/"//g')
       if [ "$ip123" != "" ]
         then

             index=$index+1

             dec2ip $ip123
             dynamic1=$ip1

             dec2ip $net123
             dynamic2=$ip1
             
             printf '%s\n' "dynamic_objects -o $dyn_name -r $dynamic1 $dynamic2 -a"
			 if  [ "$simulate" -eq "0"  ]; then
				dynamic_objects -o $dyn_name -r $dynamic1 $dynamic2 -a > /dev/null
			 fi
       fi
     done
fi
