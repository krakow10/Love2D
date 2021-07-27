--By xXxMoNkEyMaNxXx
local line=love.graphics.line
local draw=love.graphics.draw
local rect=love.graphics.rectangle
local point=love.graphics.point
local colour=love.graphics.setColor
local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect

local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition

local enabled=false

local Wall={1,1,1,1}
local Empty={0,0,0,1}
local Sand={211/255,159/255,111/255,1}

local delta=0.001
local gravity={0,-1}

local size={love.graphics.getWidth(),love.graphics.getHeight()}

local tick=love.graphics.newPixelEffect(love.filesystem.read'sand.frag')
local show=love.graphics.newPixelEffect(love.filesystem.read'draw.frag')

tick:send("delta",delta)
tick:send("gravity",gravity)

show:send("Sand",Sand)
tick:send("Wall",Wall)
tick:send("Empty",Empty)

Map=love.graphics.newImage'Map.png'
tick:send("Map",Map)
show:send("Map",Map)
data1=love.graphics.newCanvas(size[1],size[2])
data2=love.graphics.newCanvas(size[1],size[2])

data1:clear(0,128,128,255)
data2:clear(0,128,128,255)

tick:send("data",data1)

tick:send("size",size)
show:send("size",size)

function love.draw()
	colour(255,255,255,255)
	setCanvas()
	if enabled then
		setEffect(show)
	else
		setEffect()
	end
	draw(data1)
end

local mPos={getPos()}
function love.update(t)
	if enabled then
		colour(255,255,255,255)
		--run:send("data",data1)
		setEffect(tick)
		setCanvas(data2)
		rect("fill",0,0,size[1],size[2])
		setEffect()
		setCanvas(data1)
		draw(data2)
	else
		setEffect()
		setCanvas(data1)
	end
	colour(255,255,255,255)
	local newPos={getPos()}
	local dPos={newPos[1]-mPos[1],newPos[2]-mPos[2]}
	if isBtn'l' then
		if dPos[1]~=0 or dPos[2]~=0 then
			line(mPos[1],mPos[2],newPos[1],newPos[2])
		else
			point(newPos[1],newPos[2])
		end
	end
	mPos=newPos
end

function love.keypressed(k)
	if k==" " then
		enabled=not enabled
	end
end

--print(run:getWarnings())
--print(show:getWarnings())
