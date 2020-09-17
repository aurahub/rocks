local jit = require("jit")

local map = {
    ["Windows"] = "win32",
    ["Linux"] = "linux",
    ["OSX"] = "darwin",
    ["BSD"] = "bsd",
    ["POSIX"] = "posix",
    ["Other"] = "other"
}

local function type()
    return map[jit.os]
end

return {type = type}
