#!/bin/bash
VERMELHOG='\E[31;1m'
SEMCOR=$(tput sgr0)

case $1 in
  ''|*[!0-9]*)
echo -e $VERMELHOG '    (\_/)'$SEMCOR'      Ops!'
echo -e $VERMELHOG '   =( ⌐■-■)='$SEMCOR'   Você precisa digitar o tamanho da senha.'
echo -e $VERMELHOG '    (乁\¥/)´'$SEMCOR'   Ex: mkpass'$VERMELHOG' 20 '$SEMCOR;;
  *) 
RANDOMPASS=$(head /dev/urandom| tr -dc a-zA-Z0-9 | head -c$1);
CONT=`expr $1 + 1`
BARRA="$(seq -s '-' $CONT|tr -d '[:digit:]')"
CLR='\E[34;1m'
RST='\E[0m'

echo '+-'$BARRA'-+'
echo -e "| $CLR$RANDOMPASS$RST |"
echo '+-'$BARRA'-+';;
esac