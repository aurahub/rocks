local package_path = {
    package.path,
	"?.lua",
	"?/init.lua",
	"deps/?.lua",
	"deps/?/init.lua",
}
local package_cpath = {
    package.cpath,
    "deps/?.dll",
    "D:/Program Files/Lua/systree/lib/lua/5.1/?.dll",
}
package.path = table.concat(package_path, ";")
package.cpath = table.concat(package_cpath, ";")