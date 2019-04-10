local rocks_deps = {
    "luasocket",
    "lua-protobuf",
    "luafilesystem",
    "rapidjson",
    "deque",
    "luacrypto", -- luarocks install luacrypto OPENSSL_DIR=/usr/local/Cellar/openssl/1.0.2r/; --apt-get install libssl-dev
    "luajwt",
    "lbase64"
}

local aura_deps = {
    "spack"
}

local _lit_deps = {
    "cyrilis/luvit-mongodb" -- no need to install, already in project
}

for _, libname in pairs(rocks_deps) do
    os.execute("luarocks install " .. libname)
    print("luarocks install " .. libname .. " ok.")
end

for _, libname in pairs(aura_deps) do
    os.execute("git clone https://github.com/aurahub/" .. libname .. ".git")
    os.execute("cd " .. libname .. ";chomd 755 install.sh; ./install.sh; cd ..")
    print("aurahub install " .. libname .. " ok.")
end

for _, libname in pairs(lit_deps) do
    os.execute("lit install " .. libname)
    print("lit install " .. libname .. " ok.")
end

--[[
    apt-get upgrade & apt-get update
    apt-get install build-essential
    apt-get install luajit-5.1-dev
    apt-get install luvit
    apt-get install luarocks
    apt-get install libssl1.0-dev
    apt-get install vim
    apt-get install git
    apt-get install curl
    apt-get install libjemalloc-dev
    apt-get install libboost-all-dev
    luarocks install luasocket
    luarocks install lua-protobuf
    luarocks install luafilesystem
    luarocks install rapidjson
    luarocks install deque
    luarocks install lbase64
    luarocks install 
    luarocks install luajwt
    cd /tmp/;curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh; cp * /usr/local/bin/;rm -rf /tmp/*
    cd /tmp/;git clone https://github.com/aurahub/spack.git;cd spack;mdir build;cd build;cmake ..;make install;rm -rf /tmp/*
]]
