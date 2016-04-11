local cjson = require "cjson"
local config = require "config"
ngx.say(config["redis_host"])
