# proxmox-backup-server

Running:
```
DATADIR=$PWD/mounts
echo root-password > $PWD/passwords.d/root-password
podman run \
    -t -i --rm \
    -v $DATADIR/etc:/etc/proxmox-backup \
    -v $DATADIR/lib:/var/lib/proxmox-backup \
    -v $DATADIR/log:/var/log/proxmox-backup \
    -v $PWD/passwords.d:/etc/passwords.d \
    --tmpfs /run/proxmox-backup \
    -p 8007:8007 \
    andrewd/pbs
```
