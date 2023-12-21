#!/bin/bash
# Autor: Bruno Honorato da Fonseca
# Data da criação: 16/11/2023
# Ultima alteração: 20/12/2023
# Script para instalação do Nextcloud com Apache2 no Debian 12 (Bookworm)
# Script deve ser executado com usuário root

#--------------------Funções--------------------#
    # Função para gerar senhas
        function mkpass(){
            tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 ; echo ''
        }

#--------------------Variáveis--------------------#

    LOG=/tmp/nextcloud.log;
    ip=$(hostname -I | awk '{print $1}')
    PARAM=/tmp/parametros.conf
    PASSROOT=$(mkpass)
    PASSNXT=$(mkpass)

#--------------------Verifica Sistema--------------------#
    
    #-- validar versão do Debian
    VERSAO=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"')
    if [ $VERSAO -ne "12" ];then
        echo -e "\nEste script é destinado apenas ao Debian 12\n";
        exit 1;
    fi
    clear
    #if [ "$(lsb_release -cs)" = "bookworm" ]; then
     #   echo "O sistema é Debian 12. Executando o script..."
    #else
      #  echo "Este script é destinado apenas ao Debian 12. O sistema atual é $(lsb_release -rcis)."
    #    exit 1
    #fi
#--------------------Verifica Usuário--------------------#

    if [ $(id -u) == "0" ] 
    then
		  echo -e "O usuário é Root, continuando com o script...\n"
		  sleep 5
	  else
		  echo -e "Script deve ser executado como root"
		  exit 1
    fi
#--------------------Preparação do sistema--------------------#
    echo -e "Atualizando o sistema... Aguarde"
    apt update -y &>>$LOG
    apt upgrade -y &>>$LOG
    echo -e "Limapando o sistema... Aguarde"
    apt autoremove -y &>>$LOG
    apt autoclean &>>$LOG
    echo -e "Instalando pacotes essenciais... Aguarde"
    apt install zip ifupdown2 net-tools iotop nethogs nmon mtr curl gnupg2 ca-certificates lsb-release -y &>>$LOG
    #Ajusta o PATH do sistema
    echo export PATH=$PATH'/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/bin' >> /$(whoami)/.bashrc && . /$(whoami)/.bashrc
    echo -e "Utilitários e dependencias instalados\n"
#--------------------Apache--------------------#
    echo -e "Instalando o Apache2... Aguarde"
    apt install apache2 -y &>>$LOG;
    rm -rf /var/www/*
    mv apachenxt.conf /etc/apache2/sites-available/nextcloud.conf
    ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf
    rm /etc/apache2/sites-enabled/000-default.conf
    echo -e "Apache2 instalado\n"
#--------------------PHP--------------------#
    echo -e "Instalando PHP... Aguarde"
    apt install php-fpm php-pear php8.2-mbstring php8.2-intl php8.2-gd php8.2-zip php8.2-mysql php8.2-bcmath php8.2-gmp php8.2-opcache php-imagick php8.2-curl php-apcu unzip imagemagick -y &>>$LOG
    mv phpnxt.conf /etc/php/8.2/fpm/pool.d/nextcloud.conf
    echo -e "PHP Instalado\n"    
#--------------------MariaDB--------------------#  
    echo -e "Instalando e configurando MariaDB... Aguarde"
    apt install mariadb-server mariadb-client -y &>>$LOG
    mysql -uroot -e "create database nextcloud;" 
    mysql -uroot -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY '"$PASSNXT"';"
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '"$PASSROOT"';"
    mysql -uroot -p$PASSROOT -e "flush privileges;"
    echo -e "Banco de dados instalado e configurado"
    
    echo -e "Movendo paramêtros\n"
    
    echo -e "User netxcloud: '"$PASSNXT"'" &>> $PARAM
    echo -e "User root: '"$PASSROOT"'" &>> $PARAM
    mv $PARAM /etc/mysql/
#--------------------Nextcloud--------------------#
    echo -e "Baixando aquivos do nextcloud...Aguarde"
    wget -P /tmp/ https://download.nextcloud.com/server/releases/latest.zip &>>$LOG
    echo -e "Descompactando e movendo..."
    unzip -o /tmp/latest.zip -d /tmp/ &>>$LOG
    mv /tmp/nextcloud /var/www/
    echo -e  "Aplicando permissões"
    chown -Rf www-data:www-data /var/www/* &>>$LOG
#--------------------Finalizando--------------------#
    echo -e  "\nReiniciando e habilitando serviços"
    a2enmod proxy_fcgi setenvif &>>$LOG
    a2enconf php8.2-fpm &>>$LOG
    systemctl restart php8.2-fpm apache2 mariadb
    systemctl enable php8.2-fpm apache2 mariadb &>>$LOG
    echo -e "Instalação do Nextcloud finalizada"