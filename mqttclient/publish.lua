local bit = require "bit"
local M = {}

function M.pubqos0(sock,datalen)
    local data = sock:receive(datalen)    
    local length_MSB = string.byte(data,1)
    local length_LSB = string.byte(data,2)
    local title = string.char(string.byte(data,3,2+length_LSB))
    local body = string.char(string.byte(data,3+length_LSB,datalen))
    return title,body  
end

function M.pub(sock,datalen)
	local data = sock:receive(datalen)    
    local length_MSB = string.byte(data,1)
    local length_LSB = string.byte(data,2)
    local title = string.char(string.byte(data,3,2+length_LSB))
    local body_MSB = string.byte(data,3+length_LSB)
    local body_LSB = string.byte(data,4+length_LSB)
    local body = string.char(string.byte(data,5+length_LSB,datalen))
    return title,body_MSB,body_LSB,body  
end

function M.getpuback(sock,datalen)
    local data = sock:receive(datalen)    
    local body_MSB = string.byte(data,1)
    local body_LSB = string.byte(data,2)
    return body_MSB,body_LSB
end

function M.pubrec(sock,body_MSB,body_LSB)
    local res = string.char(bit.tobit(0x50),2,body_MSB,body_LSB)
    local bytes, err = sock:send(res)
    if  err then
      ngx.log(ngx.ERR,"-----------sock puback err:"..tostring(err))
    end   
end

function M.pubcomp(sock,body_MSB,body_LSB)
    local res = string.char(bit.tobit(0x70),2,body_MSB,body_LSB)
    local bytes, err = sock:send(res)
    if  err then
      ngx.log(ngx.ERR,"-----------sock puback err:"..tostring(err))
    end   
end


function M.puback(sock,body_MSB,body_LSB)
	local res = string.char(bit.tobit(0x40),2,body_MSB,body_LSB)
    local bytes, err = sock:send(res)
    if  err then
      ngx.log(ngx.ERR,"-----------sock puback err:"..tostring(err))
    end   
end

return M