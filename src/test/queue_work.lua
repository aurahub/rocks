-- local env = require("env")
local uv = require("luv")
local socket = require("socket")

-- env.set("UV_THREADPOOL_SIZE", #assert(uv.cpu_info()))
-- print(env.get("UV_THREADPOOL_SIZE"))
local ctx
ctx =
    uv.new_work(
    function(n, n2) --work,in threadpool
        print(n, n2)
        local uv = require("luv")
        local t = uv.thread_self()
        return n * n, n
    end,
    function(r, n)
        print(string.format("%d => %d", n, r))
        -- uv.queue_work(ctx, 3)
        print(socket.gettime())
    end --after work, in loop thread
)
uv.queue_work(ctx, 2, 3)

uv.run("default")
-- uv.loop_close()
