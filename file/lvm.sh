fdisk /dev/vdb
pvcreate /dev/vdb1
vgcreate docker  /dev/vdb1
lvcreate -l 100%VG -n lvdata docker
mkfs.xfs /dev/docker/lvdata
mkdir /data
mount /dev/docker/lvdata /data
echo "/dev/mapper/docker-lvdata  /data   xfs     defaults        0 0" >> /etc/fstab
