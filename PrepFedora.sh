#!/bin/bash
clear;
echo 'Iniciando script'

#Criando arquivo de log do script
echo -e '\nPreparando o ambiente e definindo variáveis';

#Pegando o usuário que está executando o script
usuario=$(whoami);
#Definindo o caminho para os logs de instalação
LOG=/home/$usuario/prepfedora.log;
#Definindo caminho onde serão baixados os arquivos para instalação
PASTA=/home/$usuario/dependencias;
#Verificando se a pasta ja existe
if [ -d $PASTA ]; then
echo '\nPasta ja existe\n' &>> $LOG;
else
  mkdir $PASTA;
fi
echo -e 'Ambiente pronto e variaveis definidas\n';

#Atualizando repositórios do sistea
echo -e 'Atualizando reposítórios';
sudo dnf update -y >> $LOG;
echo -e 'Repositórios atualizados\n';
sleep 1;

#Instalado VSCode
echo -e 'Instalando VSCode (Flatpak)';
sudo flatpak install com.visualstudio.code -y &>> $LOG;
echo -e 'VSCode instalado\n';
sleep 1;

#Instalado mega-cmd
echo -e 'Baixando e instalando mega-cmd (.rpm)';
wget -P $PASTA wget https://mega.nz/linux/repo/Fedora_38/x86_64/megacmd-Fedora_38.x86_64.rpm &>> $LOG;
echo -e 'Download Finalizado';
sudo dnf install $PASTA/megacmd-Fedora_38.x86_64.rpm &>>$LOG;
echo -e 'mega-cmd instaldo\n';
sleep 1;

#Instalando Wine e WineTricks
echo -e 'Instalando Wine e Winetricks';
sudo dnf install wine winetricks -y &>>$LOG;
echo -e 'Wine e winetricks instalados\n';
sleep 1;

#Baixando Winbox
echo -e 'Baixando Winbox 3.40';
echo -e 'Criando diretório para atalho wine';
sudo mkdir /wineprogs;
sudo chmod o+rw /wineprogs;
echo -e 'Diretório criado e permissões aplicadas';
wget -P /wineprogs https://download.mikrotik.com/winbox/3.40/winbox64.exe &>>$LOG;
echo -e 'Download concluido\n';
echo -e 'Criando alias no bashrc';
echo "alias winbox='wine /wineprogs/winbox64.exe'" >> .bashrc
. .bashrc;
echo 'Criado alias no e aplicado bashrc\n';
sleep 1;


#Instalando AnyDesk
echo -e 'Instalando AnyDesk (Flatpak)';
sudo flatpak install com.anydesk.Anydesk -y &>>$LOG;
echo -e 'AnyDesk instalado\n';
sleep 1;

#Instalando o DBeaver
echo -e 'Instalando DBeaver (Flatpak)';
sudo flatpak install io.dbeaver.DBeaverCommunity -y &>>$LOG;
echo -e 'DBeaver instalado\n';
sleep 1;

#Instalando Discord
echo -e 'Instalando Discord (Flatpak)';
sudo flatpak install com.discordapp.Discord -y &>>$LOG;
echo -e 'Discord instalado\n';
sleep 1;

#Instalando BitWarnden
echo -e 'Instalando BitWarden (Flatpak)';
sudo flatpak install com.bitwarden.desktop -y &>>$LOG;
echo -e 'BitWarden isnstalado\n';
sleep 1;

#Baixando e Instalando Google Chrome
echo -e 'Baixando e instalando Google Chrome (.rpm)';
wget -P $PASTA https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm &>>$LOG;
echo -e 'Downlaod concluido';
sudo dnf install $PASTA/google-chrome-stable_current_x86_64.rpm &>>$LOG;
echo -e 'Google Chrome instalado\n';
sleep 1;

#Baixando e Instalando RemoteDesktopManager
echo -e 'Baixando e instalando Remote Desktop Manager (.rpm)';
#wget -P $PASTA https://cdn.devolutions.net/download/Linux/RDM/2023.3.0.5/RemoteDesktopManager_2023.3.0.5_x86_64.rpm &>>$LOG;
echo -e 'Download concluido';
sudo dnf install $PASTA/RemoteDesktopManager_2023.3.0.5_x86_64.rpm &>>$LOG;
echo -e 'Remote Desktop Manager instalado\n';
sleep 1;

#Instalando OBS Studio
echo -e 'Instalando OBS Studio';
sudo flatpak install com.obsproject.Studio -y &>>$LOG;
echo -e 'OBS Studio instalado\n';
sleep 1;

#Instalando FileZilla
echo -e 'Instalando Filezilla';
sudo flatpak install flathub org.filezillaproject.Filezilla -y &>>$LOG;
echo -e 'Filezilla instalado\n';
sleep 1;

#Instalando Flameshot
echo -e 'Instalando Flameshot (Flatpak)';
sudo flatpak install org.flameshot.Flameshot -y &>>$LOG;
echo -e 'Flameshot instalado\n';
sleep 1;

#Instalando Remmina
echo -e 'Instalando Remmina (dnf)';
sudo dnf install remmina -y &>>$LOG;
echo -e 'Remmina instalado\n';
sleep 1;

#Instalando VLC
echo -e 'Instalando VLC (Flatpak)';
sudo flatpak install org.videolan.VLC -y &>>$LOG;
echo -e 'VLC instalado\n';
sleep 1;

#Instalando OnlyOffice
echo -e 'Instalando OnlyOffice (Flatpak)';
sudo flatpak install org.onlyoffice.desktopeditors -y &>>$LOG;
echo -e 'OnlyOffice instalado\n';
sleep 1;

#Instalando Nethogs
echo -e 'Instalando Nethogs (dnf)\n';
sudo dnf install nethogs -y &>>$LOG;
echo -e 'Nethogs instalado\n';
sleep 1;

#Instalando nmon
echo -e 'Instalando Nmon (dnf)\n';
sudo dnf install nmon -y &>>$LOG;
echo -e 'Nmon instalado\n';
sleep 1;

#Instalando Rclone
echo -e 'Instalando Rclone';
curl https://rclone.org/install.sh &>>$LOG | sudo bash &>>$LOG;
echo -e 'Rclone instalado\n';

#Instalando Rsync
echo -e 'Instalando Rsync';
sudo dnf install rsync -y &>>$LOG;
echo -e 'rsync instalado\n';

#Removendo pasta de dependencias
echo -e 'Removendo a pasta de depenpendencias';
rm -rf $PASTA &>>$LOG;
echo -e 'Pasta de dependencias removida';

#Finalizando Script
clear;
echo -e '\nScript Finalizado!!!\n';
sleep 3;