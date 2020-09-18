
local os = require("os")
local hooks = require("hooks")
local timer = require("timer")
local utils = require("utils")
local uv = require("luv")
local errorEmitter = require("core").errorEmitter
local pp = require("pretty-print")
local UvStreamWritable = require("process/uv_stream").UvStreamWritable
local UvStreamReadable = require("process/uv_stream").UvStreamReadable
local on = require("process/signal").on
local removeListener = require("process/signal").removeListener

-- global process declareation
local process = {}

local function kill(pid, signal)
    uv.kill(pid, signal or "sigterm")
end

local function exit(self, code)
    local left = 2
    code = code or 0
    local function onFinish()
        left = left - 1
        if left > 0 then
            return
        end
        self:emit("exit", code)
        os.exit(code)
    end
    process.stdout:once("finish", onFinish)
    process.stdout:_end()
    process.stderr:once("finish", onFinish)
    process.stderr:_end()
end

local function bootstrap(entry, ...)
    process.argv = {...}
    entry(...)
    uv.run()
end

local function initProcess()
    setmetatable(process, {__index = errorEmitter})
    process.bootstrap = bootstrap
    process.exitCode = 0
    process.kill = kill
    process.exit = exit
    process.on = on
    process.removeListener = removeListener
    if uv.guess_handle(0) ~= "file" then
        process.stdin = UvStreamReadable:new(pp.stdin)
    else
        -- special case for 'file' stdin handle to avoid aborting from
        -- reading from a pipe to a file descriptor
        -- see https://github.com/luvit/luvit/issues/1094
        process.stdin = require("fs").ReadStream:new(nil, {fd = 0})
    end
    process.stdout = UvStreamWritable:new(pp.stdout)
    process.stderr = UvStreamWritable:new(pp.stderr)
    hooks:on("process.exit", utils.bind(process.emit, process, "exit"))
    hooks:on("process.uncaughtException", utils.bind(process.emit, process, "uncaughtException"))
end
initProcess()

return process