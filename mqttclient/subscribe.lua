local fixhead = require "chargeagent.mqttclient.fixhead"
local M ={}

local string_char = string.char
local string_byte = string.byte
local string_len  = string.len

function M.sub(sock,title)
     local head = 0x82
     local body_MSB = 0x00
     local body_LSB = 0x01
     local length_MSB = 0x00
     local length_LSB = string_len(title)
     local qos = 0x01
     local datalength = 2  + 2 + length_LSB + 1 
     local headlen = fixhead.setdatalength(datalength)
    local msg =  string_char(head)..headlen..string_char(body_MSB)..string_char(body_LSB)..string_char(length_MSB)..string_char(length_LSB)..title..string_char(qos)
     local bytes, err = sock:send(msg)
     if err then
        ngx.log(ngx.ERR,"-----------mqtt sub err:"..tostring(err))
        return nil
     end 
     local datatype,datalength = fixhead.getdata(sock)     
     if not datatype or string_byte(datatype) ~= 0x90 then
          ngx.log(ngx.ERR,"-----------mqtt suback err:"..tostring(string_byte(datatype)))
          return nil
     end 
     local data = sock:receive(datalength)
     local ret_body_MSB  = string_byte(data,1)
     local ret_body_LSB  = string_byte(data,2)
     local ret_qos =  string_byte(data,3)
     if ret_body_MSB~=body_MSB or ret_body_LSB~=body_LSB or ret_qos~= qos then
         ngx.log(ngx.ERR,"-----------mqtt sub err:"..tostring(ret_body_MSB)..','..tostring(ret_body_LSB)..','..tostring(ret_qos))
        return nil
     end   
     return 1
end




return M