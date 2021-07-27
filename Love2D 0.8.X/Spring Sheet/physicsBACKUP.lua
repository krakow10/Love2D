--By xXxMoNkEyMaNxXx
local unpack=unpack

local abs=math.abs
local max=math.max
local log=math.log
local floor=math.floor

local base=1.08
local function Decode(data)
	return vec.mulNum(vec.subNum(vec.mulNum({data[1],data[2],data[3]},2),1),base^(255*data[4]))
end
local function Encode(value)
	if vec.length(value)>0 then
		local lol=max(floor(log(max(abs(value[1]),abs(value[2]),abs(value[3])))/log(base))+1,0)
		local wow=vec.addNum(vec.divNum(value,2*base^lol),0.5)
		return {wow[1],wow[2],wow[3],lol/255}
	end
	return {0.5,0.5,0.5,0}
end

local physics={}

local View={0,0,64,64}

local setEffect=love.graphics.setPixelEffect
local GPU=love.graphics.newPixelEffect(love.filesystem.read'physics.frag')
local send=GPU.send
send(GPU,"View",View)

local newCanvas=love.graphics.newCanvas
local setCanvas=love.graphics.setCanvas

--local blank=newCanvas(View[3],View[4])
local data0=newCanvas(View[3],View[4])
local data1=newCanvas(View[3],View[4])
local data2=newCanvas(View[3],View[4])
data0:getImageData():mapPixel(function(x,y)
	return unpack(vec.mulNum(Encode{x,10*math.random()-5,y},255))
end)
send(GPU,"data0",data0)
send(GPU,"data1",data1)
send(GPU,"data2",data2)

local rect=love.graphics.rectangle
function physics.update(t)
	send(GPU,"tick",t)
	setEffect(GPU)

	send(GPU,"pass",1)
	setCanvas(data2)
	rect("fill",View[1],View[2],View[3],View[4])
	send(GPU,"data2",data2)

	send(GPU,"pass",2)
	setCanvas(data1)
	rect("fill",View[1],View[2],View[3],View[4])
	send(GPU,"pass",3)
	setCanvas(data0)
	rect("fill",View[1],View[2],View[3],View[4])
	send(GPU,"data1",data1)
	send(GPU,"data0",data0)

	setCanvas()
	setEffect()
end
_G.Decode=Decode
_G.Encode=Encode
physics.data0=data0
physics.data1=data1
physics.data2=data2

_G.physics=physics
