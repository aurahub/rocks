local uv = require("uv")

local _threads = {}
local _asyncs = {}

local function master_async(action, id, ...)
    local args = {...}
    if action == "register" then
        local async = args[1]
        _asyncs[id] = async
        uv.async_send(async, "do_something", "go go go")
    end
end

local function thread_func(id, master_async)
    local uv = require("uv")

    local async =
        uv.new_async(
        function(action, ...)
            print(action)
        end
    )

    uv.async_send(master_async, "register", id, async)

    uv.run()
end

local function main()
    for id = 1, #assert(uv.cpu_info()) do
        _threads[id] = uv.new_thread(thread_func, id, uv.new_async(master_async))
    end

    uv.run()
end

main()
