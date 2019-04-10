local contest = require("game/contest")
local manager = require("game/manager")
local message = require("core/message").t

local function enter(s, request)
    local player_id = manager.get_player_id(s.token, s.client)
    if not player_id then
        s.error(1)
        return
    end

    local room, room_id, pos, pos_id
    room, room_id, pos, pos_id =
        contest.enter(
        request.map_type,
        request.map_id,
        player_id,
        function(match_id)
            s.send(
                manager.query_client(player_id),
                message.room_start_notice,
                {
                    map_type = request.map_type,
                    map_id = request.map_id,
                    player_id = player_id,
                    match_id = match_id
                }
            )
        end
    )
    local player_id_list = {}
    for pos_id = 1, room.capacity, 1 do
        player_id_list[pos_id] = room[pos_id] and room[pos_id].player_id or 0
    end
    s.reply({players = {list = player_id_list}, room_id = room_id, pos_id = pos_id})
end
-- http://0.0.0.0:10080/room/enter?data={"map_type":1,"map_id":1}&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJyb2NrcyIsImlkIjoyLCJuYmYiOjE1NTQ3MTY4ODYsImV4cCI6MjQxODcxNjg4Nn0.9yApu7aWIpKIVpjLAb3GSK1IwrNPixOcl3yTv7AJSE0

local function prepare(s, request)
    local player_id = manager.get_player_id(s.token, s.client)
    if not player_id then
        s.error(1)
        return
    end

    if not contest.prepare(request.map_type, request.map_id, request.room_id, request.pos_id, player_id) then
        s.error(2)
        return
    end
    s.reply()
end
-- http://0.0.0.0:10080/room/prepare?data={"map_type":1,"map_id":1, "room_id":1, "pos_id":1}&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJyb2NrcyIsImlkIjoyLCJuYmYiOjE1NTQ3MTY4ODYsImV4cCI6MjQxODcxNjg4Nn0.9yApu7aWIpKIVpjLAb3GSK1IwrNPixOcl3yTv7AJSE0

return {
    prepare = prepare,
    enter = enter
}
