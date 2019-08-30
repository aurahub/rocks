local lfs = require("lfs")
local protoc = require("protoc")
local pb = require("pb")

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

local function load_file(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    assert(protoc:load(content))
end

local function load_dir(dir)
    traverse(dir, load_file)
end

local function load(path)
    local attr = lfs.attributes(path)
    assert(attr, "path not exist " .. path)
    if attr and attr.mode and attr.mode == "directory" then
        load_dir(path)
    else
        load_file(path)
    end
end

return {
    load = load,
    encode = pb.encode,
    decode = pb.decode
}
