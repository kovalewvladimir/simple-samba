#!/bin/sh

INITALIZED="/.initialized"

if [ ! -f "$INITALIZED" ]; then
    cat <<EOF
################################################################################
CONTAINER: starting initialisation
################################################################################
EOF

    echo "ACCOUNT: adding account: $ACCOUNT_NAME"
    adduser -D -G users -H -S -g 'Samba User' -h /tmp $ACCOUNT_NAME
    echo -e "$ACCOUNT_PASSWORD\n$ACCOUNT_PASSWORD" | passwd "$ACCOUNT_NAME"
    echo -e "$ACCOUNT_PASSWORD\n$ACCOUNT_PASSWORD" | smbpasswd -a "$ACCOUNT_NAME"
    smbpasswd -e "$ACCOUNT_NAME"

    mkdir -p /shares/"$SHARE_NAME"

    cat > /etc/samba/smb.conf <<EOF
    [global]
        dos charset = CP866
        unix charset = UTF8
        workgroup = AA
        server string = Samba Server Version %v
        map to guest = Bad User
        obey pam restrictions = Yes
        pam password change = Yes
        passwd program = /usr/bin/passwd %u
        passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
        unix password sync = Yes
        # syslog = 0
        # log file = /var/log/samba/log.%m
        # max log size = 1000
        dns proxy = No
        usershare allow guests = Yes
        panic action = /usr/share/samba/panic-action %d
        idmap config * : backend = tdb

    [$SHARE_NAME]
        path = /shares/$SHARE_NAME
        valid users = $ACCOUNT_NAME
        read only = No
        create mask = 0775
        force create mode = 0775
        directory mask = 0775
        inherit permissions = Yes
EOF

    touch "$INITALIZED"
else
    cat <<EOF
################################################################################
CONTAINER: already initialized - direct start of samba
################################################################################
EOF
fi


cat <<EOF
################################################################################
RUN SAMBA
################################################################################
EOF

##
# CMD
##
echo ">> CMD: $@"
$@