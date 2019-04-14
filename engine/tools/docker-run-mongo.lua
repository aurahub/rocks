#!/usr/local/bin/luajit
os.execute("docker stop mongo")
os.execute("docker run -d -p 27017:27017 --name mongo --hostname mongo --bind_ip_all mongo")
