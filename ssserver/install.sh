#! /bin/sh
cd /tmp
cp -rf /tmp/ssserver/bin/* /koolshare/bin
cp -rf /tmp/ssserver/ssserver /koolshare/
cp -rf /tmp/ssserver/scripts/* /koolshare/scripts/
cp -rf /tmp/ssserver/webs/* /koolshare/webs/
cp -rf /tmp/ssserver/res/* /koolshare/res/
if [ ! -L "/koolshare/init.d/S10Softcenter.sh" ]; then
	ln -sf /koolshare/ssserver/ssserver.sh /koolshare/init.d/S66ssserver.sh
fi

cd /
rm -rf /tmp/ssserver* >/dev/null 2>&1


chmod 755 /koolshare/bin/ss-server
chmod 755 /koolshare/ssserver/*
chmod 755 /koolshare/bin/*
chmod 755 /koolshare/init.d/*
chmod 755 /koolshare/scripts/*

