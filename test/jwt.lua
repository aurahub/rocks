local jwt = require "luajwt"

local key = "zwMKRFwlGdtB1nfFSdtCgHduYF3ZCXVY"

local claim = {
    iss = "rocks",
    nbf = os.time(),
    exp = os.time() + 3600,
    id = 1908778388
}

local alg = "HS256" -- default alg
local token, err = jwt.encode(claim, key, alg)

p("Token:", token)

local validate = true -- validate exp and nbf (default: true)
local decoded, err = jwt.decode(token, key, validate)

p("Claim:", decoded, err)

local jwt2 = require("util/jwt")
p(
    jwt2.decode(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJyb2NrcyIsImlkIjoxLCJuYmYiOjE1NTQ3MjY3NTUsImV4cCI6MjQxODcyNjc1NX0.jKwhGSlEsU_3KHeHvAZE8o9AnraTnfX9mn1qbqRYxmY"
    )
)
