0,stop/start	4个阶段
    a,init
	$ source ./megawise_env.sh
	$ ./initdb.sh
	$ ./gen_megawise_config.sh
    b,start
	$ ./start_megawise.sh
	$ ./start_server.sh
    c,connect
	$ ./connect.sh
    d,stop
	$ ./stop_server.sh
	$ ./stop_megawise.sh

1,2个主要进程
    0 S inspur    10101      1  0  80   0 - 287466 SyS_ep 16:07 pts/3   00:00:00   /home/pwz/sdb/megawise/zdb/v2.6.2/bin/megawise_server -c /home/pwz/sdb/megawise/zdb/v2.6.2/conf/megawise_config.yaml
    0 S inspur    10140      1  0  80   0 -  5948 do_sel 16:08 pts/3    00:00:00   /home/pwz/sdb/megawise/zdb/v2.6.2/bin/postgres -D /home/pwz/sdb/megawise/zdb/v2.6.2/data

2,megawise_server
    a,logfiles
	[inspur@node2 script]$ lsof -p 10101
	    megawise_ 10101 inspur    3w      REG              253,0     2756    5546129 /tmp/zdb_inspur/zdb_server.INFO.log.20190509-160715.log
	    megawise_ 10101 inspur    4w      REG              253,0        0    5546131 /tmp/zdb_inspur/zdb_server.WARNING.log.20190509-160715.log
	    megawise_ 10101 inspur    5w      REG              253,0        0    5546133 /tmp/zdb_inspur/zdb_server.ERROR.log.20190509-160715.log
	    megawise_ 10101 inspur    6w      REG              253,0        0    5546135 /tmp/zdb_inspur/zdb_server.CRITICAL.log.20190509-160715.log

3,postgres
    a,logfiles
	[inspur@node2 script]$ lsof -p 10140
	    postgres 10140 inspur    1w   REG               8,17      1126 1613941952 /home/pwz/sdb/megawise/zdb/v2.6.2/data/logs/logfile
	    postgres 10140 inspur    3w   REG               8,17         0  540234739 /home/pwz/sdb/megawise/zdb/v2.6.2/data/megawise_log/zdb_inspur/zdb_inspur.WARNING.log.20190509-160845.log
	    postgres 10140 inspur    4w   REG               8,17         0  540234740 /home/pwz/sdb/megawise/zdb/v2.6.2/data/megawise_log/zdb_inspur/zdb_inspur.ERROR.log.20190509-160845.log
	    postgres 10140 inspur    5w   REG               8,17         0  540234741 /home/pwz/sdb/megawise/zdb/v2.6.2/data/megawise_log/zdb_inspur/zdb_inspur.CRITICAL.log.20190509-160845.log
