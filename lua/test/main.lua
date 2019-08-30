local _cwd = require("uv").cwd()

local paths = {
    "?.lua",
    _cwd .. "?.lua",
    -- _cwd .. "/logic/?.lua",
    -- _cwd .. "/engine/?.lua",
    _cwd .. "/deps/?.lua",
    _cwd .. "/luvi/?.lua",
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
print(require("luvi/init"))
require("luvi/init")({[0] = "luajit", [1] = "."})
for k, v in pairs(package.loaded) do
    print(k, v)
end
