<h1>Zabbix 6.4</h1>

<p>Script para instalação e configuração automatizada de um servidor Zabbix 6.4 para monitoramento</p>

## Ferramentas que serão instaladas

<p>As ferramentas que serão instaladas serão:</p>

- Zabbix 6.4
- Nginx
- PHP-FPM
- MariaDB
- Rclone
- Rsync

## Pré-requisitos

- Sistema Operacional: Debian 12 64bits
- Instalação sem interface gráfica

**Requisitos mínimos de hardware**

- Processador (Intel® ou AMD®) de 1 GHz ou mais rápido;
- 1 GB de memória RAM (2 GB ou mais é o recomendado);
- 40 GB (ou mais) de espaço livre* em disco para a instalação;

## Processo de instalação

- Baixar o script install.sh
- Dar permissão para execução: chmod +x install.sh
- Iniciar a instalação: sudo ./install.sh

Apenas aguardar o processo de instalação ser finalizado. Os logs de instalação podem ser acompanhados através do arquivo: /tmp/zabbix.log
