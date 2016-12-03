#!/bin/sh

eval `dbus export ssserver`

if [ "$ssserver_enable" == "1" ];then
	sh /koolshare/ssserver/ssserver.sh restart
else
	sh /koolshare/ssserver/ssserver.sh stop
fi
