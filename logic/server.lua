_G.luvit_require = require
local paths = {
    "?.lua",
    "/Users/tony/Documents/project/bnb/server/logic/?.lua",
    "/Users/tony/Documents/GitHub/server/rocks/?.lua",
    "/Users/tony/Documents/GitHub/server/rocks/deps/?.lua",
    "/Users/tony/Documents/GitHub/server/rocks/deps/?/init.lua"
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

require("app").run(
    {
        tcp = {
            port = 10000
        },
        proto_path = "/Users/tony/Documents/project/bnb/server/logic/proto",
        mod_path = "/Users/tony/Documents/project/bnb/server/logic/mod"
    }
)
