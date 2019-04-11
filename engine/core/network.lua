local uv = require("uv")
local spack = require("spack")
local luvit_http = require("http")

local _mapping = {}

local function tcp(conf, user_accept, user_recv)
    local host, port, keep_alive, backlog = conf.host, conf.port, conf.keep_alive, conf.backlog
    local server

    local function close(client)
        if client:is_closing() then
            return
        end
        spack.puts(_mapping[client])
        _mapping[client] = nil
        client:close()
    end

    local function send(client, id, p)
        if not client then
            return
        end
        e, chunk = spack.send(_mapping[client], id, p)
        if e <= 0 then
            print("[network] when sending packet goes into exception, close the socket " .. tostring(client))
            close(client)
        end
        client:write(chunk)
    end

    local function accept(err)
        if err then
            print("[network] when accepting goes into exception, close the socket " .. tostring(client))
            close(client)
        end

        local client = uv.new_tcp()
        uv.tcp_keepalive(client, true, keep_alive)
        server:accept(client)

        _mapping[client] = spack.gets()
        user_accept(client)

        client:read_start(
            function(err, chunk)
                if err then
                    print("[network] when stream goes into exception, close the socket " .. tostring(client))
                    close(client)
                end

                if chunk then
                    local e, id, p = spack.recv(_mapping[client], chunk)
                    while e > 0 do
                        user_recv(client, id, p)
                        e, id, p = spack.recv(_mapping[client])
                    end
                    if e < 0 then
                        print(
                            "[network] when receiving packet goes into exception, close the socket " .. tostring(client)
                        )
                        close(client)
                    end
                else
                    print("[network] when the stream ends, close the socket " .. tostring(client))
                    close(client)
                end
            end
        )
        print("[network] when accepting a new client , start read from the socket " .. tostring(client))
    end

    server = uv.new_tcp()
    server:bind(host, port)
    server:listen(backlog, accept)

    assert(server:getsockname())
    print("[network] tcp listening on port " .. server:getsockname().port)

    local user_send = function(client, id, p)
        send(client, id, p)
    end

    local user_close = function(client)
        print("[network] when received the user's close command, close the socket " .. tostring(client))
        close(client)
    end
    return user_send, user_close
end

local function http(conf, handler)
    local server = luvit_http.createServer(handler):listen(conf.port, conf.host)
    print("[network] http listening at http://" .. conf.host .. ":" .. conf.port .. "/")
    return server
end

return {
    tcp = tcp,
    http = http
}
