
local server = require "src/network"
local pb = require "src/protobuf"
local msg = require "src/message"
local spack = require "spack"
require "test/print"

data = {
    ["first"] = "value",
    ["second"] = 1,
    ["third"] = 1.0238888,
    ["fourth"] = "how length does the sentence need?1",
    ["fifth1"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth2"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth3"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth4"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth5"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth6"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth7"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth8"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    },
    ["fifth9"] = {
        ["first"] = "value",
        ["second"] = 1,
        ["third"] = 1.0238888,
        ["fourth"] = "how length does the sentence need?2",
        ["fifth"] = {
            ["first"] = "value",
            ["second"] = 1,
            ["third"] = 1.0238888,
            ["fourth"] = "how length does the sentence need?3",
            ["fifth"] = {
                ["first"] = "value",
                ["second"] = 1,
                ["third"] = 1.0238888,
                ["fourth"] = "how length does the sentence need?4",
                ["fifth"] = {}
            }
        }
    }
}

function test(json, libname)
    print("=================================")
    data_str = json.encode(data)

    start = os.clock()
    for i = 1, 1000 * 100 do
        json.encode(data)
    end
    stop = os.clock()
    print(libname .. " encode: " .. (stop - start))

    start = os.clock()
    for i = 1, 1000 * 100 do
        json.decode(data_str)
    end
    stop = os.clock()
    print(libname .. " decode: " .. (stop - start))

    start = os.clock()
    for i = 1, 1000 * 100 do
        data_str = json.encode(data)
        json.decode(data_str)
    end
    stop = os.clock()
    print(libname .. " encode&decode: " .. (stop - start))
end

pck_bench = {
    s = spack.gets(),
    load = function(file)
        pb.load("test/data.proto")
    end,
    encode = function(data)
        local e, chunk = spack.send(pck_bench.s, 0, pb.encode("Data", data))
        return chunk
    end,
    decode = function(chunk)
        local e, id, pb_data = spack.recv(pck_bench.s, chunk)
        return pb_data
    end
}
pck_bench.load("data.proto")


data = { player_id = 100 }


pck_bench_short = {
    s = spack.gets(),
    load = function(file)
        pb.load(file)
    end,
    encode = function(data)
        local e, chunk = spack.send(pck_bench_short.s, 0, pb.encode("account_login_response", data))
        return chunk
    end,
    decode = function(chunk)
        local e, id, pb_data = spack.recv(pck_bench_short.s, chunk)
        return pb_data
    end
}
pck_bench_short.load("proto")



test(pck_bench_short, "pck_bench_short")
-- =================================
-- pck_bench encode: 5.963854
-- pck_bench decode: 4.021543
-- pck_bench encode&decode: 10.652404
-- =================================
-- pck_bench_short encode: 0.17493
-- pck_bench_short decode: 0.095578
-- pck_bench_short encode&decode: 0.251237