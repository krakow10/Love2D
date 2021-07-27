--By xXxMoNkEyMaNxXx
local version=1.0

local k=4
local depth=256

local isBtn=love.mouse.isDown
local isKey=love.keyboard.isDown

local draw=love.graphics.draw
local point=love.graphics.point
local colour=love.graphics.setColor
local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect

local mX,mY=love.mouse.getX,love.mouse.getY
local vs={love.graphics.getWidth(),love.graphics.getHeight()}
local w={View={{0,0},vs}}
love.graphics.setColorMode'replace'

local sim=love.graphics.newPixelEffect(love.filesystem.read'sim.glsl')
local shader=love.graphics.newPixelEffect(love.filesystem.read'shader.glsl')
local send=sim.send

local Test=love.graphics.newImage'icon.png'

local Sky=love.graphics.newImage'Sky.jpg'
local Tile=love.graphics.newImage'Tile.jpg'

send(sim,"vs",vs)
send(sim,"k",k)
send(sim,"dt",0.001)

send(shader,"vs",vs)
send(shader,"View",w.View)
send(shader,"depth",depth)
send(shader,"Sky",Sky)
send(shader,"Tile",Tile)
send(shader,"SkySize",{Sky:getWidth(),Sky:getHeight()})
send(shader,"TileSize",{Tile:getWidth(),Tile:getHeight()})

local data=love.graphics.newCanvas()
data:clear(128,0,128,2)

function love.draw()
	setEffect(shader)
	draw(data,w.View[1][1],w.View[1][2])
	setEffect()
	if isKey'tab' then
		draw(data,w.View[1][1],w.View[1][2])
	end
end
love.graphics.setPointSize(10)
function love.update(dt)
	setCanvas(data)
	if isBtn'l' then
		colour(0,0,255,255)
		point(mX()+0.5,mY()+0.5)
		colour(255,255,255,255)
	end
	if isBtn'r' then
		colour(255,255,0,255)
		point(mX()+0.5,mY()+0.5)
		colour(255,255,255,255)
	end
	setEffect(sim)
	send(sim,"dt",dt)
	draw(data)
	setEffect()
	setCanvas()
end
--]=]

