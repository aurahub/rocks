package.path =
    package.path ..
    ";/Users/tony/Documents/project/bnb/server/logic/?.lua" ..
        ";/Users/tony/Documents/GitHub/server/rocks/?.lua;" .. "?.lua"

local uv = require "uv"
local msg = require "core/message"
local protobuf = require "core/protobuf"
local loop = require "core/loop"
local socket = require "socket"
local spack = require "spack"
local signal = require "core/signal"
signal.set(loop.stop)

local client = uv.new_tcp()
local recv_count = 0
local send_count = 0

local callback

client:connect(
    "127.0.0.1",
    10001,
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

                -- If data is set the server has relaid data, if unset the client has disconnected
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

loop.create(1)

--[[    benchmark recv & send 100k/s]]
local start = {}
local stop = {}
loop.add(
    function()
        for i = 1, 1000, 1 do
            client:write(chunk)
            send_count = send_count + 1
            if send_count % 100000 == 0 then
                local index = send_count / 100000
                start[index] = socket.gettime()
                print("send ", index, start[index])
            end
        end
    end
)
callback = function()
    recv_count = recv_count + 1
    if recv_count % 100000 == 0 then
        local index = recv_count / 100000
        stop[index] = socket.gettime()
        print("recv ", index, stop[index], stop[index] - start[index])
        os.exit(1)
    end
end
loop.run()
