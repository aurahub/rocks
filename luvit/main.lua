return require("./init")(
    function(...)
        local uv = require("uv")
        local var = require("var")

        local hooks = require("hooks")
        hooks:on("process.exit", uv.stop)

        var.free_unclosed = false
        var.require = _G.require
        var.require_bundle = require

        var.entry()
    end,
    ...
)
