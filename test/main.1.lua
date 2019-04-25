local service = require "service"
local uv = require "uv"
local socket = require "socket"
require("pack")

service.start("a")
service.start("b")
service.start("c")
service.start("d")
service.start("e")
service.start("f")
service.start("g")
service.start("h")

service.start("i")
service.start("j")
service.start("k")
service.start("l")
service.start("m")
service.start("n")
service.start("o")

local count = 0
local timer = uv.new_timer()
timer:start(
    0,
    1,
    function()
        local t = socket.gettime()
        for i = 1, 300 do
            count = count + 1
            service.send("a", count)
        end
    end
)

uv.run()
