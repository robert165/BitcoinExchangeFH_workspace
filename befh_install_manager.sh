#!/bin/bash
#	liu,yu 2018-05-22 
#	V 1.0.0
#描述：部署工程Coin-Crawler的docker和添加volume，步骤如下：
#1.地址：显示当前IP等信息，询问是否更改(未完成)
#2.用户：是否切换或创建用户，是则创建并切换到新用户（未完成）
#3.询问安装cpu模式或gpu模式的docker
#4.输入volume本地地址
#5.安装docker，gpu需要安装nvidia-docker
#6.编译.../BitcoinExchangeFH/docker/Dockerfile.BitcoinExchangeFH或.../BitcoinExchangeFH/docker/Dockerfile.BitcoinExchangeFH
#7.启动镜像，并加载volume
#
#   ../BitcoinExchangeFH_workspace 目录结构
#	|--data	#模型
#	|--BitcoinExchangeFH #代码
#	|--img	#检测数据
#
# 注意：
# 1.dockerfile中注明EXPOSE 8000端口号。
# 
echo "# 测试步骤：执行完脚本需要在新命令行执行的命令"
echo "# 1.cd Coin-Crawler/"
echo "# 2./workspace/Coin-Crawler/bin/deep_ocr_id_card_reco --img /workspace/img/xuanye.jpeg             --debug_path /tmp/debug             --cls_sim /workspace/data/chongdata_caffe_cn_sim_digits_64_64             --cls_ua /workspace/data/chongdata_train_ualpha_digits_64_64
"

IMAGENAME=bitcoinexchangefh_dockerimage
IMAGETAGCPU=py36
IMAGETAGGPU=py36
HOSTPORT_FLASK=8021
HOSTPORT_MYSQL=8022
OUTPORT_FLASK=5000
OUTPORT_MYSQL=3306
MYSQLIMAGENAME=mysql
MYSQLIMAGETAG=57
MYSQLCONTAINERNAME=kwsmysql
MYSQLCONTAINERNAMELINK=db
MYSQL_ROOT_PASSWORD=kws123

###################################
##	地址：显示当前IP等信息，询问是否更改
###################################



###################################
##	用户：是否切换或创建用户，是则创建并切换到新用户
###################################
#echo -n "Enter your name:"
#read name
#su - $name <<LOGEOF
#pwd;
#LOGEOF

echo "####################################################"
echo "##						##"
echo "##	询问安装cpu模式或gpu模式的docker		##"
echo "##						##"
echo "####################################################"
FLAG=1
CHIPMODE="cpu"



echo "####################################################"
echo "##						##"
echo "##	输入volume本地地址连接到docker		##"
echo "##						##"
echo "####################################################"
FLAGVOL=1
while [ $FLAGVOL -eq 1 ] 
do
	echo "Please input volume's path."
	echo "For Example:/home/$USER/PythonProjects/BitcoinExchangeFH/BitcoinExchangeFH_workspace "
	echo -n "The Volume Path is:"
	read VOLUMEPATH
	if [ ! -d "$VOLUMEPATH" ]; then
		
 		echo "There is no Path called '$VOLUMEPATH'."
		FLAGVOL=1
	else
		if [[ "$VOLUMEPATH" =~ /$ ]]; 
		then
			echo "There should be no '/' at the end of Path '$VOLUMEPATH'."
			FLAGVOL=1
		else
			echo -n "Comfirm the path (yes|no):"
			read cf
			if [ "$cf"x = "yes"x ];
			then
				FLAGVOL=0
			else
		    		FLAGVOL=1
			fi

		fi
		
	fi
done








echo "####################################################################"
echo "##								##"
echo "##	安装docker，gpu模式还需要安装nvidia-docker		##"
echo "##								##"
echo "####################################################################"
## cpu
if [ $FLAGDK -eq 0 ];
then
	# step 1: 安装必要的一些系统工具
	sudo apt-get remove docker docker-engine docker-ce docker.io
	apt-get update
	apt-get upgrade
	sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
	# step 2: 安装GPG证书
	curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
	# Step 3: 写入软件源信息
	sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
	# Step 4: 更新并安装 Docker-CE
	sudo apt-get -y update
	sudo apt-get -y install docker-ce
	#建立 docker 组：
	sudo groupadd docker
	#将当前用户加入 docker 组：
	sudo gpasswd -a ${USER} docker
	if [ $? -eq 0 ];
	then
		echo "Docker is Installed!"
	fi
else
	echo "Docker is Installed!"
fi


echo

echo "####################################################################"
echo "##								##"
echo "##		gpu需要安装nvidia-docker			##"
echo "##								##"
echo "####################################################################"
# 装显卡驱动？装CUDNN？
## gpu
if [ "$CHIPMODE"x = "gpu"x -a $FLAGNVDK -eq 0 ];
then
	curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  	sudo apt-key add -
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
	curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  	sudo tee /etc/apt/sources.list.d/nvidia-docker.list
	sudo apt-get update
	# Test nvidia-smi 验证是否安装成功
	sudo nvidia-docker run --rm nvidia/cuda nvidia-smi
	if [ $? -eq 0 ];
	then
		echo "Nvidia-Docker is Installed."
	fi
else
	echo "Nvidia-Docker is Installed."
fi

echo
echo "############################################################################"
echo "##									##"
echo "##	检测是否有BitcoinExchangeFH_DockerImage:py27镜像	##"
echo "##	编译.../BitcoinExchangeFH/docker/Dockerfile.BitcoinExchangeFH		##"
echo "##	或.../BitcoinExchangeFH/docker/Dockerfile.BitcoinExchangeFH		##"
echo "##									##"
echo "############################################################################"

# docker提速
#sudo docker --registry-mirror=https://registry.docker-cn.com daemon
if [ "$CHIPMODE"x = "cpu"x ];
then
	imagetagname=sudo docker images | awk  '$1=="$IMAGENAME"{print  $1":"$2}' | grep "$IMAGENAME:$IMAGETAGCPU"
	echo $imagetagname
	if [ "$imagetagname"x != "$IMAGENAME:$IMAGETAGCPU"x  ];
	then
		#sudo docker build -t $IMAGENAME:$IMAGETAGCPU -f ${VOLUMEPATH}/Dockerfile.BitcoinExchangeFH ${VOLUMEPATH}
		sudo docker build -t $IMAGENAME:$IMAGETAGCPU -f ${VOLUMEPATH}/docker/Dockerfile.BitcoinExchangeFH ${VOLUMEPATH}/docker
	else 
		echo " dockerfile for cpu is aready installed!"
	fi
fi


#sudo docker build -t $MYSQLIMAGENAME:$MYSQLIMAGETAG -f ${VOLUMEPATH}/docker/Dockerfile.Mysql ${VOLUMEPATH}/docker



#描述：删除顽固的None镜像
#sudo docker ps -a  | awk '{print $1 }'|xargs docker stop 
#sudo docker ps -a  | awk '{print $1 }'|xargs docker rm
sudo docker ps -a | grep "Exited" | awk '{print $1 }'|xargs docker stop 
sudo docker ps -a | grep "Exited" | awk '{print $1 }'|xargs docker rm
#sudo docker images|grep none|awk '{print $3 }'|xargs docker rmi


echo
echo "############################################################################"
echo "##									##"
echo "##	显示镜像IP，端口号，镜像名，数据地址，各种命令			##"
echo "##									##"
echo "############################################################################"

if [ "$CHIPMODE"x = "cpu"x ];
then
	echo "镜像名称:$IMAGENAME:$IMAGETAGCPU"
fi

local_host="`hostname --fqdn`"
local_ip=`host $local_host 2>/dev/null | awk '{print $NF}'`
echo "主机IP:  $local_ip"
echo "主机端口号:$HOSTPORT，对外端口号:$OUTPORT"
echo "# 测试步骤：执行完脚本需要在新命令行执行的命令"
echo "# 1.cd befh/"



echo
echo "############################################"
echo "##	运行，start镜像，并加载volume	##"
echo "############################################"

#-p 3306:3306：将容器的3306端口映射到主机的3306端口。
#-v $PWD/conf/my.cnf:/etc/mysql/my.cnf：将主机当前目录下的 conf/my.cnf挂载到容器
#-v $PWD/logs:/logs：将主机当前目录下的logs目录挂载到容器的/logs
#-v $PWD/data:/mysql_data：将主机当前目录下的data目录挂载到容器的/mysql_data
#-e MYSQL_ROOT_PASSWORD=123456：初始化root用户的密码


#sudo mkdir -p ${VOLUMEPATH}/mysql/{conf,logs,data}
#sudo docker run --name $MYSQLCONTAINERNAME -p $HOSTPORT_MYSQL:$OUTPORT_MYSQL -v ${VOLUMEPATH}/mysql/conf:/etc/mysql/conf.d -v ${VOLUMEPATH}/mysql/logs:/logs -v ${VOLUMEPATH}/mysql/data:/var/lib/mysql  -e MYSQL\_ROOT\_PASSWORD=$MYSQL_ROOT_PASSWORD  -d  $MYSQLIMAGENAME:$MYSQLIMAGETAG  


# Run the app, mapping your machine’s $HOSTPORT to the container’s published port $OUTPORT using -p:
if [ "$CHIPMODE"x = "cpu"x ];
then
	#sudo docker run -it --link=$MYSQLCONTAINERNAME:$MYSQLCONTAINERNAMELINK  --volume ${VOLUMEPATH}:/workspace  -p $HOSTPORT_FLASK:$OUTPORT_FLASK  $IMAGENAME:$IMAGETAGCPU
	#sudo docker run -it --link=$MYSQLCONTAINERNAME:$MYSQLCONTAINERNAMELINK --volume ${VOLUMEPATH}:/workspace  -p $HOSTPORT_FLASK:$OUTPORT_FLASK  $IMAGENAME:$IMAGETAGCPU /bin/bash
	sudo docker run -it  --volume ${VOLUMEPATH}:/workspace  -p $HOSTPORT_FLASK:$OUTPORT_FLASK  $IMAGENAME:$IMAGETAGCPU
	sudo docker run -it  --volume ${VOLUMEPATH}:/workspace  -p $HOSTPORT_FLASK:$OUTPORT_FLASK  $IMAGENAME:$IMAGETAGCPU /bin/bash
	echo
fi




