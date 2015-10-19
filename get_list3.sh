#!/bin/sh -x

ACTION='list'
ACCOUNT_LIST=TARGET_LIST.lst #for example
LIST=LIST_bricks_sdb1_003.lst
ROOT=/bricks/sdb1/ms2
CP_LOG=cp_003.log

bundle exec ruby bin/lister.rb $ACTION $ACCOUNT_LIST $LIST $ROOT 2> $CP_LOG
