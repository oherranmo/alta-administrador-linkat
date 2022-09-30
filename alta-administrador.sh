#!/bin/bash
#Autor: Òscar Herrán Morueco

root_check()
{
if [ "$(id -u)" != "0" ]; then
	whiptail --title "Error!" \
    --msgbox "Heu d'executar aquest script com a root (sudo) > ./nomscript.sh" 10 30
	exit 1
fi
add_user
}

add_user()
{

USERNAME=$(whiptail --title "Nom d'usuari" \
    --inputbox "Escriviu el nom d'usuari administrador que voleu afegir" 10 60  3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
user_check
else
echo "Operació avortada per l'usuari"
fi

}

user_check()
{

if [ -z $USERNAME ]; then
	whiptail --title "Error!" \
    --msgbox "Introduïu un nom d'usuari" 10 30
        
    fi
if getent passwd "$USERNAME" >/dev/null; then
	whiptail --title "Error!" \
    --msgbox "L'usuari $USERNAME, ja existeix" 10 30
    add_user
else
user_password
fi

    if grep -q "^$USERNAME:" /etc/passwd
    then
user_password
    else
	whiptail --title "Error!" \
    --msgbox "L'usuari $USERNAME, ja existeix" 10 30
        exit 1
    fi

}


user_password()
{

PASSWORD=$(whiptail --title "Contrasenya per a $USERNAME" \
    --passwordbox "Escriviu una contrasenya" 10 60  3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
if [ -z $PASSWORD ]; then
	whiptail --title "Error!" \
    --msgbox "No heu introduït cap contrasenya, no es pot deixar un usuari administrador sense contrasenya" 10 60
user_password

else
ocultar_usuari
fi
else
echo "Operació avortada per l'usuari"
fi
}

ocultar_usuari()
{

if(whiptail  --title "Ocultar $USERNAME ?" \
    --yesno "Voleu que l'usuari $USERNAME es mostri a la llista d'usuaris del sistema?" \
    --yes-button "Si" \
    --no-button "No" 10 60) then
groupadd $USERNAME
useradd -m -s /bin/bash $USERNAME -g $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG adm,fax,cdrom,floppy,tape,audio,dip,video,lpadmin,scanner,sambashare,sudo $USERNAME
reiniciar

else
groupadd $USERNAME
useradd -m -s /bin/bash $USERNAME -r -g $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG adm,fax,cdrom,floppy,tape,audio,dip,video,lpadmin,scanner,sambashare,sudo $USERNAME
echo "[SeatDefaults]" > "/etc/lightdm/lightdm.conf"
echo "greeter-show-manual-login=true" >> "/etc/lightdm/lightdm.conf"
reiniciar
fi
}

reiniciar()
{

if(whiptail  --title "Reinici" \
    --yesno "Voleu reiniciar l'equip per a aplicar tots els canvis ara?" \
    --yes-button "Si" \
    --no-button "No" 10 60) then
reboot
else
clear
echo "Ha finalitzat la creació de l'usuari $USERNAME"
exit 1
fi

}
root_check
