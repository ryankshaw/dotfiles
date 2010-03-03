#!/bin/sh

# pulled from: http://blog.interlinked.org/tutorials/rsync_time_machine.html

date=`date "+%Y-%m-%dT%H_%M_%S"`
HOME=~
backup_server=ryankshaw@iamryanshaw.com

ssh $backup_server "mkdir -p Backups/incomplete_back-$date" 

rsync -azP \
  --delete \
  --delete-excluded \
  --exclude-from=$HOME/.rsync/exclude \
  --link-dest=../current \
  $HOME $backup_server:Backups/incomplete_back-$date \
  && ssh $backup_server \
  "mv Backups/incomplete_back-$date Backups/back-$date \
  && rm -f Backups/current \
  && ln -s back-$date Backups/current"
