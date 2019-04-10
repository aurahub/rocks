local manager = require("game/manager")
local socket = require("socket")

local heartbeat = function(s, request)
    manager.heartbeat(s.client)
    local response = {}
    if request.time then
        response.time = socket.gettime()
    end
    s.reply(response)
end

return {
    heartbeat = heartbeat
}
