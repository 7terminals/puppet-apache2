#!/bin/sh

# Creates a chroot Apache + PHP server 

CHROOT_DIR=/webserver

#Create CHROOT_DIR if doesn't exists
if ! [ -d $CHROOT_DIR ] 
then
        mkdir -p $CHROOT_DIR
fi

#
# Find all files required for running the webserver and php modules and move them into the chroot
#

for i in `rpm -ql <%= webserver_packages %>`
do
    if ! [ -e $CHROOT_DIR/$i ]
	then
		cp --parents -r $i $CHROOT_DIR
	fi
done 


#
# Rope in the dependencies
#

for i in $( ldd -v $CHROOT_DIR/usr/sbin/httpd | grep "=>" | awk -F "=>" '{ print $2 }' | awk '{ print $1 }' | grep "/" | sort | uniq ) 
do 
    if ! [ -e $CHROOT_DIR/$i ]
	then
		cp --parents -r  $i* $CHROOT_DIR
	fi
done

for i in $( ldd -v $CHROOT_DIR/usr/lib64/httpd/modules/* | grep "=>" | awk -F "=>" '{ print $2 }' | awk '{ print $1 }' | grep "/" | sort | uniq ) 
do
    if ! [ -e $CHROOT_DIR/$i ]
	then
		cp --parents -r  $i* $CHROOT_DIR
	fi
done

for i in $( ldd -v $CHROOT_DIR/usr/lib64/php/modules/* | grep "=>" | awk -F "=>" '{ print $2 }' | awk '{ print $1 }' | grep "/" | sort | uniq )
do
    if ! [ -e $CHROOT_DIR/$i ]
	then
		cp --parents -r  $i* $CHROOT_DIR
	fi
done


#
# Build the base layout required to run the CHROOT
#

#Check if directory is exists
if ! [ -d $CHROOT_DIR/tmp ]
then
	mkdir $CHROOT_DIR/tmp
fi

if ! [ -e $CHROOT_DIR/etc/resolv.conf ]
then
	cp --parents -r /etc/resolv.conf $CHROOT_DIR/
fi

if ! [ -e $CHROOT_DIR/etc/nsswitch.conf ]
then
	cp --parents -r /etc/nsswitch.conf $CHROOT_DIR/
fi

for i in `ls /lib64/libnss_*`
do
	if ! [ -e $i ]
	then
		cp --parents -r $i $CHROOT_DIR/
	fi
done

if ! [ -e  $CHROOT_DIR/etc/hosts ]
then
	cp --parents -r /etc/hosts $CHROOT_DIR/
fi

if ! [ -e $CHROOT_DIR/etc/localtime ]
then
	cp --parents -r /etc/localtime $CHROOT_DIR/
fi

if ! [ -e $CHROOT_DIR/etc/mime.types ]
then
	cp --parents -r /etc/mime.types $CHROOT_DIR/
fi

if ! [ -d $CHROOT_DIR/usr/share/zoneinfo ]
then
	cp --parents -r /usr/share/zoneinfo $CHROOT_DIR/
fi


USR_EXISTS=`grep "in-code:x:2001:2001:Apache:/var/www:/sbin/nologin" $CHROOT_DIR/etc/passwd | wc -l`
if [ $USR_EXISTS -eq 0 ]
then
	echo "in-code:x:2001:2001:Apache:/var/www:/sbin/nologin" > $CHROOT_DIR/etc/passwd
fi

GRP_EXISTS=`grep "in-code:x:2001:" $CHROOT_DIR/etc/group | wc -l`
if [ $GRP_EXISTS -eq 0 ]
then
	echo "in-code:x:2001:" > $CHROOT_DIR/etc/group
fi

if ! [ -d $CHROOT_DIR/dev ]
then
	mkdir $CHROOT_DIR/dev
fi

#Creating devices
if ! [ -e $CHROOT_DIR/dev/null ]
then
	mknod $CHROOT_DIR/dev/null c 1 3
fi

if ! [ -e $CHROOT_DIR/dev/urandom ]
then
	mknod $CHROOT_DIR/dev/urandom c 1 8
fi

if ! [ -e $CHROOT_DIR/dev/random ]
then
	mknod $CHROOT_DIR/dev/random c 1 9
fi	

#Check if loopback is present in host file
if [ `cat $CHROOT_DIR/etc/hosts | grep "127\.0\.0\.1" | wc -l` -eq 0 ]
then
	echo "127.0.0.1 $(hostname) " >> $CHROOT_DIR/etc/hosts
fi

#Check if home  where all the vhosts are housed exists
if ! [ -d $CHROOT_DIR/home ]
then
	mkdir $CHROOT_DIR/home
fi