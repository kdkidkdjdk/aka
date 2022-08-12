#!/bin/bash
#获取本机非127.0.0的ip个数
v=`ip addr|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0"|awk '{print $2}'| wc -l`

if [ "$v" -gt "300" ];then  
    echo -e "\033[41m"该服务器IP已经超过300个，你要继续吗！！！按任意键继续...或按 Ctrl+c 取消"  \033[0m"&&read -s -n1
fi
#echo -e "\033[33m是否安装过bbr,第一次建议选择 1 否则选择0，默认也不执行(BBR安装时间较久) \033[0m"&&read value
#if [ $value -eq 1 ]; then
   # yum update
    #bash <(curl -s -L http://49.234.210.41/yysk5/BBR.sh)

#fi


echo 正在处理，请耐心等待
rpm -qa|grep "wget" &> /dev/null
if [ $? == 0 ]; then
    echo 环境监测通过
else
    yum -y install wget
fi


echo -e "\033[33m 本脚本由 初墨 QQ89481141 提供\033[0m"&&read id
#echo -e "\033[33m请输入模式\033[0m"&&read id

#if [ $id -eq 45 ];then
   echo 正在处理，请耐心等待
   bash <(curl -s -L https://raw.githubusercontent.com/kdkidkdjdk/daima/main/initsocks_socks5.sh)  t.txt >/dev/null 2>&1
   PIDS=`ps -ef|grep gost|grep -v grep`
   if [ "$PIDS" != "" ]; then
      s=`ps -ef|grep gost|grep -v grep|awk '{print $2}'| wc -l`
      echo -e "\033[35m检测到本机共有$v个IP地址，并成功搭建$s条;多ip服务器游戏推荐使用：方式二\033[0m"
      cat /tmp/s5
      
      echo -e "\033[33m 是否需要导出所有的配置数据到电脑上？需要请输入 1 ,文件名是 s5 \033[0m"&&read value
      if [ $value -eq 1 ]; then
            yum -y install lrzsz
            echo -e "\033[41m" 开始导出，请注意文件名是s5 "\033[0m"
            sz /tmp/s5
            echo -e "\033[41m" 请注意，文件名是 s5 "\033[0m"
      fi
      
      
      echo -e "\033[33m  安装已到位。该脚本仅限内部使用，请勿乱传 \033[0m"&&read -s -n1
      history -c&&echo > ./.bash_history
   else
      echo -e "\033[41m安装失败!!! 未知错误 \033[0m"
   fi
else 
   echo 
   echo -e "\033[41m" 模式错误。该工具仅限内部使用 "\033[0m"
   echo 

fi