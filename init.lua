local uv = require("uv")
local getenv = uv.os_getenv
local setenv = uv.os_setenv
if not getenv("LUVI_PATH") then
    setenv("LUVI_PATH", "/usr/local/share/lua/5.1/luvi/")
end
if not getenv("LUVI_BUNDLE_PATH") then
    setenv("LUVI_BUNDLE_PATH", "/usr/local/share/lua/5.1/")
end

local function token(command)
    local tokens = {}
    for t in string.gmatch(command, "[^%s]+") do
        table.insert(tokens, t)
    end
    return tokens
end

local function dirname(str)
    if str:match(".-/.-") then
        local name = string.gsub(str, "(.*/)(.+)", "%1")
        return name
    elseif str:match(".-\\.-") then
        local name = string.gsub(str, "(.*\\)(.+)", "%1")
        return name
    else
        return ""
    end
end

local function set_path()
    local rocks_dir = dirname(debug.getinfo(1, "S").source:sub(2))
    local root_dir = "/"
    package.path = package.path .. ";" .. rocks_dir .. "?.lua"
    package.path = package.path .. ";" .. rocks_dir .. "?/init.lua"
    package.path = package.path .. ";" .. root_dir .. "?.lua"
    package.path = package.path .. ";" .. root_dir .. "?/init.lua"
    print("-------------package.path-----------------")
    for token in string.gmatch(package.path, "[^%;]+") do
        print(token)
    end
    print("-------------package.cpath----------------")
    for token in string.gmatch(package.cpath, "[^%;]+") do
        print(token)
    end
    print("------------------------------------------")
end

return function(config)
    require("luvi/main")(token("luvit --main main.lua"))(
        function(...)
            set_path()
            require("rocks/app")(config)
        end
    )
end
