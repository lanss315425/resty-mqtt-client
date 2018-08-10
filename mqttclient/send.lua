local M = {}

local string_len = string.len
local string_char = string.char
local string_byte = string.byte

local function gethead(qos,dup,retain)
	if qos == 0 and dup == 0 and retain == 0 then
		return 0x30
	elseif qos == 0 and dup == 0 and retain ==1 then
		return 0x31
	elseif qos ==1 and dup == 0 and	retain == 0 then
		return 0x32	
	elseif qos ==1 and dup == 0 and	retain == 1 then
		return 0x33			
	elseif qos ==2 and dup == 0 and	retain == 0 then
		return 0x34	
	elseif qos ==2 and dup == 0 and	retain == 1 then
		return 0x35					
	end	
end

local function getdatalength(datalength)
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


function M.getdata(title,qos,index,data)
	local head = gethead(qos,0,0)
	local length_MSB = 0
	local length_LSB = string_len(title)
	local datalength = 2 + length_LSB +2 + string_len(data)
	local headlen = getdatalength(datalength)
	local hex = bit.tohex(index)
	local body_MSB = tonumber(string.sub(hex,5,6),16)
	local body_LSB = tonumber(string.sub(hex,7,8),16)
	local msg =  string_char(head)..headlen..string_char(length_MSB)..string_char(length_LSB)..title..string_char(body_MSB)..string_char(body_LSB)..data
	return body_MSB,body_LSB,msg
end

return M
