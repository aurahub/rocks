require("deps/path/init")
local uv = require("luv")
local p = require("pretty-print").prettyPrint
p(uv.os_uname())
p(uv.os_gethostname())
p(uv.gettimeofday())
p(uv.cwd())