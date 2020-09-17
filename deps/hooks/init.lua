local Emitter = require("core").Emitter
--luacheck: new globals exports
local e = exports or {}
setmetatable(e, Emitter.meta)
if e.init then
    e:init()
end
return e
