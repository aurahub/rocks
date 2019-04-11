local lfs = require("lfs")
local url = require("util/url")
local P = require("util/print")

local _mapping = {}
local _handlers = {}
local _responses = {}
local _messages = {}

local _mod_prefix

local function get_pathes(rootpath, pathes)
    pathes = pathes or {}
    for entry in lfs.dir(rootpath) do
        if entry ~= "." and entry ~= ".." then
            local path = rootpath .. "/" .. entry
            local attr = lfs.attributes(path)
            assert(type(attr) == "table")
            if attr.mode == "directory" then
                getpathes(path, pathes)
            else
                table.insert(pathes, path)
            end
        end
    end
    return pathes
end

local function traverse(rootpath, func)
    for _, file in pairs(get_pathes(rootpath)) do
        func(file)
    end
end

local function readline(file, func)
    local f, err = assert(io.open(file, "rb"))
    if not err then
        for line in f:lines() do
            func(line)
        end
        f:close()
    end
end

local function eval(equation, variables)
    if (type(equation) == "string") then
        local eval = loadstring("return " .. equation)
        if (type(eval) == "function") then
            setfenv(eval, variables or {})
            return eval()
        end
    end
end

local function prepare_mapping(parts)
    local name = parts[1]
    local comment = eval(parts[2])
    local id = comment.mod * 256 + comment.msg
    if _mapping[id] or _mapping[name] then
        print("----------------------------------------")
        print("[error] proto id or name is repeated:\n", id, name)
        print("----------------------------------------")
    end
    _mapping[id] = name
    _mapping[name] = id
end

local function prepare_handlers(parts)
    local name = parts[1]
    local info = {string.match(name, "([%w]+)_([%w]+)_([%w]+)")}
    if #info >= 3 then
        local m, f, t = info[1], info[2], info[3]
        local reg = function()
            local mod = require("" .. _mod_prefix .. "/" .. m)
            if type(mod) ~= "table" then
                print("----------------------------------------")
                print("[error] module is not well preformed for message:\n", name)
                print("----------------------------------------")
                return
            end
            if (t == "request" or t == "response") and not mod[f] then
                print("----------------------------------------")
                print("[error] handler is not well preformed for message:\n", name)
                print("----------------------------------------")
                return
            end

            if t == "request" then
                _handlers[name] = mod[f]
            elseif t == "response" then
                _responses[mod[f]] = name
            end
            _messages[name] = name
        end
        local error = function(...)
            print("----------------------------------------")
            print("[error] require module exception:\n", name)
            print(...)
            print(debug.traceback())
            print("----------------------------------------")
        end
        xpcall(reg, error)
    end
end

local function match(line)
    if string.find(line, "[%s]*message.*") then
        local parts = {
            string.match(line, "[%s]*message[%s]*([^%s]+)[%s]*//[%s]*({.*}).*")
        }
        if #parts >= 2 then
            prepare_mapping(parts)
            if _mod_prefix then
                prepare_handlers(parts)
            end
        end
    end
end

local function load(dir, m)
    _mod_prefix = m
    traverse(
        dir,
        function(file)
            readline(file, match)
        end
    )
end

function url_parse_path(p)
    local id = string.match(p, "[/|_]([%d]+).*")
    return string.match(_mapping[tonumber(id)] or p, "[/|_]*([%w]+)[/|_]([%w]+).*")
end

local function map_url(u)
    local path, query = url.parse(u)
    if not path or not query then
        p("[message] url cannot resolve")
        return
    end

    local mod, handler = url_parse_path(path)
    p(mod, handler)
    if not mod or not handler then
        p("[message] url cannot resolve")
        return
    end
    local name = string.format("%s_%s_%s", mod, handler, "request")

    local query_params = url.parse_query(query)
    if not query_params.data then
        p("[message] url cannot resolve")
        return
    end

    return name, query_params.data, query_params.token
end

local function map(i)
    return _mapping[i]
end

local function handler(name)
    return _handlers[name]
end

local function response(handler)
    return _responses[handler]
end

return {
    load = load,
    map = map,
    handler = handler,
    response = response,
    map_url = map_url,
    t = _messages
}
