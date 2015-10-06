#!/bin/sh -x

ACTION='list'
ACCOUNT='nekojarashi' #for example
LIST=LIST_bricks_sdb1_003.lst
ROOT=/bricks/sdb1/ms2
CP_LOG=cp_003.log

bundle exec ruby bin/lister.rb $ACTION $ACCOUNT $LIST $ROOT 2> $CP_LOG
