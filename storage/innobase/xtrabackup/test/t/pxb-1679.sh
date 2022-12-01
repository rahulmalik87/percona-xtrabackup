#
# PXB-1679: Crash after truncating partition when the backup is taken
#

start_server

mysql test <<EOF
CREATE TABLE test01 (id int auto_increment primary key, a TEXT, b TEXT) PARTITION BY HASH(id) PARTITIONS 4;
INSERT INTO test01 (a, b) VALUES (REPEAT('a', 1000), REPEAT('b', 1000));
INSERT INTO test01 (a, b) VALUES (REPEAT('x', 1000), REPEAT('y', 1000));
INSERT INTO test01 (a, b) VALUES (REPEAT('q', 1000), REPEAT('p', 1000));
INSERT INTO test01 (a, b) VALUES (REPEAT('l', 1000), REPEAT('c', 1000));
INSERT INTO test01 (a, b) VALUES (REPEAT('m', 1000), REPEAT('p', 1000));
INSERT INTO test01 (a, b) VALUES (REPEAT('1', 1000), REPEAT('2', 1000));
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;
INSERT INTO test01 (a,b) SELECT a,b FROM test01;

CREATE TABLE test02 (id int auto_increment primary key, a TEXT, b TEXT);
INSERT INTO test02 SELECT * FROM test01;
EOF

xtrabackup --backup --target-dir=$topdir/backup  
mysql -e "ALTER TABLE test01 TRUNCATE PARTITION p3" test
mysql -e "TRUNCATE TABLE test02" test
record_db_state test
xtrabackup --backup --target-dir=$topdir/incremental --incremental-basedir=$topdir/backup  

shutdown_server

xtrabackup --prepare --target-dir=$topdir/backup --apply-log-only
xtrabackup --prepare --target-dir=$topdir/backup --incremental-dir=$topdir/incremental

rm -rf $mysql_datadir
xtrabackup --copy-back --target-dir=$topdir/backup

start_server
verify_db_state test
