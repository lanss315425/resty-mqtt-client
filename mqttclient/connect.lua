local fixhead = require "chargeagent.mqttclient.fixhead"
local M = {}
local string_char = string.char
local string_byte = string.byte
local string_len  = string.len

function M.login(sock,name,keepalivetime)
     local head = 0x10
     local length_MSB = 0x00
     local protocolname ='MQTT'
     local length_LSB = string_len(protocolname)
     local protocollevel  = 0x04
     local connecttags = 0x02
     local keepalive_MSB = 0x00
     local keepalive_LSB = keepalivetime or 0x3C
     local lientidentifier_MSB = 0x00
     local lientidentifier = name or 'bjt'
     local lientidentifier_LSB = string_len(lientidentifier)
     local datalength = 2 + length_LSB + 1 + 1 + 2+ 2 + lientidentifier_LSB
     local headlen = fixhead.setdatalength(datalength)
     local msg =  string_char(head)..headlen..string_char(length_MSB)..string_char(length_LSB)..protocolname..string_char(protocollevel)..string_char(connecttags)
     ..string_char(keepalive_MSB)..string_char(keepalive_LSB)..string_char(lientidentifier_MSB)..string_char(lientidentifier_LSB)..lientidentifier
     local bytes, err = sock:send(msg)
     if err then
        ngx.log(ngx.ERR,"-----------sock connect err:"..tostring(err))
        return nil
     end 
     local datatype,datalength = fixhead.getdata(sock)     
     if not datatype or string_byte(datatype) ~= 0x20 then
          return nil
     end 
     local data = sock:receive(datalength)
     local ret_code = string_byte(data,2,2)
     if ret_code ~= 0x00 then
         ngx.log(ngx.ERR,"-----------sock connect err:ret_code:"..tostring(ret_code))
          return nil
     end
     return 1
end

function M.disconnect(sock)
    local res = string_char(bit.tobit(0xE0),0)
    local bytes, err = sock:send(res)
    if  err then
      ngx.log(ngx.ERR,"-----------sock disconnect err:"..tostring(err))
      --M.sock:exit()
    end   
end


return M