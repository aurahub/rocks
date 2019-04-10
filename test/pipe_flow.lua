_G.luvit_require = require
local paths = {
    "?.lua",
    "/Users/tony/Documents/project/bnb/server/logic/?.lua",
    "/Users/tony/Documents/GitHub/server/rocks/?.lua",
    "/Users/tony/Documents/GitHub/server/rocks/deps/?.lua",
    "/Users/tony/Documents/GitHub/server/rocks/deps/?/init.lua"
}
for _, path in pairs(paths) do
    package.path = package.path .. ";" .. path
end

local async = require "core/async"
local mongo = require "core/mongo"
local print_table = require "test/print"
mongo.init()
local db = mongo.get(1)

local function task1(cb)
    local test = db:collection("test")
    p("preparing to insert")
    test:insert(
        {
            title = "Hello word!",
            content = "Here is the first blog post ....",
            author = "Cyril Hou"
        },
        cb
    )
end
local function task2(cb)
    local test = db:collection("test")
    p("preparing to find")
    test:findOne(
        {
            title = "Hello word!"
        },
        cb
    )
end

local function yield(co, f)
    f(
        function(...)
            coroutine.resume(co, ...)
        end
    )
    return coroutine.yield(co)
end

function test()
    local function flow(co)
        local err, res = yield(co, task1)
        -- p(err, res)
        if err then
            return
        end
        local err, res = yield(co, task2)
        -- p(err, res)
    end

    for i = 1, 100, 1 do
        pipeline.enqueue("login", flow)
    end
end
db:on("connect", test)
