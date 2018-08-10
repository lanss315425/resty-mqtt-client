local bit = require "bit"
local M = {}
local string_byte = string.byte
local bit_band  = bit.band
local string_char = string.char


function M.setdatalength(datalength)
  local X = datalength
  local databyte = ''
  while X > 0 do
    local encodedByte = math.fmod(X,128)
    X = math.modf(X / 128)
    if  X > 0  then
        encodedByte = bit.bxor(encodedByte ,128)
      end
      databyte = databyte..string_char(encodedByte)
  end
  return databyte
end

local function getdatalength(sock)
	 local length = 0
	 local multiplier = 1
	 local loop = true
	 while loop do
		 local data ,err = sock:receive(1)
		 if err then
		      ngx.log(ngx.ERR,"-----------receive mqtt length err:"..tostring(err))   
		      length = 0
		      break
	 	 end       
	 	 local encodedByte = string_byte(data)
	 	 local result = bit_band(encodedByte,128)
	 	 if result == 0 then
	 	 	loop = false
	 	 end	
	 	 length = length + (bit_band(encodedByte,127)) * multiplier
    	 multiplier = multiplier*128	
 	end
 	return length
end


--[[Reserved	0	禁止	保留
CONNECT	1	客户端到服务端	客户端请求连接服务端
CONNACK	2	服务端到客户端	连接报文确认
PUBLISH	3	两个方向都允许	发布消息
PUBACK	4	两个方向都允许	QoS 1消息发布收到确认
PUBREC	5	两个方向都允许	发布收到（保证交付第一步）
PUBREL	6	两个方向都允许	发布释放（保证交付第二步）
PUBCOMP	7	两个方向都允许	QoS 2消息发布完成（保证交互第三步）
SUBSCRIBE	8	客户端到服务端	客户端订阅请求
SUBACK	9	服务端到客户端	订阅请求报文确认
UNSUBSCRIBE	10	客户端到服务端	客户端取消订阅请求
UNSUBACK	11	服务端到客户端	取消订阅报文确认
PINGREQ	12	客户端到服务端	心跳请求
PINGRESP	13	服务端到客户端	心跳响应
DISCONNECT	14	客户端到服务端	客户端断开连接
Reserved	15	禁止	保留--]]
function M.getdata(sock)
		local data ,err = sock:receive(1)
		if err then
		  ngx.log(ngx.ERR,"-----------receive mqtt fix 1 err:"..tostring(err))   
		  return nil
		end       
		--ngx.log(ngx.ERR,"getdatatype:"..tostring(bit.tohex(string.byte(data,1,1))))
		local datalength = getdatalength(sock)		 
		return data,datalength
end


return M