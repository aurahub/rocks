local jwt = require("util/jwt")
local enqueue = require("core/async").enqueue
local async = require("core/async").async
-- local mongo = require("core/mongo")

local function sum_str(str)
    local hash = 0
    for _, c in pairs({string.byte(str, 1, #str)}) do
        hash = hash + c
    end
    return hash
end

local function login_coro(co, s, req)
    local acc_type = req.acc_type == "" and "visitor"
    local acc_name = req.acc_name
    local passwd = req.passwd == "" and "default"
    -- local db = mongo.get(sum_str(string.format("%s@%s", acc_name, acc_type)))

    local player_id = math.random(1, 10000)
    -- local account = db:collection("account")
    -- local err, res = async(co, account.findOne, account, {acc_type = acc_type, acc_name = acc_name})
    -- if err then
    --     p("[login] account.findOne error")
    --     return
    -- end

    -- local player_id
    -- if res then
    --     if res.passwd ~= passwd then
    --     -- s.error(1)
    --     end
    --     player_id = res.player_id
    -- else
    --     local counters = db:collection("counters")
    --     local err, res = async(co, counters.findAndModify, counters, {key = "player_id"}, {["$inc"] = {next = 1}})
    --     if err then
    --         p("[login] counters.findAndModify error")
    --         s.error(2)
    --         return
    --     end

    --     player_id = res[1].next
    --     local err, res =
    --         async(
    --         co,
    --         account.insert,
    --         account,
    --         {acc_type = acc_type, acc_name = acc_name, passwd = "default", player_id = player_id}
    --     )
    --     if err then
    --         p("[login] account.insert error")
    --         s.error(3)
    --         return
    --     end
    -- end

    p("[login] player " .. player_id .. " login")
    local token, err = jwt.encode(player_id)
    if err then
        p("[login] gen_token error")
        s.error(4)
        return
    end
    s.reply({token = token})
end

local function login(s, req)
    enqueue("login", login_coro, s, req)
end
-- http://0.0.0.0:10080/mono/login?data={"acc_type":"","acc_name":"adfasf","passwd":"default"}

return {
    login = login
}
