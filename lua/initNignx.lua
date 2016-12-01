local services = ngx.shared.services;
local redis = require ("redis_iresty")
local red = redis:new()

local set_shared = function()
    local ok, err = red:get("/user/user")
    if not ok then
        ngx.log(ngx.ERR, "failed to get service form redis: ", err)
        return
    end
    local ok, err, forc = services:set("/user/user", ok);
    if not ok then
        ngx.log(ngx.ERR,"failed to set upstream",err)
    end
end

-- redis subscribe
local subscrible_redis = function()
	local red = redis:new({timeout=1000})
	local func = red:subscribe( "service" )
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

-- ngnix status judge
local nginx_status = false
ngx_sta_handler = function(premature)
    if premature then
        nginx_status = true
        ngx.log(ngx.ERR, "nginx is stoping or reloading ...")
        return
    end
    nginx_status = false
    set_shared()
    ngx.log(ngx.ERR, "nginx worker " .. ngx.worker.id() .." is runing...")
    ngx.timer.at(60, ngx_sta_handler)
end

-- ngx.timer.at(0, ngx_sta_handler)
if 0 == ngx.worker.id() then
    local ok, err = ngx.timer.at(0, ngx_sta_handler)
    if not ok then
        log(ngx.ERR, "failed to create timer: ", err)
        return
    end
	local ok, err = ngx.timer.at(0, subscrible_redis)
end
