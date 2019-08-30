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

local function yield(co, f, ...)
    local arg = {...}
    table.insert(
        arg,
        function(...)
            coroutine.resume(co, ...)
        end
    )
    f(unpack(arg))
    return coroutine.yield(co)
end

function test()
    local co
    co =
        coroutine.create(
        function()
            local test = db:collection("test")
            local insert_item = {
                title = "Hello word!",
                content = "Here is the first blog post ....",
                author = "Cyril Hou"
            }
            local find_item = {
                title = "Hello word!"
            }
            local err, res = yield(co, test.insert, test, insert_item)
            p(err, res)
            if err then
                return
            end
            local err, res = yield(co, test.findOne, test, find_item)
            p(err, res)
            return
        end
    )
    coroutine.resume(co)
end
db:on("connect", test)
