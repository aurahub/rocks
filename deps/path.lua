local package_path = {
    package.path,
	".\\?.lua",
	".\\?\\init.lua",
	".\\deps.\\?.lua",
	".\\deps.\\?.\\init.lua",
}
local package_cpath = {
    package.cpath,
    string.gsub(package.cpath, "%?", "clibs\\?")
}

package.path = table.concat(package_path, ";")
package.cpath = table.concat(package_cpath, ";")