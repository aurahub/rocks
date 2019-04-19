-- local env = require("env")
local uv = require("luv")
local socket = require("socket")

-- env.set("UV_THREADPOOL_SIZE", #assert(uv.cpu_info()))
-- print(env.get("UV_THREADPOOL_SIZE"))

local ctx =
    uv.new_work(
    function(...)
        _G.a = _G.a or 0
        _G.a = _G.a + 1
    end,function()
    end
)

print(
    socket.gettime())
uv.queue_work(ctx, 1)
uv.queue_work(ctx, 2)
uv.queue_work(ctx, 3)
