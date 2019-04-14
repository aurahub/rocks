#!/usr/local/bin/luajit
local _cwd = require("luv").cwd()
for _, path in ipairs(
    {
        _cwd .. "/luvit/?.lua",
        _cwd .. "/luvit/libs/?.lua",
        _cwd .. "/luvit/deps/?.lua",
        _cwd .. "/engine/?.lua",
        _cwd .. "/logic/?.lua",
        "/?.lua"
    }
) do
    package.path = package.path .. ";" .. path
end

local var = require("var")
var.entry = function()
    var.require("engine/init")(
        {
            tcp = {
                port = 10001
            },
            proto_path = _cwd .. "/logic/proto",
            mod_path = _cwd .. "/logic/mod"
        }
    )
end

require("luviinit")({"luvit"})
