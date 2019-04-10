local jwt = require "util/jwt"
local timer = require "core/timer"

local _clients = {} -- clients
local _players = {} -- players
local _states = {} -- hearbeats

local function get_player_id(token, client)
    local player_id
    if token then
        player_id = jwt.decode(token)
        if player_id and client then
            _clients[client] = player_id
            _players[player_id] = client
        end
    elseif client then
        player_id = _clients[client]
    end
    return player_id
end

local function query_client(player_id)
    return _players[player_id]
end

local function query_active(client)
    return _states[client] and _states[client].active
end

local function heartbeat(client)
    _states[client] = {t = os.time(), active = true}
end

local function update()
    local now = os.time()
    for client, state in pairs(_states) do
        if client then
            local duration = now - state.t
            if duration > 3 then
                state.active = false
            end
            if duration > 60 then
                local player_id = _clients[client]
                if player_id then
                    _clients[client] = nil
                    _players[player_id] = nil
                    _states[client] = nil
                end
            end
        end
    end
end

timer.add(500, update)

return {
    get_player_id = get_player_id,
    query_client = query_client,
    query_active = query_active,
    heartbeat = heartbeat
}
