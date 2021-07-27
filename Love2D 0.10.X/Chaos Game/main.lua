--By Quaternions
local unpack=unpack
local lgprint=love.graphics.print
local draw=love.graphics.draw
local setShader=love.graphics.setShader
local setCanvas=love.graphics.setCanvas

randomdata=love.graphics.newImage'6642048402356.png'
--global on purpose
pointdata=love.graphics.newCanvas(1024,1024,"rgba16f")

local chaospoly=love.graphics.newShader'chaospoly.frag'
local xorshift=love.graphics.newShader'xorshift.frag'

--generate points and send to shader
local n=5
local points={}
for i=1,n do
	points[i]={math.cos(math.pi*(2*i+1)/n),math.sin(math.pi*(2*i+1)/n)}
end

chaospoly:send("Npoints",n)
chaospoly:send("points",unpack(points,1,#points+1))
chaospoly:send("randomdata",randomdata)

local i=0

function love.draw()
	i=i+1
	setCanvas()
	lgprint(0,0,i.."/1024")
	setShader(xorshift)
	setCanvas(randomdata)
	draw(randomdata)
	chaospoly:send("randomdata",randomdata)
	setShader(chaospoly)
	setCanvas(pointdata)
	draw(pointdata)
end
