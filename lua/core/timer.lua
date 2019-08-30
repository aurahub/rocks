local uv = require("uv")

local _schedule = {}

local function error(...)
    print("[error] loop task run error:")
    print(debug.traceback(...))
end

local function add(interval, f)
    if not _schedule[interval] then
        _schedule[interval] = {}
        local timer = uv.new_timer()
        timer:start(
            0,
            interval,
            function()
                for k, t in pairs(_schedule[interval]) do
                    xpcall(t, error)
                end
            end
        )
        print("[timer] cycling interval " .. interval)
    end
    table.insert(_schedule[interval], f)
    return f
end

local function rm(interval, f)
    if not _schedule[interval] then
        return
    end
    local s = _schedule[interval]
    for k, t in pairs(s) do
        if f == t then
            s[k] = nil
        end
    end
end

return {
    add = add,
    rm = rm
}
