local deque = require "deque"

local work_queue = deque()
local _task_id = 0
local _task = function()
    print("handle", _task_id)
end

for i = 0, 100, 1 do
    _task_id = _task_id + 1
    work_queue:pushLeft(_task)
end

for t in work_queue:iterRight() do --iterates through the items, from right to left
    t()
end