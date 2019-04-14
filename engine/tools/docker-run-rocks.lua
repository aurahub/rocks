#!/usr/local/bin/luajit
os.execute("docker stop rocks")
os.execute("docker rm rocks")
os.execute(
    "docker run -d -p 10000:10000 -p 10080:10080 --name rocks --hostname --rocks -v /Users/tony/Documents/GitHub/rocks:/mnt/data -w /mnt/data/ --link mongo:mongo lizongti/rocks ./app.lua"
)
-- os.execute(
--     "docker run -it -p 10000:10000 -p 10080:10080 --name rocks --hostname --rocks -v /Users/tony/Documents:/mnt/data -w /mnt/data/GitHub/rocks --link mongo:mongo lizongti/rocks /bin/bash"
-- )
