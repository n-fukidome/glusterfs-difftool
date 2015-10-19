#!/bin/sh -x

ACTION='compare'
ACCOUNT_LIST=TARGET_LIST.lst #for example
LIST0=LIST_bricks_sdb1_001.lst
LIST1=LIST_bricks_sdb1_002.lst
RES=RES_mstr001_mstr002.lst
CP_LOG=cp_001_002.log

bundle exec ruby bin/lister.rb $ACTION $ACCOUNT_LIST $LIST0 $LIST1 $RES 2> $CP_LOG
