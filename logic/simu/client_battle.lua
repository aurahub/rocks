local lfs = require("lfs")
local _cwd = lfs.currentdir() -- must run in project dir

local paths = {
    "?.lua",
    _cwd .. "/logic/?.lua",
    _cwd .. "?.lua",
    _cwd .. "/deps/?.lua",
    _cwd .. "/deps/?/init.lua"
}
for _, path in pairs(paths) do
    package.path = package.path .. ";" .. path
end

local cpaths = {
    "/usr/lib/x86_64-linux-gnu/lua/5.1/?.so" --debian
}
for _, path in pairs(cpaths) do
    package.cpath = package.cpath .. ";" .. path
end

_G.p = require("pretty-print").prettyPrint
-- _G.print = _G.p

local uv = require("uv")
local msg = require("core/message")
local protobuf = require("core/protobuf")
local message = msg.t
local json = require("rapidjson")
local timer = require("core/timer")
local socket = require("socket")
local spack = require("spack")
local signal = require("core/signal")
local timer = require("core/timer")
local net = require("net")
protobuf.load(_cwd .. "/logic/proto")
msg.load(_cwd .. "/logic/proto", _cwd .. "/logic/mod")

signal.set(uv.stop)

local _client

local _spack_id = spack.gets()
local _client_data = {}
local _move_tick = 0
local _heartbeat_time = socket.gettime()
local _need_restart = false
local _frame_index = 0

local function send(name, data)
    if msg.map(name) > 255 then
        p("<=", name, data)
    end
    local id = msg.map(name)
    local packet = json.encode(data or {})

    local e, chunk = spack.send(_spack_id, id, packet)
    if e <= 0 then
        p(e, chunk)
    end
    _client:write(chunk)
end

local frame = function()
    _move_tick = _move_tick + 100
    send(message.match_frame_request, {pos_x = 1000 + _move_tick, pos_y = 1000 + _move_tick, forward = 1})
end

local function handler(name, data)
    if msg.map(name) > 255 then
        p("=>", name, data)
    end
    if data.err and data.err > 0 then
        p("error!")
        return
    end
    if name == message.mono_login_response then
        _client_data.token = data.token
        send(message.hall_auth_request, {token = data.token})
    elseif name == message.hall_auth_response then
        send(message.room_enter_request, {map_type = 1, map_id = 1})
    elseif name == message.room_enter_response then
        send(message.room_prepare_request, {map_type = 1, map_id = 1, room_id = data.room_id, pos_id = data.pos_id})
    elseif name == message.room_start_notice then
        _client_data.match_id = data.match_id
        send(message.match_auth_request, {token = _client_data.token, match_id = _client_data.match_id})
    elseif name == message.match_auth_response then
        timer.add(1000, frame)
    elseif name == message.match_stop_notice then
        _move_tick = 0
        timer.rm(1000, frame)
        send(message.room_enter_request, {map_type = 1, map_id = 1})
    end
end

local function recv(chunk)
    local e, id, packet = spack.recv(_spack_id, chunk)
    if not packet then
        return
    end
    local name = msg.map(id)
    local data = json.decode(packet)
    if name == message.common_heartbeat_response then
        _heartbeat_time = socket.gettime()
    else
        handler(name, data)
    end
end

local function start_client()
    _client = uv.new_tcp()
    _client:connect(
        "127.0.0.1",
        10000,
        function(err)
            if err then
                p("Client connect error", err)
                _need_restart = true
                return
            end

            p("Client Connected!")

            _client:read_start(
                function(err, data)
                    if err then
                        p("Client read error: ", err)
                        _client:close()
                        _need_restart = true
                    end

                    if data then
                        recv(data)
                    else
                        p("Client data empty: ", err)
                        _client:close()
                        _need_restart = true
                    end
                end
            )
        end
    )
end

local function start()
    _need_restart = false
    start_client()
    send(
        "mono_login_request",
        {
            acc_type = "",
            acc_name = "AEMON32112" .. math.random(10000),
            passwd = "default"
        }
    )
end

timer.add(
    1000,
    function()
        if socket.gettime() - _heartbeat_time >= 3 then
            _need_restart = true
        end
        if _need_restart then
            start()
        end
        send("common_heartbeat_request", {time = socket.gettime()})
    end
)

start()
uv.run()
