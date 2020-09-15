local socket = require "socket"
local Mongo = require("luvit-mongodb")
local db = Mongo:new({db = "test"})

-- replace `DATABASE_NAME` above with a DB name.
db:on(
    "connect",
    function()
        print("11111")
        -- Do stuff here.
        local Post = db:collection("post")
        local page = 1
        Post:insert(
            {
                title = "Hello word!",
                content = "Here is the first blog post ....",
                author = "Cyril Hou"
            },
            function(err, res)
                p(res)
            end
        )
        local posts = Post:find({author = "Cyril Hou"})

        posts:limit(10):skip(page * 10):update({authorAge = 25}):exec(
            function(err, res)
                -- p(err, res)
            end
        )
        -- Post:distinct("category", function(err, res)
        -- 	p("All distinct value of `category` in post collections: ", res)
        -- end)
    end
)
db:on(
    "end",
    function()
        -- client disconnected or server disconnected
        print("connect end")
    end
)
db:on(
    "error", -- connot connect or socket error
    function(err)
        print("error", err)
    end
)
db:on(
    "close", -- equals to end
    function()
        print("close")
    end
)
