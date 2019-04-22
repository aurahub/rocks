local env = require("env")
local uv = require("luv")
local socket = require("socket")
local mq = require("spsc_queue")

env.set("UV_THREADPOOL_SIZE", #assert(uv.cpu_info()))

mq.push("r1", "main", "1")
mq.push("r2", "main", "2")
local ctx =
    uv.new_work(
    function(recv, mq) --work,in threadpool
        local mq = require("spsc_queue")
        print(mq.pop(recv, "main"))
        return r
    end,
    function(r, n)
        print(r, n)
    end --after work, in loop thread
)
uv.queue_work(ctx, "r1")
uv.queue_work(ctx, "r2")

uv.run("default")
-- uv.loop_close()
