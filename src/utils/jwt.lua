local jwt = _G.require("luajwt")

local _key = "zwMKRFwlGdtB1nfFSdtCgHduYF3ZCXVY"
local _alg = "HS256"
local function encode(id)
    local claim = {
        iss = "rocks",
        nbf = os.time(),
        exp = os.time() + 3600 * 24 * 10000,
        id = id
    }

    return jwt.encode(claim, _key, _alg)
end

local function decode(token)
    local data, err = jwt.decode(token, _key, true)
    if not err then
        if data.exp > os.time() then
            return data.id
        end
    end
end

return {
    encode = encode,
    decode = decode
}
