#!/bin/sh -x

ACTION='list'
ACCOUNT='nekojarashi' #for example
LIST=LIST_bricks_sdb1_001.lst
ROOT=/bricks/sdb1/001
CP_LOG=cp_001_002.log

bundle exec ruby bin/lister.rb $ACTION $ACCOUNT $LIST $ROOT 2> $CP_LOG
