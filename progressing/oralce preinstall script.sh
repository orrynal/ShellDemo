#!/bin/bash

# Oracle initial environment script
_oldhname=`hostname`

_newhname=($1 $2)

_scahname=rac-scan

_domhname=.domain.com

_pubhaddr=($3 $4)
_prihaddr=($5 $6)
_viphaddr=($7 $8)
_scahaddr=$9
_oraclsid=($10 $11)
_servicid=$12

_viphname=(${_newhname[0]}-vip ${_newhname[1]}-vip)
_prihname=(${_newhname[0]}-priv ${_newhname[0]}-priv)

# set hostname
setHostname() {
	cd /etc/sysconfig/
	mv network network_back
	
	sed 's/'$_oldhname'/'$_newhname'/' network_back >network
	
	hostname $_newhname

}

setHosts() {
for t in pub vip priv scan
do
	case $t in
	        # 此处的值也为数组成员数量,如上面为3个成员，那么此处就是0-2(0、1、2)三个数
	        pub)
	        for i in ${_pubhaddr[@]}
	        do
	        	for j in ${_newhname[@]}
	        	do
	        		echo "$i	$_newhname$_domhname $_newhname"
	        	done
	        done|sed '2,3d' >> /etc/hosts
	        ;;
	        priv)
	        for i in ${_prihaddr[@]}
	        do	   
	        	for j in ${_prihname[@]}
	        	do	             
	        		echo "$i	$_prihname$_domhname $_prihname"
	        	done
	        done|sed '2,3d' >> /etc/hosts
	        ;;	        
	        vip)
	        for i in ${_viphaddr[@]}
	        do	  
	        	for j in ${_viphname[@]}
	        	do	 	              
	        		echo "$i	$_viphname$_domhname $_viphname"
	        	done
	        done|sed '2,3d' >> /etc/hosts
	        ;;
	        scan)
	        echo "$_scahaddr	$_scahname$_domhname $_scahname">>/etc/hosts
	        ;;	        	        	        
	        *)
	        printf "*"
	        ;;
	esac

}


# set users and groups
addGroupUser()
{
	groupadd -g 501 oinstall
	groupadd -g 502 dba
	groupadd -g 503 oper
	groupadd -g 504 asmadmin
	groupadd -g 505 asmdba
	groupadd -g 506 asmoper
	
	
	useradd -u 501 -g oinstall -G asmadmin,asmdba,asmoper grid
	useradd -u 502 -g oinstall -G dba,oper,asmdba oracle
	
	# set user password
	for u in grid oracle
	do
		# set password is "oracle"
		echo "oracle" |passwd --stdin $u
	done
}

# set open file and proc

setLimits() {
	cat >>/etc/security/limits.conf <<EOF
	grid soft nproc  2047
	grid hard nproc  16384
	grid soft nofile 1024
	grid hard nofile 65536
	 
	oracle soft nproc  2047
	oracle hard nproc  16384
	oracle soft nofile 1024
	oracle hard nofile 65536
	
	EOF
}


# 32bit or 64bit
for i in `uname -a|grep -i x86_64`
do 
	if [ "$i" = "x86_64" ]
	then 
		echo 64
	elif [ "$i" = "i386" ]
	then
		echo 32
	fi
done|grep -v ^$|sort -u>._sysarch.log

_sysarch=`cat ._sysarch.log`

echo system is running $_sysarch arch

setSecurityLogin() {
	if [ "$_sysarch" = "x86_64" ]
	then 
		echo "system is running in $_sysarch mode"
		cat >> /etc/pam.d/login <<EOF
		session    required     /lib64/security/pam_limits.so
		session    required     pam_limits.so
		EOF
	elif [ "$_sysarch" = "i386" ]
	then
		echo "system is running in $_sysarch mode"
		cat >> /etc/pam.d/login <<EOF
		session    required     pam_limits.so
		EOF
	fi 
}

case $_sysarch in
        # 此处的值也为数组成员数量,如上面为3个成员，那么此处就是0-2(0、1、2)三个数
        32|64)
        printf "     %s" "${_sysarch}位系统"
        printf "\n"
				writeLogin
        ;;
        *)
        printf "*"
        ;;
esac

rm -f ._sysarch.log


# set profile

setProfile() {
	cat >> /etc/profile <<EOF
	 
	if[ $USER="oracle" ] || [ $USER="grid" ];then
	 if[ $SHELL="/bin/ksh" ];then
		 ulimit -p 16384
		 ulimit -n 65536
	 else
		 ulimit -u 16384 -n 65536
	 fi
	 	umask022
	 fi
	
	EOF
 
}

# set csh
setCsh() {
	cat >> /etc/csh.login <<EOF
	 
	if（ $USER="oracle" || $USER="grid" )then
	 limit maxproc 16384
	 limit descriptors 65536
	 endif
	EOFCSH
	EOF
}


# set grid profile
setGridProfile() {
	userdir=`cat /etc/passwd|grep -i grid|awk -F : '{print $6}'`
	export userdir
	
	cat >> $userdir/.bash_profile << EOF
	#grid .bash_profile
	export GRID_HOME=/u01/app/11.2.0/grid
	export ORACLE_HOME=/u01/app/11.2.0/grid
	export PATH=$GRID_HOME/bin:$GRID_HOME/OPatch:/sbin:/bin:/usr/sbin:/usr/bin
	 
	export ORACLE_SID=+ASM1
	export LD_LIBRARY_PATH=$GRID_HOME/lib:$GRID_HOME/lib32
	 
	export ORACLE_BASE=/u01/app/grid
	export ORA_NLS10=$ORACLE_HOME/nls/data
	#export NLS_LANG="Simplified Chinese"_China.ZHS16GBK
	
	EOF

}

# set oracle profile
setOracleProfile() {
	userdir=`cat /etc/passwd|grep -i oracle|awk -F : '{print $6}'`
	export userdir
	
	cat >> $userdir/.bash_profile << EOF
	export TMP=/tmp; 
	export TMPDIR=$TMP;  
	
	export ORACLE_BASE=/u01/app/oracle 
	export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
	export ORACLE_SID=sxri1
	  
	export ORACLE_TERM=xterm 
	export PATH=/usr/sbin:$PATH 
	export PATH=$ORACLE_HOME/bin:$PATH
	export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
	export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
	export NLS_DATE_FORMAT="yyyy-mm-dd  HH24:MI:SS"
	#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
	
	
 	EOF
}
