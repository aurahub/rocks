local uv = require "uv"
local socket = require "socket"

local async =
    uv.new_async(
    function()
    end
)
uv.new_thread(
    function(async)
        local uv = require "uv"
        local socket = require "socket"
        print(socket.gettime())
        for i = 1, 1000 * 10 do
            uv.async_send(async)
        end
        print(socket.gettime())
    end,
    async
)

uv.run()
