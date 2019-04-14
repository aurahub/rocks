local aura_deps = {
    "spack"
}

for _, libname in pairs(aura_deps) do
    os.execute("git clone https://github.com/aurahub/" .. libname .. ".git")
    os.execute("cd " .. libname .. ";chomd 755 install.sh; ./install.sh; cd ..")
    print("aurahub install " .. libname .. " ok.")
end

--[[
    apt-get upgrade & apt-get update
    apt-get install build-essential
    apt-get install cmake
    apt-get install vim
    apt-get install git
    apt-get install curl
    apt-get install luarocks

    apt-get install libssl-dev
    apt-get install libjemalloc-dev
    apt-get install libboost-all-dev
    apt-get install libghc-pcre-light-dev
    apt-get install zlib1g-dev
    apt-get install libuv1-dev

    luarocks install luv
    luarocks install lua-cjson
    luarocks install luasocket
    luarocks install lua-protobuf
    luarocks install luafilesystem
    luarocks install rapidjson
    luarocks install luacrypto
    luarocks install deque
    luarocks install lbase64
    luarocks install lrexlib-pcre
    luarocks install luajwt
    luarocks install openssl
    luarocks install lua-zlib
  
    wget http://luajit.org/download/LuaJIT-2.0.5.zip
    git clone https://github.com/aurahub/spack.git;

docker stop rocks;docker rm rocks;docker run -d -p 10000:10000 -p 10080:10080 --name rocks --hostname rocks -v /C/Users/Administrator/Documents/data:/data --link 357c133ae4a4:mongo -w /data/server/ rocks luajit logic/server.lua
docker stop rocks;docker rm rocks;docker run -it -p 10000:10000 -p 10080:10080 --name rocks --hostname rocks -v /C/Users/Administrator/Documents/data:/data --link 357c133ae4a4:mongo rocks /bin/bash

]]
