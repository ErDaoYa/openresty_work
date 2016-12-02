local services = ngx.shared.services;
local redis = require ("redis_iresty")

local set_shared = function()
	local red = redis:new()
    local keys, err = red:keys("bs*")
    if err or type(keys) ~= "table" then
        ngx.log(ngx.ERR, "failed to get keys form redis, err : ", err)
        return
    end
	for k,v in pairs(keys)do
		local address =  red:hget(v, "address")
		-- location_regex = v.split("bs:service:")
		ngx.log(ngx.ERR, v,address)
	end
    local ok, err, forc = services:set("/user/user", ok);
    if not ok then
        ngx.log(ngx.ERR,"failed to set upstream",err)
    end
end

-- redis subscribe
local subscribe_redis = function()
	local func = redis:subscribe( "service" )
	if not func then
		ngx.log(ngx.ERR, "subcrible failed ", err)
	end

	while true do
		local res, err = func()
		if err then
			func(false)
		end
		if res then
			ngx.log(ngx.ERR, "the message is ", res[3])
		end
	end
end

-- 判断nginx状态
local nginx_stoped = false
-- ngnix status judge
ngx_status_handler = function(premature)
    if premature then
        nginx_stoped = true
        ngx.log(ngx.ERR, "nginx is stoping or reloading ...")
        return
    end
    nginx_stoped = false
    ngx.log(ngx.INFO, "nginx worker " .. ngx.worker.id() .." is runing...")
    ngx.timer.at(30, ngx_status_handler)
end

-- 只开一个worker处理这个定时器
if 0 == ngx.worker.id() then
    local ok, err = ngx.timer.at(0, ngx_status_handler)
    if not ok then
        log(ngx.ERR, "failed to create timer: ", err)
        return
    end
	if not nginx_stoped then
		local ok, err = ngx.timer.at(0, set_shared)
		if not ok then
			log(ngx.ERR, "failed to create timer for get service form redis: ", err)
		end
		local ok, err = ngx.timer.at(0, subscribe_redis)
		if not ok then
			log(ngx.ERR, "failed to create timer to redis sub: ", err)
		end
	end
end
