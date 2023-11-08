#!/bin/bash
#Script para instalação do ZabbixServer 6 no Debian 12 (Bookworm)
#Script deve ser executado com usuário root

#Função para gerar senhas
function mkpass(){
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 ; echo ''
}
#variáveis
LOG=/log/zabbix.log;
PARAM=/log/parametros.md;
SQL_ZBX="create user zabbix@localhost identified by '$PASSZBX=$(mkpass)'";
SQL_ROOT="ALTER USER 'root'@'localhost' IDENTIFIED BY '$PASSROOT=$(mkpass)'";

#--------------------Preparando sistema--------------------#
apt update && apt upgrade -y;
#instalando utilitários
apt install iperf3 ifupdown2 net-tools iotop nethogs nmon mtr git -y;
#instalando rclone
curl https://rclone.org/install.sh | bash;
#alterando o PATH do sistema
export PATH=$PATH'/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/bin';

#--------------------MariaDB--------------------#
#instalando o mariadb
apt install mariadb-server mariadb-client -y;
#iniciando o serviço e habilitando no boot
systemctl enable --now mariadb.service;

#Criando configurações para o zabbix;
mysql -u root -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;";
mysql -u root -e "$SQL_ZBX";
mysql -u root -e "grant all privileges on zabbix.* to zabbix@localhost;";
mysql -u root -e "set global log_bin_trust_function_creators = 1;";
mysql -u root -e "flush privileges;";

#Alterando a senha do root
mysql -u root -e "$SQL_ROOT";

#Salva as credenciais em um arquivo
echo -e "\nSenha usuário zabbix mariadb: $PASSZBX" &>> $PARAM;
echo -e "\nSenha usuário root mariadb: $PASSROOT" &>> $PARAM;






#Criando estrutura do zazbbix no banco de dados
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p$PASSZBX zabbix