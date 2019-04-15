os.execute('mongod --config /usr/local/etc/mongod.conf& >/dev/null 2>&1;echo "$!" > /tmp/mongo.pid;print "$!"')
