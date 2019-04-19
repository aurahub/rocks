package.path =
    package.path ..
    ";/Users/tony/Documents/project/bnb/server/logic/?.lua" ..
        ";/Users/tony/Documents/GitHub/server/rocks/?.lua" ..
            ";?.lua" .. ";/Users/tony/.luaver/luarocks/3.0.4_5.1/share/lua/5.1/*.lua"

local url = require("utils/url")
local P = require("test/print")

P(url.parse("head http://user:pass@host.com:8080/p/a/t/h/?query=string#hash tail", true, 5))

--[[
res = {
    scheme = "http",
    userinfo = "user:pass",
    user = "user",
    password = "pass",
    host = "host.com:8080",
    hostname = "host.com",
    port = "8080",
    path = "/p/a/t/h/",
    query = "?query=string",
    queryParams = {
        query = "string"
    },
    fragment = "hash"
}
cur = 62
err = " "
--]]
-- parse query
P(url.parse("head ?query=string#hash tail", false, 5))

--[[
res = {
    fragment = "hash",
    query = "?query=string",
}
cur = 23,
err = " "
--]]
-- P(url.parse("/account_login_request/?r={asdflsfjlsjdflsdjflkdj}", true))
-- P(url.parse("/account/login/request/?r={asdflsfjlsjdflsdjflkdj}", true))
-- P(url.parse("/account/login/request/", true))

-- P(url.deode("{%22acc_type%22:%22%22,%22acc_name%22:%22adfasf%22,%22passwd%22:%22default%22}"))
-- P(socket_url.parse("/account_login_request/?r={asdflsfjlsjdflsdjflkdj}"))
-- print(url.resolve("/account_login_request/?data={asdflsfjlsjdflsdjflkdj}&token=11111"))
print(url.resolve("/account_login_request/?data={asdflsfjlsjdflsdjflkdj}&token=11111"))
