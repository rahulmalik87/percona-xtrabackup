#!/bin/bash
. inc/common.sh

start_server
mysql -e "create table t1(i int)" test

vlog "case#1 backup with lz4 and compression"

xtrabackup --backup --target-dir=$topdir/backup --compress=lz4 --encrypt=AES256 --encrypt-key=percona_xtrabackup_is_awesome___

echo "echo secret_text_not_to_be_printed" > $topdir/backup/runme.sh
cp $topdir/backup/test/t1.ibd.lz4.xbcrypt $topdir/backup/'./m'\''; bash runme.sh;#.lz4.xbcrypt'

xtrabackup --target-dir=$topdir/backup --encrypt-key=percona_xtrabackup_is_awesome___ --decrypt=AES256 --decompress 2>&1 | tee $topdir/pxb.log

if grep -q 'secret_text_not_to_be_printed' $topdir/pxb.log
then
	die "xtrabackup should not print this warning"
fi

if ! grep -q 'completed OK' $topdir/pxb.log
then
	die "test failed"
fi
