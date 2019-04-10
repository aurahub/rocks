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

protobuf.load("/Users/tony/Documents/project/bnb/server/logic/proto/")
msg.load("/Users/tony/Documents/project/bnb/server/logic/proto/", "/Users/tony/Documents/project/bnb/server/logic/mod/")

local id = msg.map("account_heartbeat_request")
local packet = protobuf.encode("account_heartbeat_request", {})
local spack_id = spack.gets()
local e, chunk = spack.send(spack_id, id, packet)
local len = #chunk

local client_count = 1000
local frame_per_second = 1000
local packet_per_frame = 2
local packet_count = client_count * frame_per_second * packet_per_frame

local recv_length = 0
local send_count = 0
local callback
local start = {}
local stop = {}

local client_list = {}
for i = 0, client_count, 1 do
    local client = uv.new_tcp()
    client_list[i] = client

    client:connect(
        "127.0.0.1",
        10002,
        function(err)
            if err then
                error(err)
            end

            client:read_start(
                function(err, data)
                    if err then
                        print("Client read error: " .. err)
                        client:close()
                    end

                    if data then
                        callback(data)
                    else
                        client:close()
                    end
                end
            )
        end
    )
end

loop.create(math.floor(1000 / frame_per_second))

loop.add(
    function()
        for i = 1, packet_per_frame, 1 do
            for _, client in pairs(client_list) do
                client:write(chunk)
                send_count = send_count + 1
                if send_count % packet_count == 0 then
                    local index = send_count / packet_count
                    start[index] = socket.gettime()
                    print("send ", index, start[index])
                end
            end
        end
    end
)
callback = function(data)
    recv_length = recv_length + #data
    if (recv_length / len) > packet_count then
        local index = 1
        stop[index] = socket.gettime()
        print("recv ", index, stop[index], stop[index] - start[index])
        os.exit(1)
    end
end
loop.run()

-- 1000 k/10s = 10k/s
