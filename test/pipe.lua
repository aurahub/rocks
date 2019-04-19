local async = require "core/async"

local function a()
    print("a")
end
local function b(d)
    print("b")
end
pipeline.enqueue("test", a)
for i = 0, 10, 1 do
    pipeline.enqueue("test", b)
end
