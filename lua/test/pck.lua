local pb = require "core/protobuf"
local msg = require "core/message"
local spack = require "spack"
require "test/print"

pb.load("proto")
msg.load("proto")

local s = spack.gets()
local e, chunk =
    spack.send(s, msg.map("account_login_response"), pb.encode("account_login_response", {player_id = 100}))
local e, id, pb_data = spack.recv(s, chunk)

print(spack.send(s, msg.map("account_login_request"), pb.encode("account_login_request", {account = 1})))
ret = {spack.recv(s, "0014000000000001CAE=")}
print(#ret)
print(type(ret[3]))
