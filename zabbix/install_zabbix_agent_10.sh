#!/bin/bash

# Verificando se o arquivo de repositório ja existe no diretório
REPO_FILE="zabbix-release_5.4-1+debian10_all.deb"
if [[ -f $REPO_FILE ]]; then
    rm -f $REPO_FILE
fi

# Adicionando o repositório do Zabbix
wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/$REPO_FILE
dpkg -i $REPO_FILE
apt update

# Corrigindo pacotes quebrados, se houver
apt --fix-broken install

# Instalando o Zabbix Agent
apt install -y zabbix-agent

# Solicitando informações para configuração
read -p "Digite o IP ou nome do host do servidor Zabbix: " zabbix_server
read -p "Digite o nome do host para este agente (geralmente o hostname da máquina): " zabbix_hostname

# Atualizando o arquivo de configuração
sed -i "s/^Server=127.0.0.1/Server=$zabbix_server/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive=127.0.0.1/ServerActive=$zabbix_server/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^Hostname=Zabbix server/Hostname=$zabbix_hostname/" /etc/zabbix/zabbix_agentd.conf

#Removendo o arquivo repo
rm -f $REPO_FILE

# Iniciando e habilitando o serviço
systemctl restart zabbix-agent
systemctl enable zabbix-agent

echo ''
echo "Instalação e configuração do Zabbix Agent concluídas!"
echo ''