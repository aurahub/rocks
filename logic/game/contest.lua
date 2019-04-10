local timer = require "core/timer"
local manager = require "game/manager"
local socket = require "socket"

local _contest = {}
local _meta = {}
local _players = {}

local _now
local function update()
    _now = socket.gettime()
    for map_key, rooms in pairs(_contest) do
        for room_id, room in pairs(rooms) do
            p(room)
            local count = 0
            for pos_id, pos in pairs(room) do
                if not manager.query_active(manager.query_client(pos.player_id)) then -- clear player
                    room[pos_id] = nil
                    _players[pos.player_id] = nil
                elseif pos.prepare then
                    count = count + 1
                end
            end
            if count >= 2 then -- can start
                local match_id = string.format("%s|%s|%s", map_key, room_id, _now)
                for _, pos in pairs(room) do
                    pos.notify_start(match_id)
                end
                for pos_id, pos in pairs(room) do
                    _players[pos.player_id] = nil
                end
                rooms[room_id] = nil
            end
            local pos_count = 0
            for _, _ in pairs(room) do
                pos_count = pos_count + 1
            end
            if pos_count == 0 then
                rooms[room_id] = nil
            end
        end
        local room_count = 0
        for _, _ in pairs(rooms) do
            room_count = room_count + 1
        end
        if room_count == 0 then
            _contest[map_key] = nil
        end
    end
end

timer.add(1000, update)

local function new_map(map_key)
    _contest[map_key] = {}
    _meta[map_key] = {
        __index = {
            capacity = 8
        }
    }
end

local function new_room(map_key)
    _contest[map_key] = _contest[map_key] or {}
    local rooms = _contest[map_key]
    local room = {}
    table.insert(rooms, room)
    setmetatable(room, _meta[map_key])
end

local function find_pos(map_key)
    local rooms = _contest[map_key]
    for room_id, room in pairs(rooms) do
        for pos_id = 1, room.capacity, 1 do
            if not room[pos_id] then
                local pos = {}
                room[pos_id] = pos
                return room, room_id, pos, pos_id
            end
        end
    end
end

local function ensure_find_pos(map_type, map_id)
    local map_key = string.format("%s@%s", map_id, map_type)
    if not _contest[map_key] then
        new_map(map_key)
    end
    local room, room_id, pos, pos_id = find_pos(map_key)
    if not room then
        new_room(map_key)
        room, room_id, pos, pos_id = find_pos(map_key)
    end
    return room, room_id, pos, pos_id
end

local function enter(map_type, map_id, player_id, notify_start)
    if _players[player_id] then
        return
    end
    local room, room_id, pos, pos_id = ensure_find_pos(map_type, map_id)
    _players[player_id] = pos
    pos.player_id = player_id
    pos.prepare = false
    pos.notify_start = notify_start
    return room, room_id, pos, pos_id
end

local function prepare(map_type, map_id, room_id, pos_id, player_id)
    local map_key = string.format("%s@%s", map_id, map_type)
    local rooms = _contest[map_key]
    if not rooms then
        p("[contest] prepare no rooms")
        return
    end
    local room = rooms[room_id]
    if not room then
        p("[contest] prepare no room")
        return
    end
    local pos = room[pos_id]
    if not pos then
        p("[contest] prepare no pos")
        return
    end
    if player_id ~= pos.player_id then
        p("[contest] prepare player_id error")
        return
    end
    pos.prepare = true
    return true
end

return {
    prepare = prepare,
    enter = enter
}
