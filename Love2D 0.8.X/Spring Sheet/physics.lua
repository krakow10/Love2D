--By xXxMoNkEyMaNxXx
local unpack=unpack

local abs=math.abs
local max=math.max
local log=math.log
local floor=math.floor

local base=1.1
local function Decode(data)
	return vec.mulNum(vec.subNum(vec.mulNum({data[1],data[2],data[3]},2),1),base^(255*data[4]))
end
local function Encode(value)
	if vec.length(value)>1/255 then
		local lol=max(floor(log(max(abs(value[1]),abs(value[2]),abs(value[3])))/log(base))+1,0)
		local wow=vec.addNum(vec.divNum(value,2*base^lol),0.5)
		return {wow[1],wow[2],wow[3],lol/255}
	end
	return {0.5,0.5,0.5,0}
end
local c=vec.func(vec.mulNum(Encode{1,2,3},255),floor)
print(unpack(c))
print(unpack(Decode(vec.divNum(c,255))))

local physics={}

physics.View={0,0,64,64}

local setEffect=love.graphics.setPixelEffect
local GPU=love.graphics.newPixelEffect(love.filesystem.read'physics.frag')
local send=GPU.send
send(GPU,"View",physics.View)

local draw=love.graphics.draw
local rect=love.graphics.rectangle

local newCanvas=love.graphics.newCanvas
local setCanvas=love.graphics.setCanvas

local blankData=love.image.newImageData(physics.View[3],physics.View[4])
blankData:mapPixel(function(x,y)
	return unpack(vec.mulNum(Encode{0,0,0},255))
end)
local newImage=love.graphics.newImage
local blank=newImage(blankData)

local function newData(passes)
	local data={}
	for i=1,passes do
		data[i]=newCanvas(physics.View[3],physics.View[4])
		setCanvas(data[i])
		draw(blank)--I'm drawing a blank!
	end
	setCanvas()
	return data
end

physics.passes=1
local data0=newData(physics.passes)
local data1=newData(physics.passes)
local data2=newData(physics.passes)
local staticData=newData(physics.passes)

--[[
do
	local derp=data0[1]:getImageData()
	derp:mapPixel(function(x,y)
		return unpack(vec.mulNum(Encode{x,0,y},255))
	end)
	setCanvas(data0[1])
	draw(newImage(derp))
	setCanvas()
end
--]]

send(GPU,"data2",unpack(data2))
send(GPU,"data1",unpack(data1))
send(GPU,"data0",unpack(data0))

local function runDataN(data,N)
	send(GPU,"dataN",N)
	for i=1,physics.passes do
		setCanvas(staticData[i])
		draw(data[i])
	end
	send(GPU,"staticData",unpack(staticData))
	for pass=0,physics.passes-1 do
		send(GPU,"pass",pass)
		setCanvas(data[pass+1])
		draw(blank)
		setEffect(GPU)
		rect("fill",unpack(physics.View))
		setEffect()
		send(GPU,"data"..N,unpack(data,1,pass+1))
	end
end

function physics.update(t)
	send(GPU,"tick",t)

	runDataN(data2,2)
	runDataN(data1,1)
	runDataN(data0,0)

	setCanvas()
end
_G.Decode=Decode
_G.Encode=Encode
physics[0]=data0
physics[1]=data1
physics[2]=data2

_G.physics=physics
