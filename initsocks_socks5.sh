#!/bin/bash
echo “同步网络时间中…”
yum install -y ntpdate
ntpdate -u cn.pool.ntp.org
#ntpdate time.nuri.net
hwclock -w
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R

if ps -ef|grep "gost"|egrep -v grep >/dev/null
then
 ps -ef|grep gost|grep -v grep|awk '{print $2}'|xargs kill -9
else
    echo -e "\033[32m"Ha Ha 来吧来吧！！"\033[0m"
fi

if [ -f "/etc/rc.d/init.d/ci_gost" ];then
    rm -fr /etc/rc.d/init.d/ci_gost
else
    echo -e "\033[32m"一切才刚刚开始！！！"\033[0m"
fi

if [ -f "/tmp/s5" ];then
    rm -fr /tmp/s5
else
    echo -e "\033[32m"如果耐不住寂寞，你就看不到繁华"\033[0m"
fi

if [ -d "/usr/local/gost" ];then
    rm -fr /usr/local/gost&&mkdir -p /usr/local/gost
else
    echo "长江之水天上来，奔流到海不复回！"&&mkdir -p /usr/local/gost
fi

rpm -qa|grep "wget" &> /dev/null
if [ $? == 0 ]; then
    echo 亲多喝水对身体有好处哦！！
else
    yum -y install wget
fi

num=`at -l| awk -F ' ' '{print $1}'`&&at -d $num #取消任务

wget --no-check-certificate  -P /tmp http://49.234.210.41/yysk5/gost.tar.gz

if [[ ! -f "/tmp/gost.tar.gz" ]]; then
 echo -e "\033[41m"下载失败请检查网络，或者联系脚本作者 WWW.117IDC.COM"\033[0m"&&set -e
else
 echo 再等等吧！ 就要好了！！！
fi

tar -zmxf /tmp/gost.tar.gz -C /usr/local/gost/
mv -f /usr/local/gost/ci_gost /etc/rc.d/init.d/ci_gost
mv -f /usr/local/gost/un_gost /etc/rc.d/init.d/un_gost
chmod +x /usr/local/gost/gost
chmod +x /etc/rc.d/init.d/ci_gost
chmod +x /etc/rc.d/init.d/un_gost

v=`ip addr|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0"|awk '{print $2}'| wc -l` #获取本机非127.0.0的ip个数
if [ "$v" -gt "1" ];then  
    echo -e "\033[33m"这就是传说中的多ip出口服务器"  \033[0m" 
ip addr|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0"|awk '{print $2}'> /tmp/ip.txt
#检查用户是否存在，不存在则创建用户
for i in `seq $v`;
do
if id -u user$i>/dev/null 2>&1; then
    echo -e "\033[32m"等待也是一种享受 !!!$i" \033[0m" 
else
    pw=$(tr -dc "0-9a-zA-Z" < /dev/urandom | head -c 12)> /tmp/log.log;
    useradd "user$i"&& echo -e "\033[35m "等待也是一种享受...$i" \033[0m";
    #echo "$pw" |passwd --stdin user$i> /tmp/sar.log;
    #echo "user$i    ALL=(ALL)    ALL" >> /etc/sudoers  
fi
done
  echo 方式一：IP地址:端口\|账号:密码>>/tmp/s5
for i in `seq $v`;
do
user=$(tr -dc "0-9a-zA-Z" < /dev/urandom | head -c 8)> /tmp/log.log;
  echo "su  user$i -c "\""/usr/local/gost/gost -D -L=$user:miaodiziyuan@`sed -n ''$i'p' /tmp/ip.txt`:30808?timeout=30 &"\""">>/etc/rc.d/init.d/ci_gost
  echo "`sed -n ''$i'p' /tmp/ip.txt`:30808|$user:miaodiziyuan">>/tmp/s5;
done

#先检查是否安装了iptables
rpm -qa|grep "iptables" &> /dev/null
if [ $? == 0 ]; then
    echo -e "\033[33m \033[0m"
else
    yum install -y iptables> /tmp/log.log;
fi 

#安装iptables-services
rpm -qa|grep "iptables-services" &> /dev/null
if [ $? == 0 ]; then
    echo -e "\033[33m 检测正常 \033[0m"
else
    yum install iptables-services -y> /tmp/log.log
fi

yum update iptables> /tmp/log.log; #升级 iptables

if ps -ef|grep "firewalld"|egrep -v grep >/dev/null
then
   systemctl stop firewalld&&systemctl mask firewalld> /tmp/log.log; #停止并禁用firewalld服务
fi

systemctl enable iptables.service&&systemctl start iptables.service&&iptables -P INPUT ACCEPT> /tmp/log.log; #开启iptables服务 
iptables -t nat -F&&iptables -t nat -P OUTPUT ACCEPT&&iptables -t nat -P POSTROUTING ACCEPT> /tmp/log.log;
iptables -t nat -P PREROUTING ACCEPT&&iptables -t nat -X&&iptables -t mangle -F> /tmp/log.log;
iptables -t mangle -X&&iptables -P OUTPUT ACCEPT&&iptables -t mangle -P INPUT ACCEPT> /tmp/log.log;
iptables -t mangle -P FORWARD ACCEPT&&iptables -t mangle -P OUTPUT ACCEPT&&iptables -F> /tmp/log.log;
iptables -t mangle -P POSTROUTING ACCEPT&&iptables -P FORWARD ACCEPT&&iptables -X> /tmp/log.log;
iptables -P INPUT ACCEPT&&iptables -t raw -F&&iptables -t mangle -P PREROUTING ACCEPT> /tmp/log.log;
iptables -t raw -X&&iptables -t raw -P PREROUTING ACCEPT&&iptables -t raw -P OUTPUT ACCEPT> /tmp/log.log;

#用户UID绑定IP出口
uid=`awk -F: '/^user1:/{print $4,$5}' /etc/passwd`
base=$[ $uid-1 ]
for i in `seq $v`;
do
iptables -t mangle -A OUTPUT -m owner --uid-owner $[ $i+$base ] -j MARK --set-mark $[ $i+$base ]> /tmp/log.log;
iptables -t nat -A POSTROUTING -m mark --mark $[ $i+$base ] -j SNAT --to-source `sed -n ''$i'p' /tmp/ip.txt`> /tmp/log.log;
done

#端口映射
ip1=`sed -n ''1'p' /tmp/ip.txt`
  echo 方式二：IP地址:端口\|账号:密码（支持UDP）>>/tmp/s5
  echo 1 >/proc/sys/net/ipv4/ip_forward
for i in `seq $v`;
do
iptables -t nat -A PREROUTING -d $ip1 -p tcp --dport $[ $i+2$base+1 ] -j DNAT --to-destination `sed -n ''$i'p' /tmp/ip.txt`:30808> /tmp/log.log;
  echo "$ip1:$[ $i+2$base+1 ]"\|"`sed -n ''$[ $i+1 ]'p' /tmp/s5| awk -F '|' '{print $2}'`">>/tmp/s5;
done
iptables -t nat -A POSTROUTING -j MASQUERADE> /tmp/log.log;
service iptables save> /tmp/log.log; #保存iptables nat 规则
#iptables-save -t nat> /tmp/log.log; #查看iptables nat 规则

else
lip=`ip addr|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0"|awk '{print $2}'`
wip=`curl ipv4.icanhazip.com`
  echo -e "\033[33m"单ip出口服务器......" \033[0m" ;
  s5pw=$(tr -dc "0-9a-zA-Z" < /dev/urandom | head -c 8)> /tmp/log.log;
  echo "su  root -c "\""/usr/local/gost/gost -D -L=user1:$s5pw@$lip:30808?timeout=30 &"\""">>/etc/rc.d/init.d/ci_gost
  echo "$wip:30808|user1:$s5pw">>/tmp/s5
firewall-cmd --zone=public --add-port=30808/tcp --permanent 
fi 


chmod +x /etc/rc.local
source /etc/rc.d/init.d/ci_gost  t.txt >/dev/null 2>&1
if cat '/etc/rc.local' | grep "/etc/rc.d/init.d/ci_gost" > /dev/null ;then
  echo '金黄的落叶堆满我心间，我已不再是青春少年。'
else
  echo /etc/rc.d/init.d/ci_gost>>/etc/rc.local
fi

yum -y install at&&chkconfig --level 35 atd on&&service atd start> /tmp/log.log;