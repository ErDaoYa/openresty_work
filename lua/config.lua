local _config = {}
local _mt = {
    __index = {
        redis_host = "127.0.0.1",
        redis_port = 6379
    }
}
setmetatable(_config, _mt)
return _config
