package.path =
    package.path .. ";" .. "./?.lua;" .. ";" .. "./?/init.lua;" .. ";" .. "./deps/?.lua;" .. ";" .. "./deps/?/init.lua;"
_G.process = require("process").globalProcess()
local p = require("pretty-print").prettyPrint

local mongodb = require("mongodb")
local c = mongodb:new({db = "test"})

c:on(
    "connect",
    function()
        -- Do stuff here.
        local Post = c:collection("post")
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
                p(err, res)
            end
        )
        Post:distinct(
            "category",
            function(err, res)
                p("All distinct value of `category` in post collections: ", res)
            end
        )
    end
)
c:on(
    "end",
    function()
        -- client disconnected or server disconnected
        print("connect end")
    end
)
c:on(
    "error", -- connot connect or socket error
    function(err)
        print("error", err)
    end
)
c:on(
    "close", -- equals to end
    function()
        print("close")
    end
)
require("luv").run()
