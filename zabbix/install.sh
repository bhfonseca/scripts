#!/bin/bash
# Autor: Bruno Honorato da Fonseca
# Data da criação: 08/11/2023
# Ultima alteração: 10/11/2023
# Script para instalação do ZabbixServer 6.4 e Grafana no Debian 12 (Bookworm)
# Script deve ser executado com usuário root

#--------------------Funções--------------------#
    clear
    # Função para gerar senhas
        function mkpass(){
            tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 ; echo ''
        }
#--------------------Inicio--------------------#
    echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n"  &>>$LOG
    HORAINICIAL=$(date +%T)
#--------------------Verifica Sistema--------------------#
    if [ "$(lsb_release -cs)" = "bookworm" ]; then
        echo "O sistema é Debian 12. Executando o script..."
    else
        echo "Este script é destinado apenas ao Debian 12. O sistema atual é $(lsb_release -rcis)."
        exit 1
    fi
#--------------------Verifica Usuário--------------------#

    if [ $(id -u) == "0" ] 
    then
		echo -e "O usuário é Root, continuando com o script..."
		sleep 5
	else
		echo -e "Script deve ser executado como root"
		exit 1
    fi

#--------------------Variáveis--------------------#

    LOG=/tmp/zabbix.log
    PARAM=/tmp/parametros.conf
    PASSZBX=$(mkpass)
    PASSROOT=$(mkpass)


#--------------------Preparando sistema--------------------#
    
    echo -e "Atualizando o sistema... Aguarde"
    apt update &>>$LOG
    apt upgrade -y &>>$LOG
    apt autoremove -y &>>$LOG
    apt autoclean &>>$LOG
    echo -e "Instalando Utilitários e Dependencias... Aguarde"
    apt install ifupdown2 net-tools iotop nethogs nmon mtr curl gnupg2 ca-certificates lsb-release debian-archive-keyring -y &>>$LOG 
    #Ajusta o PATH do sistema
    export PATH=$PATH'/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/bin' &>>$LOG
    echo -e "Utilitários e dependencias instalados\n"

#--------------------Backup--------------------#

    echo -e "Instalando ferramentas para backup\n"
    apt install rsync -y &>>$LOG
    curl -fsSL https://rclone.org/install.sh | bash >> $LOG 2>&1;

#--------------------Nginx--------------------#

    echo -e "Instalando o Nginx"
    apt install nginx-full -y &>>$LOG;
    echo -e "Nginx instalado\n"
    rm /etc/nginx/sites-enabled/*
    rm /var/www/html/*

#--------------------MariaDB--------------------#
    echo -e "Iniciando instalação do MariaDB"
    apt install mariadb-server mariadb-client -y  &>>$LOG
    systemctl enable --now mariadb.service &>>$LOG
    echo -e "MariaDB instalado"

    #Criando configurações para o zabbix;
    echo -e "Criando usuários no banco"
    sleep 2
    mysql -u root -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;" &>>$LOG
    #-mysql -u root -e "create user zabbix";
    mysql -u root -e "create user 'zabbix'@'localhost' identified by '"$PASSZBX"';" &>>$LOG
    mysql -u root -e "grant all privileges on zabbix.* to zabbix@localhost;" &>>$LOG
    mysql -u root -e "set global log_bin_trust_function_creators = 1;flush privileges;" &>>$LOG
    mysql -u root -e "alter user 'root'@'localhost' identified by '"$PASSROOT"'" &>>$LOG
    echo -e "Usuários criados\n"

    #Salva as credenciais em um arquivo
    echo > $PARAM
    echo -e "Senha usuário zabbix mariadb:$PASSZBX" &>> $PARAM
    echo -e "Senha usuário root mariadb:$PASSROOT" &>> $PARAM

#--------------------Zabbix--------------------#
    
    echo -e "Adicionando reposítórios do zabbix...Aguarde"
    wget -P /tmp/ https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian12_all.deb &>>$LOG
    dpkg -i /tmp/zabbix-release_6.4-1+debian12_all.deb &>>$LOG
    apt update -y &>>$LOG
    echo -e "Instalando Zabbix Server 6.4"
    apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent -y &>>$LOG
    echo -e "Zabbix instalado!!!\n"

    #Criando estrutura do Zabbix
    echo -e "Criando estrutura do banco de dados do zabbix, esse processo pode demorar um pouco"
    echo -e "Por favor aguarde"
    zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p$PASSZBX zabbix &>>$LOG
    mysql -u root -p$PASSROOT -e "set global log_bin_trust_function_creators = 0;" &>>$LOG
    echo -e "Estrutura criada\n"

    echo -e "Criando arquivo zabbix_server.conf"
   { echo "LogFile=/var/log/zabbix/zabbix_server.log"
     echo "LogFileSize=0"
     echo "PidFile=/run/zabbix/zabbix_server.pid"
     echo "SocketDir=/run/zabbix"
     echo "DBName=zabbix"
     echo "DBUser=zabbix"
     echo "DBPassword=$PASSZBX"
     echo "ListenPort=10051"
     echo "SNMPTrapperFile=/var/log/snmptrap/snmptrap.log"
     echo "Timeout=4"
     echo "FpingLocation=/usr/bin/fping"
     echo "Fping6Location=/usr/bin/fping6"
     echo "LogSlowQueries=3000"
     echo "StatsAllowedIP=127.0.0.1"   
     }> /etc/zabbix/zabbix_server.conf
    
    echo -e "Aplicando configurações adicionais"
    #Alterando porta e server name
    sudo sed -i 's/^#//' /etc/zabbix/nginx.conf
    sed -i 's/listen[[:space:]]*8080;/listen 81;/' /etc/zabbix/nginx.conf
    sed -i 's/server_name[[:space:]]*example\.com;/server_name zabbix;/' /etc/zabbix/nginx.conf
    echo -e "Zabbix instalado\n"

    #Movendo parametros
    mv $PARAM /etc/zabbix/ -f

#--------------------Grafana--------------------#

    echo -e "Instalando Grafana"
    apt install -y adduser libfontconfig1 musl &>>$LOG
    wget https://dl.grafana.com/enterprise/release/grafana-enterprise_10.2.0_amd64.deb &>>$LOG
    dpkg -i grafana-enterprise_10.2.0_amd64.deb &>>$LOG
    echo -e "Instalando plugin para o zabbix"
    grafana-cli plugins install alexanderzobnin-zabbix-app &>>$LOG
    echo -e "Grafana instalado\n"

#--------------------Serviços--------------------#

    echo -e "Reiniciando serviços\n"
    systemctl restart zabbix-server zabbix-agent nginx php8.2-fpm grafana-server &>>$LOG
    systemctl enable zabbix-server zabbix-agent nginx php8.2-fpm grafana-server &>>$LOG

#--------------------Finalização--------------------#
	HORAFINAL=$(date +%T)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
    echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n"  &>>$LOG
    echo -e "Para acessar o Zabbix abra no navegador http://$(hostname -I | awk '{print $1}'):81"
    echo -e "Para acessar o Grafana abra no navegador http://$(hostname -I | awk '{print $1}'):3000"
    echo -e "Senha para acesso ao banco de dados esta localizada em /etc/zabbix/parametros.conf"
    echo -e "Pressione <Enter> para concluir o processo."
    read
    exit 1    
