#!/bin/bash
# Authors : Maxime POUVREAU, Benjamin CALVET
# Creative Commons, Tous droits réservés
#
# Ce script constitue l'ensemble des fonctions de l'application WAN
# Le Script principal renvoi en arg 1 : le type d'action , en arg 2 : l'ip et en arg 3 : le temps de ban.
LOG=logban
if [ ! -w $LOG ] ; then
	touch $LOG
	chmod 644 $LOG
fi

case $1 in
	"1")
	iptables -A PREROUTING -t mangle -d $2 -j DROP
	iptables -A PREROUTING -t mangle -s $2 -j DROP
	echo "$2" >> $LOG
	(sleep "$3"m && iptables -D PREROUTING -t mangle -d $2 -j DROP) &
	(sleep "$3"m && iptables -D PREROUTING -t mangle -s $2 -j DROP) &
	(sleep "$3"m && sed -i "/$2/d" $LOG) &
	;;

	"2")
	iptables -A PREROUTING -t mangle -d $2 -j DROP
	iptables -A PREROUTING -t mangle -s $2 -j DROP
	echo "$2" >> $LOG
	;;

	"3")
	ips=($(cat $LOG | tr ' ' '\n'))
	nb=$(wc -l $LOG | awk '{print $1}')
	echo ${ips[0]}
	echo ${ips[1]}
	echo ${ips[2]}
	exec 3>&1
	ip=$(dialog --title "IP A DEBANNIR" --menu "" 0 0 0 $(for ((n=0; n <= $nb-1; n++));do echo "${ips[$n]} !"; done) 2>&1 1>&3)
	exec 3>&-
	echo $ip
	iptables -D PREROUTING -t mangle -d $ip -j DROP
	iptables -D PREROUTING -t mangle -s $ip -j DROP
	sed -i "/$ip/d" $LOG
	;;

	"4")
	for ip in $(cat $LOG) ; do
		iptables -D PREROUTING -t mangle -d $ip -j DROP
		iptables -D PREROUTING -t mangle -s $ip -j DROP
		sed -i "/$ip/d" $LOG
	done
	;;

	"5")
	dialog --aspect 0 --clear --textbox $LOG 0 0
	;;
esac
