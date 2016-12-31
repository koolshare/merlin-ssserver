#!/bin/sh

# ====================================变量定义====================================
# 版本号定义
version="1.8"

# 导入skipd数据
eval `dbus export ssserver`

# 引用环境变量等
source /koolshare/scripts/base.sh


# kill first
stop_ssserver(){
	killall ss-server
}

# start ssserver
start_ssserver(){
mkdir -p /jffs/ss/ssserver

	[ $ssserver_ota -ne 1 ] && ARG_OTA="" || ARG_OTA="-A";
	[ $ssserver_udp -ne 1 ] && ARG_UDP="" || ARG_UDP="-u";
	if [ "$ssserver_obfs" == "http" ];then
		ARG_OBFS="--obfs http"
	elif [ "$ssserver_obfs" == "tls" ];then
		ARG_OBFS="--obfs tls"
	else
		ARG_OBFS=""
	fi

	cat > /koolshare/ssserver/ss.json <<-EOF
	{
	    "server":["[::0]", "0.0.0.0"],
	    "server_port":$ssserver_port,
	    "local_address":"0.0.0.0",
	    "local_port":1079,
	    "password":"$ssserver_password",
	    "timeout":$ssserver_time,
	    "method":"$ssserver_method",
	    "fast_open":false
	}
	EOF
	
	ss-server -c /koolshare/ssserver/ss.json $ARG_UDP $ARG_OTA $ARG_OBFS -f /tmp/ssserver.pid
}

open_port(){
	ifopen=`iptables -S -t filter | grep INPUT | grep dport |grep $ssserver_port`
	if [ -z "$ifopen" ];then
		iptables -t filter -I INPUT -p tcp --dport $ssserver_port -j ACCEPT
		iptables -t filter -I INPUT -p udp --dport $ssserver_port -j ACCEPT
	fi


	if [ ! -f /jffs/scripts/firewall-start ]; then
		cat > /jffs/scripts/firewall-start <<-EOF
		#!/bin/sh
		EOF
	fi
	fire_rule=$(cat /jffs/scripts/firewall-start | grep $ssserver_port)
	if [ -z "$fire_rule" ];then
		cat >> /jffs/scripts/firewall-start <<-EOF
			iptables -t filter -I INPUT -p tcp --dport $ssserver_port -j ACCEPT
			iptables -t filter -I INPUT -p udp --dport $ssserver_port -j ACCEPT
		EOF
	fi
}

close_port(){
	ifopen=`iptables -S -t filter | grep INPUT | grep dport |grep $ssserver_port`
	if [ ! -z "$ifopen" ];then
			iptables -t filter -D INPUT -p tcp --dport $ssserver_port -j ACCEPT
			iptables -t filter -D INPUT -p udp --dport $ssserver_port -j ACCEPT
	fi

	fire_rule=$(cat /jffs/scripts/firewall-start | grep $ssserver_port)
	if [ ! -z "$fire_rule" ];then
		sed -i "/$ssserver_port/d" /jffs/scripts/firewall-start >/dev/null 2>&1
	fi
}

case $ACTION in
start)
	if [ "$ssserver_enable" == "1" ];then
		logger "[软件中心]: 启动ss-server！"
		start_ssserver
		open_port
	else
		logger "[软件中心]: ss-server未设置开机启动，跳过！"
	fi
	;;
stop | kill )
	close_port	
	stop_ssserver
	;;
restart)
	close_port
	stop_ssserver
	start_ssserver
	open_port
	;;
*)
	echo "Usage: $0 (start|stop|restart)"
	exit 1
	;;
esac
