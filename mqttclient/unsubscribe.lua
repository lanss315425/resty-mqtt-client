local bit = require "bit"
local M = {}

function M.unsub(sock,datalen)
	   local data = sock:receive(datalen)    
     local body_MSB = string.byte(data,1)
     local body_LSB = string.byte(data,2)
     local length_MSB = string.byte(data,3)
     local length_LSB = string.byte(data,4)
     local title = string.char(string.byte(data,5,4+length_LSB))
     return title,body_MSB,body_LSB
end

function M.unsuback(sock,body_MSB,body_LSB)
	  local res = string.char(bit.tobit(0xB0),2,body_MSB,body_LSB)
    local bytes, err = sock:send(res)
    if  err then
      ngx.log(ngx.ERR,"-----------sock connectack err:"..tostring(err))
      --M.sock:exit()
    end   
end

return M