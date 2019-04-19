package.path =
    package.path ..
    ";/Users/tony/Documents/project/bnb/server/logic/?.lua" ..
        ";/Users/tony/Documents/GitHub/server/rocks/?.lua;" .. "?.lua"

local uv = require "uv"
local msg = require "core/message"
local protobuf = require "core/protobuf"
local timer = require "core/timer"
local socket = require "socket"
local spack = require "spack"
local signal = require "core/signal"

signal.set(uv.stop)

local client = uv.new_tcp()
local recv_count = 0
local send_count = 0

local callback

client:connect(
    "127.0.0.1",
    10000,
    function(err)
        if err then
            error(err)
        end

        -- Relay data back to client
        client:read_start(
            function(err, data)
                -- If error, print and close connection
                if err then
                    print("Client read error: " .. err)
                    client:close()
                end

                -- If data is set the server has relaid data,
                -- unset the client has disconnected
                if data then
                    callback()
                else
                    client:close()
                end
            end
        )
    end
)

protobuf.load("/Users/tony/Documents/project/bnb/server/logic/proto/")
msg.load("/Users/tony/Documents/project/bnb/server/logic/proto/", "/Users/tony/Documents/project/bnb/server/logic/mod/")

local id = msg.map("account_heartbeat_request")
local packet = protobuf.encode("account_heartbeat_request", {})
local spack_id = spack.gets()
local e, chunk = spack.send(spack_id, id, packet)
print(chunk)

--[[    benchmark recv & send delay 0.2ms ]]
local start, stop
timer.add(
    1000,
    function()
        start = socket.gettime()
        print("send ", start)
        client:write(chunk)
    end
)
callback = function()
    stop = socket.gettime()
    print("recv ", stop, stop - start)
end
uv.run()
