require("deps/path").load()
local uv = require("luv")
local p = require("pretty-print").prettyPrint
p(uv.os_uname())
p(uv.os_gethostname())
p(uv.gettimeofday())
p(uv.cwd())

-- Create a handle to a uv_timer_t
local timer = uv.new_timer()

for i = 0, 1000, 1 do
    -- This will wait 1000ms and then continue inside the callback
    timer:start(2000, 0, function ()
    -- timer here is the value we passed in before from new_timer.

    print ("Awake!")

    -- You must always close your uv handles or you'll leak memory
    -- We can't depend on the GC since it doesn't know enough about libuv.
    timer:close()
    end)
end

print("Sleeping");

uv.run()