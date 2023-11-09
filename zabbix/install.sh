#!/bin/bash
# Autor: Bruno Honorato da Fonseca
# Data da criação: 08/11/2023
# Script para instalação do ZabbixServer 6 no Debian 12 (Bookworm)
# Script deve ser executado com usuário root

#--------------------Funções--------------------#
    # Função para gerar senhas
        function mkpass(){
            tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 ; echo ''
        }

#--------------------Verifica Usuário--------------------#
    if [ $(id -u) == "0" ] && [ "$(lsb_release -rs)" == "12" ]
	    then
		    echo -e "O usuário é Root, continuando com o script..."
		    echo -e "Distribuição é Debian12(Bookworm), continuando com o script...\n"
		    sleep 5
	    else
		    echo -e "Usuário não é Root ou a Distribuição não é Debian12(Bookworm)"
		    echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		    echo -e "Execute novamente o script para verificar o ambiente."
		    exit 1
    fi

#--------------------Variáveis--------------------#

    LOG=/tmp/zabbix.log;
    PARAM=/tmp/parametros.conf;
    PASSZBX=$(mkpass);
    PASSROOT=$(mkpass);

echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
#--------------------Preparando sistema--------------------#
    
    echo -e "Atualizando o sistema... Aguarde";
    apt update &>>$LOG;
    apt upgrade -y &>>$LOG;
    echo -e "Instalando Utilitários e Dependencias... Aguarde"
    apt install iperf3 ifupdown2 net-tools iotop nethogs nmon mtr git curl gnupg2 ca-certificates lsb-release debian-archive-keyring -y &>>$LOG;
    curl -fsSL https://rclone.org/install.sh | bash >> $LOG 2>&1;
    #Ajuste o PATH do sistema
    export PATH=$PATH'/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/bin' &>>$LOG;
    echo -e "Utilitários e dependencias instalados\n"

#--------------------Nginx--------------------#

    echo -e "Adicionando repositório do Nginx... Aguarde"
    echo "deb http://nginx.org/packages/debian bookworm nginx" \ | tee /etc/apt/sources.list.d/nginx.list &>>$LOG;
    curl -fsSL https://nginx.org/keys/nginx_signing.key  | apt-key add - >> $LOG 2>&1;
    apt update -y &>>$LOG;
    echo -e "Instalando o Nginx"
    apt install nginx -y &>>$LOG;
    echo -e "Nginx instalado\n"

#--------------------Zabbix--------------------#
    
    echo -e "Adicionando reposítórios do zabbix...Aguarde"
    wget -P /tmp/ https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian12_all.deb &>>$LOG
    dpkg -i /tmp/zabbix-release_6.4-1+debian12_all.deb &>>$LOG
    apt update -y &>>$LOG
    echo -e "Instalando Zabbix Server 6.4"
    apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent -y &>>$LOG
    echo -e "Zabbix instalado!!!\n"

#--------------------MariaDB--------------------#
    echo -e "Iniciando instalação do MariaDB"
    apt install mariadb-server mariadb-client -y  &>>$LOG
    systemctl enable --now mariadb.service &>>$LOG
    echo -e "MariaDB instalado"

    #Criando configurações para o zabbix;
    mysql -u root -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;" &>>$LOG
    mysql -u root -e "create user zabbix@localhost identified by '"$PASSZBX"'" &>>$LOG
    mysql -u root -e "grant all privileges on zabbix.* to zabbix@localhost" &>>$LOG
    mysql -u root -e "set global log_bin_trust_function_creators = 1;flush privileges;" &>>$LOG
    #Criando estrutura do Zabbix
    zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uroot zabbix &>>$LOG
    mysql -u root -e "set global log_bin_trust_function_creators = 0;" &>>$LOG
    mysql -u root -e "alter user 'root'@'localhost' identified by '"$PASSROOT"'" &>>$LOG

    #Salva as credenciais em um arquivo
    echo > $PARAM
    echo -e "Senha usuário zabbix mariadb:$PASSZBX" &>> $PARAM
    echo -e "Senha usuário root mariadb:$PASSROOT" &>> $PARAM

    mv $PARAM /etc/zabbix/ -f
#--------------------Estrutura--------------------#
    #Criando estrutura do zazbbix no banco de dados
echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
