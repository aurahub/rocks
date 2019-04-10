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

local mongo = require "core/mongo"
local print_table = require "test/print"
local uv = require "uv"
local deque = require "deque"
local async = require "core/async"
local socket = require "socket"
mongo.init()
local db = mongo.get(1)

local function insert(cb)
    db:collection("test"):insert(
        {
            title = "Hello word!",
            content = "Here is the first blog post ....",
            author = "Cyril Hou"
        },
        cb
    )
end
local function find(cb)
    db:collection("test"):findOne(
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

-- benchmark 1500 insert/s
local count = 0
function test1()
    local function flow(co)
        local err, res = yield(co, insert)
        count = count + 1
        if count % 10000 == 0 then
            print(socket.gettime())
        end
    end

    print(socket.gettime())
    for i = 1, 10000, 1 do
        pipeline.enqueue("login", flow)
    end
end

-- benchmark 4000/s
function test2()
    local function flow(co)
        local err, res = yield(co, find)
        count = count + 1
        if count % 10000 == 0 then
            print(socket.gettime())
        end
    end

    print(socket.gettime())
    for i = 1, 10000, 1 do
        pipeline.enqueue("login", flow)
    end
end

db:on("connect", test2)
