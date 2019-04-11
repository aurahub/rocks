line = "message account_login_request // {mod = 1, msg = 1} "
blank = "[%s|]*"
name = "[^%s]+"
inf = ".*"

_part = function(s)
    return string.format("(%s)", s)
end

print(string.match(line, "message1" .. inf))
print(string.match(line, "message" .. blank .. name .. blank .. inf))
print(
    string.match(line, "message" .. blank .. _part(name) .. blank .. "//" .. blank .. _part("{" .. inf .. "}") .. inf)
)

print(string.match("/1sdfsdf?sss", "[/|_]([%d]+).*"))

print(string.match("1@1|1|1", "(%d+)@(%d+).*"))