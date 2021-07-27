--By xXxMoNkEyMaNxXx
local version=1.0

local k=0.01
local depth=512

local vec=require'vec'
local ui=loader.open'ui.lua'

local draw=love.graphics.draw

local colour=love.graphics.setColor
local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect

local vs={love.graphics.getWidth(),love.graphics.getHeight()}
love.graphics.setColorMode'replace'

local w=ui.connect(ctrl.newWindow())
w.Control._BringToFront={"MDl","MDr"}
local wrapper=ui.wrapper(w)
wrapper.TitleBar.Text="Splash V"..string.format("%.1f",version)

local sim=love.graphics.newPixelEffect(love.filesystem.read'Splash/sim.glsl')
local shader=love.graphics.newPixelEffect(love.filesystem.read'Splash/shader.glsl')
local send=sim.send

local Test=love.graphics.newImage'Splash/icon.png'

local Sky=love.graphics.newImage'Splash/Sky.jpg'
local Tile=love.graphics.newImage'Splash/Tile.jpg'

send(sim,"vs",vs)
send(sim,"k",k)
send(sim,"dt",0.001)

send(shader,"vs",vs)
send(shader,"View",w.View)
send(shader,"depth",depth)
send(shader,"Sky",Sky)
send(shader,"Tile",Tile)

--[=[
local data={love.graphics.newCanvas(),love.graphics.newCanvas()}
---[[
data[1]:clear(128,0,128,0)
--]]
--[[
data[1]:renderTo(function()
	draw(Tile)
end)
--]]

function w:draw()
	draw(data[1],self.View[1][1],self.View[1][2],0,0.2,0.2)
	setEffect(shader)
	send(shader,"View",self.View)
	draw(data[1],self.View[1][1],self.View[1][2])
	setEffect()
end

function w:update(dt)
	setEffect(sim)
	setCanvas(data[2])
	send(sim,"dt",dt)
	draw(data[1])
	setEffect()
	setCanvas()
	data[1],data[2]=data[2],data[1]
end
--]=]
--[=[
local data=love.graphics.newCanvas()
data:clear(128,0,128,0)

function w:draw()
	colour(255,255,255,255)
	send(shader,"View",w.View)
	setEffect(shader)
	draw(Test,w.View[1][1],w.View[1][2],0,vs[1]/400,vs[2]/400)
	--draw(data,self.View[1][1],self.View[1][2])
	setEffect()
	--draw(data,self.View[1][1],self.View[1][2],0,0.2,0.2)
end

--[[
function w:update(dt)
	send(sim,"dt",dt)
	setEffect(sim)
	setCanvas(data)
	draw(data)
	setEffect()
	setCanvas()
end
--]]
--]=]

local wtf=love.graphics.newCanvas()
wtf:renderTo(function()
	setEffect(shader)
	draw(Test,0,0,0,wtf:getWidth()/400,wtf:getHeight()/400)
	setEffect()
end)
local file=love.filesystem.newFile'wtf.png'
file:open'w'
wtf:getImageData():encode(file)
file:close()
