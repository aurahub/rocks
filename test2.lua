
require("deps/path")
local p = require("pretty-print").prettyPrint
local Mongodb = require("mongodb")
local net = require("net")
local uv = require('luv')

local socket
socket = net.createConnection(27017, "localhost")
print(socket)
socket:on(
    "connect",
    function()
        p("[Info] - Database is connected.......")
        socket.tempData = ""
        print(socket)
        socket:on(
          "data",
          function(data)
              -- self:_onData(data)
              -- p(data)
          end
        )

        -- socket:on(
        --     "end",
        --     function()
        --         socket:destroy()
        --         -- self:emit("end")
        --         -- self:emit("close")
        --         p("client end")
        --     end
        -- )

        -- socket:on(
        --     "error",
        --     function(err)
        --         p("Error!", err)
        --         -- self:emit("error", err)
        --     end
        -- )

        -- self:emit("connect")
        p(22222)
    end
)



socket:on(
    "error",
    function(code)
        if (code == "ECONNREFUSED") then
            -- self:emit("error", code)
            p("Database connection failed. ")
        end
    end
)

while true do
uv.run()
end