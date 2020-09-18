local package_path = {
    package.path,
	"?.lua",
	"?/init.lua",
	"deps/?.lua",
	"deps/?/init.lua",
}
local package_cpath = {
    package.cpath,
    "deps"
}

local function load()
    package.path = table.concat(package_path, ";")
    package.cpath = table.concat(package_cpath, ";")
end

return {
    load = load
}