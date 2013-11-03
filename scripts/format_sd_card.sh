#! /bin/sh

if [ $# -ne 1 ]; then
  echo "Usage: $0 <drive>"
  exit 1;
fi

# Sao criadas duas particoes: uma para boot e outra para o sistema de arquivos
DRIVE=$1
PARTITION1=${DRIVE}1
PARTITION2=${DRIVE}2

umount ${PARTITION1}
umount ${PARTITION2}

SIZE=$(fdisk -l ${DRIVE} | grep Disk | grep bytes | awk '{print $5}')

echo DISK SIZE - ${SIZE} bytes

CYLINDERS=$(echo ${SIZE}/255/63/512 | bc)

echo CYLINDERS - ${CYLINDERS}

echo "Particionando ${DRIVE}..."

# Lista as particoes do sd-card e o particiona de acordo com tal configuracao.
{
echo ,70,C,*
echo ,,L,-
} | sfdisk --no-reread -f -u M -D -H 255 -S 63 -C ${CYLINDERS} ${DRIVE}

echo "Formatando ${DRIVE}..."

# Formata as particoes criadas anteriormente, da seguinte forma:
# - Particao 1: FAT32 - para arquivos de boot. Tamanho: 9 cilindros do sd-card;
# - Particao 2: EXT4 - para o sistema de arquivos. Tamanho: tamanho restante do dispositivo.
if [ -b ${PARTITION1} ]; then
  mkfs.vfat -F 32 -n "boot" ${PARTITION1}
else
  echo "Particao ${PARTITION1} nao encontrada!"
fi

if [ -b ${PARITION2} ]; then
  mkfs.ext4 -L "rootfs" ${PARTITION2}
else
  echo "Particao ${PARTITION1} nao encontrada!"
fi

#$ sudo fdisk -l /dev/sdb

#Disk /dev/sdb: 3951 MB, 3951034368 bytes
#255 heads, 63 sectors/track, 480 cylinders, total 7716864 sectors
#Units = sectors of 1 * 512 = 512 bytes
#Sector size (logical/physical): 512 bytes / 512 bytes
#I/O size (minimum/optimal): 512 bytes / 512 bytes
#Disk identifier: 0x00000000

#   Device Boot      Start         End      Blocks   Id  System
#/dev/sdb1   *          63      144584       72261    c  W95 FAT32 (LBA)
#/dev/sdb2          160650     7711199     3775275   83  Linux

