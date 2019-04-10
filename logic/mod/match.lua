local battle = require("game/battle")
local message = require("core/message").t
local manager = require("game/manager")

local auth = function(s, request)
    local player_id = manager.get_player_id(s.token, s.client)
    if not player_id then
        s.error(1)
        return
    end

    if not request.match_id then
        s.error(2)
    end

    local match_id = request.match_id
    battle.join(
        match_id,
        player_id,
        function(frame)
            s.send(manager.query_client(player_id), message.match_frame_notice, frame)
        end,
        function(result)
            s.send(manager.query_client(player_id), message.match_stop_notice, result)
        end
    )

    s.reply()
end

local frame = function(s, request)
    local player_id = manager.get_player_id(s.token, s.client)
    if not player_id then
        return
    end

    battle.act(player_id, request)
end

return {
    frame = frame,
    auth = auth
}
