#!/bin/sh -x

ACTION='compare'
ACCOUNT='neko-cake' #for example
LIST0=LIST_bricks_sdb1_001.lst
LIST1=LIST_bricks_sdb1_002.lst
RES=RES_mstr001_mstr002.lst
CP_LOG=cp_003_004.log

bundle exec ruby bin/lister.rb $ACTION $ACCOUNT $LIST0 $LIST1 $RES 2> $CP_LOG
