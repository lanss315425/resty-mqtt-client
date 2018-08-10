local bit = require "bit"
local M = {}
local string_char = string.char

function M.sendping(sock)
	local res = string_char(bit.tobit(0xC0),0)
    local bytes, err = sock:send(res)
    if  err then
      	ngx.log(ngx.ERR,"-----------sock sendping err:"..tostring(err))
        return nil
    end   
    return 1
end

function M.pingresp(sock)
	local res = string_char(bit.tobit(0xd0),0)
    local bytes, err = sock:send(res)
    if  err then
      ngx.log(ngx.ERR,"-----------sock connectack err:"..tostring(err))
      --M.sock:exit()
    end   
end

return M