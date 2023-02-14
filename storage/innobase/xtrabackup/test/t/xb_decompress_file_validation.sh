#!/bin/bash
. inc/common.sh

start_server

vlog "case#1 backup with qpress and compression"

xtrabackup --backup --target-dir=$topdir/backup --compress --encrypt=AES256 --encrypt-key=percona_xtrabackup_is_awesome___

echo "echo secret_text_not_to_be_printed" > $topdir/backup/runme.sh
echo "" > $topdir/backup/'./m'\''; bash runme.sh;#.qp.xbcrypt'

xtrabackup --target-dir=$topdir/backup --encrypt-key=percona_xtrabackup_is_awesome___ --decrypt=AES256 --decompress 2>&1 | tee $topdir/pxb.log

if grep -q 'secret_text_not_to_be_printed' $topdir/pxb.log
then
	die "xtrabackup should not print this warning"
fi




