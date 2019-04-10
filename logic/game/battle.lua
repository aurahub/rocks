local timer = require("core/timer")
local socket = require("socket")
local json = require("rapidjson")
local _matches = {}
local _players = {}
local _actions = {}

local _now

local _interval = 15
local _game_timeout = 120

local _born =
    json.decode(
    '[{"x":0,"y":0},{"x":6,"y":0},{"x":14,"y":1},{"x":5,"y":4},{"x":8,"y":9},{"x":1,"y":12},{"x":5,"y":12},{"x":14,"y":12}]'
)

local function get_object_id(table_id, cell_id, index)
    return bit.bor(bit.lshift(table_id, 24), bit.lshift(cell_id, 16)) + index
end

local function get_born_pos(match_id, index)
    local map_type, map_id = string.match("1@1|1|1", "(%d+)@(%d+).*")
    return {x = _born[index].x * 100, y = _born[index].y * 100}
end

local function get_index(match)
    local count = 1
    for _, _ in pairs(match.players) do
        count = count + 1
    end
    return count
end

local function new_match(match_id)
    _matches[match_id] =
        _matches[match_id] or
        {
            start = _now,
            players = {}
        }
    _actions[match_id] = _actions[match_id] or {}
end

local function join(match_id, player_id, notify_frame, notify_stop)
    local match = _matches[match_id]
    if not match then
        new_match(match_id)
    end
    match = _matches[match_id]
    local index = get_index(match)
    local born = get_born_pos(match_id, index)
    match.players[player_id] = {
        notify_frame = notify_frame,
        notify_stop = notify_stop,
        state = {
            player_id = player_id,
            object_id = get_object_id(2, 1, index),
            pos_x = born.x,
            pos_y = born.y,
            forward = 0
        }
    }
    _players[player_id] = match_id
end

local function act(player_id, action)
    local match_id = _players[player_id]
    local match = _matches[match_id]
    if match then
        action.player_id = player_id
        table.insert(_actions[match_id], action)
    end
end

local function merge(match_id)
    local actions = _actions[match_id]
    local match = _matches[match_id]
    if not actions or not match then
        return {}
    end
    local frame = {
        clock = _now - match.start,
        player_state = {}
    }
    local merge_actions = {}

    for _, action in pairs(actions) do
        local player_id = action.player_id
        local state = match.players[player_id].state
        state.pos_x = action.pos_x
        state.pos_y = action.pos_y
        state.forward = action.forward
    end
    _actions[match_id] = {}
    for _, data in pairs(match.players) do
        table.insert(frame.player_state, data.state)
    end
    return frame
end

local function stop(match_id)
    local result = {}
    for player_id, data in pairs(_matches[match_id].players) do
        data.notify_stop(result)
        _players[player_id] = nil
    end
    _matches[match_id] = nil
    _actions[match_id] = nil
end

local function update()
    _now = socket.gettime()
    for match_id, match in pairs(_matches) do
        local frame = merge(match_id)
        if _now - match.start > _game_timeout then
            stop(match_id)
        end
        for player_id, data in pairs(match.players) do
            data.notify_frame(frame)
        end
    end
end

timer.add(_interval, update)

return {
    join = join,
    act = act
}
