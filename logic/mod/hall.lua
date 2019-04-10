local msg = require "core/message"
local mongo = require "core/mongo"
local jwt = require "util/jwt"
local manager = require "game/manager"

local function auth(s, request)
    local player_id = manager.get_player_id(s.token or request.token, s.client)
    if not player_id then
        s.error(1)
        return
    end

    s.reply({player_id = player_id})
end
-- http://0.0.0.0:10080/hall/auth?data={}&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJyb2NrcyIsImlkIjoyLCJuYmYiOjE1NTQ3MTY4ODYsImV4cCI6MjQxODcxNjg4Nn0.9yApu7aWIpKIVpjLAb3GSK1IwrNPixOcl3yTv7AJSE0

return {
    auth = auth
}
