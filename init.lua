return function(config)
    local var = require("luvit/libs/var")
    var.entry = function()
        require("rocks/app")(config)
    end
    require("luvit/luviinit")({"luvit"})
end
