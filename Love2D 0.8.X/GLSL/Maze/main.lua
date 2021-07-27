local s=love.graphics.newPixelEffect(love.filesystem.read'maze.frag')
s:send("C0",{0,0,0,1})
s:send("C1",{1,1,1,1})
local setEffect=love.graphics.setPixelEffect
local c=love.graphics.newCanvas()
s:send("size",{c:getWidth(),c:getHeight()})
local radius,ratio=12.6,16
s:send("radius",radius)
s:send("ratio",ratio)
local draw=love.graphics.draw
local setCanvas=love.graphics.setCanvas
math.randomseed(os.time()+os.clock())
math.random()
local r=math.random
function love.draw()
	s:send("RAND",{r(),r(),r(),r()})
	setEffect(s)
	setCanvas(c)
	draw(c)
	setEffect()
	setCanvas()
	draw(c)
end
local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition
function love.update()
	s:send("md",isBtn'l' and 1 or 0)
	s:send("mp",{getPos()})
end
function love.mousepressed(_,_,b)
	if b=="wu" then
		radius=radius+0.2
		s:send("radius",radius)
	elseif b=="wd" then
		radius=radius-0.2
		s:send("radius",radius)
	end
end
function love.keypressed(k)
	if k=="up" then
		ratio=ratio+1
		s:send("ratio",ratio)
	elseif k=="down" then
		ratio=ratio-1
		s:send("ratio",ratio)
	elseif k=="delete" then
		c:clear()
	end
end
