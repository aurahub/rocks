local blank = "[%s|]*"
local inf = ".*"
local split = "[/|_]"
local inf_n_qm = "[^%?]*%?"

p = function(s)
    return string.format("(%s)", s)
end

local line = "/account/login"
local line2 = "/account_login_request/?r={asdflsfjlsjdflsdjflkdj}"
local line3 = "/account_login_request/?{asdflsfjlsjdflsdjflkdj}"

print(string.match(line, split .. p("%w+") .. split .. p("%w+") .. inf))
print(string.match(line2, split .. p("%w+") .. split .. p("%w+") .. inf_n_qm .. p(".+")))
print(string.match(line3, split .. p("%w+") .. split .. p("%w+") .. inf_n_qm .. p(".+")))
