local lfs = require("lfs")
local _cwd = lfs.currentdir() -- must run in project dir

local paths = {
    "?.lua",
    _cwd .. "?.lua",
    _cwd .. "/logic/?.lua",
    _cwd .. "/engine/?.lua",
    _cwd .. "/deps/?.lua"
    -- _cwd .. "/deps/?/init.lua",
    -- _cwd .. "/deps/luvit/?.lua"
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

-- local mainRequire = require('require')("bundle:main.lua")
-- _G.p = mainRequire("pretty-print").prettyPrint

require("init")({[0] = "luajit",[1] = "deps/luvit-mongodb"})