local _config = {}
local _mt = {
    __index = {
        redis_host = "172.16.69.100",
        redis_port = 6379
    }
}
setmetatable(_config, _mt)
return _config
