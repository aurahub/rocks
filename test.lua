require("deps/path")
local uv = require("luv")
-- local p = require("pretty-print").prettyPrint
-- p(uv.os_uname())
-- p(uv.os_gethostname())
-- p(uv.gettimeofday())
-- p(uv.cwd())

-- -- Create a handle to a uv_timer_t
-- local timer = uv.new_timer()

--     -- This will wait 1000ms and then continue inside the callback
--     timer:start(1000, 500, function ()
--     -- timer here is the value we passed in before from new_timer.

--     print ("Awake!")

--     -- You must always close your uv handles or you'll leak memory
--     -- We can't depend on the GC since it doesn't know enough about libuv.
--     -- timer:close()
--     end)

-- print("Sleeping");

-- uv.run()