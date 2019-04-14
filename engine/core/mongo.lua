-- Pipeline:
--      The pipleline pool is more like redis pipeline with hash index.
--      Change Memory firstly, then save changes into db.
--      If task fails, find steam log to recover change, which needs to read a recovery point.
--      So remember to record a recovery point when saving changes.
--      Hash is used to support concurrency of saving.
--      Using 'fill' and 'heartbeat' is for maintenance of long connection.
-- Transaction:
--      The transaction pool is more like transaction in mysql.
--      No caching procedure, so there's no need to fear about task failing.
--      Upper logic need to lock db access for gettting transaction separated.
local var = require("var")
local mongo = var.require_bundle("luvit-mongodb")

local _instance

local function join(conn)
    for i, old_conn in pairs(_instance.pool) do
        if old_conn == conn then
            print("[mongo] conn already exists in pool", conn)
            return
        end
    end
    table.insert(_instance.pool, conn)
end

local function leave(conn)
    for i, old_conn in pairs(_instance.pool) do
        if old_conn == conn then
            _instance.pool[i] = nil
        end
    end
end

local function create(host, port, dbname)
    local conn = mongo:new({host = host, port = port, dbname = dbname})
    conn:on(
        "connect",
        function()
            conn:on(
                "error",
                function(err)
                    print("[mongo]socket error", err, conn)
                    leave(conn)
                end
            )
            conn:on(
                "close",
                function()
                    leave(conn)
                end
            )
        end
    )
    return conn
end

local function fill()
    for i = 1, _instance.capacity, 1 do
        if not _instance.pool[i] then
            print("[mongo] fill a new conncetion at index", i)
            join(create(_instance.host, _instance.port, _instance.dbname))
        end
    end
end

local function init(conf)
    conf = conf or {}
    _instance = {
        host = conf.host or "127.0.0.1",
        port = conf.port or 27017,
        dbname = conf.dbname or "rocks",
        capacity = conf.capacity or 1,
        pool = {}
    }
    fill()
    return instance
end

local get = function(hash_value)
    local hash_index = (hash_value % _instance.capacity) + 1
    return _instance.pool[hash_index]
end

return {
    init = init,
    fill = fill,
    heartbeat = heartbeat,
    get = get
}
