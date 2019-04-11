pb = require "core/protobuf"
require "util/print"
require "base64"

pb.load("logic/proto")
-- Print(pb.encode("account_login_request", {}))
-- local resp = pb.encode("account_login_response", {player_id = 100})
-- Print(resp)
-- Print(pb.decode("account_login_response", resp))

-- p(pb.decode("room_enter_response", base64.decode("EgAIAQ==")))

local l =
    "CpwBZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBjM01pT2lKeWIyTnJjeUlzSW1sa0lqb3hMQ0p1WW1ZaU9qRTFOVFEzTWpnek1UQXNJbVY0Y0NJNk1qUXhPRGN5T0RNeE1IMC5Dbjk0NE1KM2ZtdlhiWlg3Y2F0RU5WaUZKUlhqbkpsMWwxTHhjNUx5bVJj"
-- local ls = string.sub(l, 17)
p(ls)
ls = l
p(pb.decode("hall_auth_request", base64.decode(ls)))

-- local data = {
--     token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJyb2NrcyIsImlkIjoxLCJuYmYiOjE1NTQ3MjgzMTAsImV4cCI6MjQxODcyODMxMH0.Cn944MJ3fmvXbZX7catENViFJRXjnJl1l1Lxc5LymRc"
-- }

-- p(base64.encode(pb.encode("hall_auth_request", data)))
