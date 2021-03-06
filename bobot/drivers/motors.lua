local device = _G
local RD_VERSION=string.char(0x00)
local SET_VEL_2MTR= 0x01 -- dos motores
local SET_VEL_MTR = 0x02 -- un motor con vel y sentido
local TEST_MOTORS = 0x03

api={}
api.getVersion = {}
api.getVersion.parameters = {} -- no input parameters
api.getVersion.returns = {[1]={rname="version", rtype="int"}}
api.getVersion.call = function ()
	device:send(RD_VERSION) -- operation code 0 = get version
    local version_response = device:read(3) -- 3 bytes to read (opcode, data)
    if not version_response or #version_response~=3 then return -1 end
    local raw_val = (string.byte(version_response,2) or 0) + (string.byte(version_response,3) or 0)* 256
    return raw_val
end

api.setvelmtr = {}
api.setvelmtr.parameters = {[1]={rname="id", rtype="int"},[2]={rname="sentido", rtype="int"},[3]={rname="vel", rtype="int"}} --parametros, id sentido vel
api.setvelmtr.returns = {[1]={rname="dato", rtype="int"}} --codigo de operación
api.setvelmtr.call = function (id, sentido, vel)
	vel=tonumber(vel)
	if vel>1023 then vel=1023 end
	local msg = string.char(SET_VEL_MTR,id, sentido, math.floor(vel / 256),vel % 256)
	device:send(msg)
	local ret = device:read(1)
	local raw_val = string.byte(ret or " ", 1) 
	return raw_val	 
end

api.setvel2mtr = {}
api.setvel2mtr.parameters = {[1]={rname="sentido", rtype="int"},[2]={rname="vel", rtype="int"},[3]={rname="sentido", rtype="int"},[4]={rname="vel", rtype="int"}} 
api.setvel2mtr.returns = {[1]={rname="dato", rtype="int"}} --codigo de operación
api.setvel2mtr.call = function (sentido1, vel1, sentido2, vel2)
	vel1, vel2 = tonumber(vel1), tonumber(vel2)
	if vel1>1023 then vel1=1023 end
	if vel2>1023 then vel2=1023 end
	local msg = string.char(SET_VEL_2MTR,sentido1, math.floor(vel1 / 256),vel1 % 256, sentido2, math.floor(vel2 / 256),vel2 % 256)
	device:send(msg)
	local ret = device:read(1)
	local raw_val = string.byte(ret or " ", 1) 	
	return raw_val	 
end

api.setvelatr2 = {} -- no impl en firmware
api.setvelatr2.parameters = {[1]={rname="id", rtype="int"}, [2]={rname="vel", rtype="int"}} --primer parametro id motor, segundo velocidad
api.setvelatr2.returns = {[1]={rname="dato", rtype="int"}} --codigo de operación
api.setvelatr2.call = function (vel)
	local vdiv, vmod = math.floor(vel / 256),vel % 256
	local msg = string.char(SET_VEL_ATR, 0, vdiv, vmod)
	device:send(msg)
	msg = string.char(SET_VEL_ATR, 1, vdiv, vmod)
	device:send(msg)
	local ret = device:read(1)
	ret = device:read(1)
	local raw_val = string.byte(ret or " ", 1) 	
	return raw_val	 
end

api.testMotors = {}
api.testMotors.parameters = {} -- no input parameters
api.testMotors.returns = {[1]={rname="dato", rtype="int"}}
api.testMotors.call = function ()
	device:send(TEST_MOTORS) -- operation code 2 = test motors
    local ret = device:read(1) -- 1 byte to read (opcode)
    if not ret or #ret~=1 then return -1 end
    local ret = string.byte(ret, 1)
    return ret
end
