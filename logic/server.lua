local lfs = require("lfs")
local _cwd = lfs.currentdir() -- must run in project dir

local paths = {
    "?.lua",
    _cwd .. "/logic/?.lua",
    _cwd .. "?.lua",
    _cwd .. "/deps/?.lua",
    _cwd .. "/deps/?/init.lua"
}
for _, path in pairs(paths) do
    package.path = package.path .. ";" .. path
end

local cpaths = {
    "/usr/lib/x86_64-linux-gnu/lua/5.1/?.so" --debian
}
for _, path in pairs(cpaths) do
    package.cpath = package.cpath .. ";" .. path
end

_G.p = require("pretty-print").prettyPrint
_G.print = _G.p
require("app").run(
    {
        tcp = {
            port = 10000
        },
        proto_path = _cwd .. "/logic/proto",
        mod_path = _cwd .. "/logic/mod"
    }
)
