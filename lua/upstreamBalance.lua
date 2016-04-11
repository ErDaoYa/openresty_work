local balancer =  require("ngx.balancer")
local services = ngx.shared.services
local upstream = services:get("/user/user")
ngx.log(ngx.ERR, upstream)
local ok, err = balancer.set_current_peer("127.0.0.1", 8081)
if not ok then
    ngx.log(ngx.ERR, "failed to set the current peer:", err)
    return ngx.exit(500)
end
