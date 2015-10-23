# glusterfs-difftool

## リスト取得時

`sh get_list1.sh` (例) で以下のプログラムを実行
(ファイル名についている数字は、環境ごとに使い分けることを想定。　 `MSTR001` には `get_list1.sh` を使う)

成功すると以下が作成される

- (`lists` ディレクトリ配下に)エンタープライズごとのファイルのリスト
- ログのファイル

```bash:get_list1.sh

#!/bin/sh -x

ACTION='list'
ACCOUNT_LIST=TARGET_LIST.lst #このファイルに指定したファイルにリスト取得対象のエンタープライズ名を記しておく
LIST=LIST_bricks_sdb1_001.lst # <エンタープライズ名>_<LISTで指定した名前> でリストが作られていく
ROOT=/bricks/sdb1/ms2
CP_LOG=cp_001.log # ログとして出すファイルの名前

bundle exec ruby bin/lister.rb $ACTION $ACCOUNT_LIST $LIST $ROOT 2> $CP_LOG
```

## リスト比較時

`sh compare_001_002.sh` (例) で以下のプログラムを実行
(ここだと、上で取得したもののうち MSTR001 と MSTR002 を比較する場合)

成功するといかが作成される

- (今は出ないようになっている)(`results` ディレクトリ配下に)エンタープライズごとの結果リスト
- 各brickにだけあるファイルの絶対パスのリスト => ファイル名 `ONLY_<ほにゃらら>`
- 各brickで内容(サイズ)が違うファイルの絶対パスのリスト => ファイル栄 `DIFF_<ほにゃらら>`
- ログ

```bash:compare_001_002.sh

#!/bin/sh -x

ACTION='compare'
ACCOUNT_LIST=TARGET_LIST.lst # このファイルに指定したファイルにリスト取得対象のエンタープライズ名を記しておく
LIST0=LIST_bricks_sdb1_001.lst # 比較するリストその一
LIST1=LIST_bricks_sdb1_002.lst # 比較するリストその二
RES=RES_mstr001_mstr002.lst # <エンタープライズ名>_<RESに指定した名前>でリストが作られていく
CP_LOG=cp_001_002.log # ログとして出すファイルの名前

bundle exec ruby bin/lister.rb $ACTION $ACCOUNT_LIST $LIST0 $LIST1 $RES 2> $CP_LOG
```
