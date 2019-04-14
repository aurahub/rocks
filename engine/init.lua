local uv = require("uv")
local network = require("core/network")
local timer = require("core/timer")
local msg = require("core/message")
local protobuf = require("core/protobuf")
local signal = require("core/signal")
local mongo = require("core/mongo")
local async = require("core/async")
local socket = require("socket")
local json = require("rapidjson")
local base64 = require("base64")
local url = require("utils/url")
local jwt = require("utils/jwt")
local json = require("rapidjson")
local _cwd = uv.cwd()

local _conf = {
    tcp = {
        host = "0.0.0.0",
        port = 10000,
        keep_alive = 60,
        backlog = 128
    },
    http = {
        host = "0.0.0.0",
        port = 10080
    },
    mongo = {
        host = "127.0.0.1",
        port = 27017,
        dbname = "rocks",
        capacity = 1,
        fill_interval = 1000
    },
    proto_path = _cwd .. "/logic/proto",
    mod_path = _cwd .. "/logic/mod",
    serialization = "json" -- "protobuf"
}

local _ser = {}

local function init_ser(t)
    if _conf.serialization == "json" then
        _ser.encode = function(name, data)
            if msg.map(name) > 255 then
                p("<=", name, data)
            end
            return json.encode(data)
        end
        _ser.decode = function(name, packet)
            local data = json.decode(packet)
            if msg.map(name) > 255 then
                p("=>", name, data)
            end
            return data
        end
    elseif _conf.serialization == "protobuf" then
        _ser.encode = function(name, data)
            p("<=", name, data)
            return protobuf.encode(name, data)
        end
        _ser.decode = function(name, packet)
            local data = protobuf.decode(packet)
            p("=>", name, data)
            return data
        end
    end
end

local net_send, net_close

local function send(client, name, data)
    data = data or {}
    local id = msg.map(name)
    net_send(client, id, _ser.encode(name, data))
end

local function close(client)
    net_close(client)
end

local function accept(client)
end

local function reply(client, handler, data)
    local response = msg.response(handler)
    if response then
        send(client, response, data)
    else
        print("response not found")
    end
end

local function error(...)
    print("----------------------------------------------------------")
    print(...)
    print(debug.traceback())
    print("----------------------------------------------------------")
end

local function recv(client, id, packet)
    local function work()
        local name = msg.map(id)
        if not name then
            print("message id not found", id)
            return
        end

        local handler = msg.handler(name)
        if not handler then
            print("[app]handler not found", name)
            return
        end

        local s = {
            client = client,
            close = close,
            send = send,
            reply = function(data)
                data = data or {}
                data.err = 0
                data.msg = ""
                reply(client, handler, data)
            end,
            error = function(err)
                local data = {}
                data.err = err
                data.msg = ""
                reply(client, handler, data)
            end
        }

        local data = _ser.decode(name, packet)
        handler(s, data)
    end

    local status, err = xpcall(work, error)
end

-- TODO: support post, support token
local function on_request(req, res)
    local function work()
        local name, packet, token = msg.map_url(req.url)
        if not name then
            print("[app] name not found:", req.url)
            return
        end

        local handler = msg.handler(name)
        if not handler then
            print("[app] handler not found:", name)
            return
        end

        local s = {
            token = token,
            close = function()
            end,
            notify = function()
            end,
            reply = function(data)
                data = data or {}
                data.err = 0
                data.msg = ""
                local body = json.encode(data)
                res:setHeader("Content-Type", "text/plain")
                res:setHeader("Content-Length", #body)
                res:finish(body)
            end,
            error = function(err)
                local data = {}
                data.err = err
                data.msg = ""
                local body = json.encode(data)
                res:setHeader("Content-Type", "text/plain")
                res:setHeader("Content-Length", #body)
                res:finish(body)
            end
        }

        if req.method == "GET" then
            handler(s, json.decode(packet))
        elseif req.method == "POST" then
        end
    end

    xpcall(work, error)
end

local function assign(t_conf, m_conf)
    for k, v in pairs(t_conf) do
        if type(v) == "table" then
            m_conf[k] = m_conf[k] or {}
            assign(t_conf[k], m_conf[k])
        else
            m_conf[k] = t_conf[k]
        end
    end
end

local function run(conf)
    assign(conf, _conf)

    protobuf.load(_conf.proto_path)
    msg.load(_conf.proto_path, _conf.mod_path)
    init_ser(_conf.serialization)

    net_send, net_close = network.tcp_server(_conf.tcp, accept, recv)
    mongo.init(_conf.mongo)
    timer.add(_conf.mongo.fill_interval, mongo.fill)

    network.http_server(_conf.http, on_request)

    signal.set(uv.stop)
end

return run
