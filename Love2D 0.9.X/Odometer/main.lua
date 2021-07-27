--By Quaternions
local exp=math.exp
local sin=math.sin

local clear=love.graphics.clear
local draw=love.graphics.draw
local gprint=love.graphics.print
local rect=love.graphics.rectangle
local setCanvas=love.graphics.setCanvas
local setShader=love.graphics.setShader

local isDown=love.mouse.isDown

local tick=love.timer.getTime


love.graphics.setColor(0,0,0,255)
love.graphics.setBackgroundColor(255,255,255,255)

local w,h=love.graphics.getDimensions()

local base=10

NumberImage=love.graphics.newImage'0123456789.png'
local NumberWidth=NumberImage:getWidth()
local NumberHeight=NumberImage:getHeight()

--Generate full resolution sum image
local TopDownSum=love.graphics.newCanvas(NumberWidth,NumberHeight,"rgba32f")
local TopDownShader=love.graphics.newShader'TopDown.glsl'
setShader(TopDownShader)
setCanvas(TopDownSum)
draw(NumberImage)

--the main meat
local MotionShader=love.graphics.newShader'Motion.glsl'
MotionShader:send("Font",NumberImage)
MotionShader:send("Sum",TopDownSum)
MotionShader:send("DSize",{base*h*NumberWidth/NumberHeight,h})
MotionShader:send("FontSize",{NumberWidth,NumberHeight/base})

setCanvas()

local t0=tick()+16*5
local thisNumber=0
local lastNumber=0
MotionShader:send("n0",lastNumber)

local pause=false

--local frame=0
--local divider=60
--let's run this
function love.draw()
	if not pause then
	--[[
		if frame<divider then
			frame=frame+1
		else
			--]]
		lastNumber=thisNumber
		thisNumber=1000000/(1+exp(-0.2*(tick()-t0)))--10.5+1.5*sin(tick())--
		MotionShader:send("n0",lastNumber)
		MotionShader:send("n1",thisNumber)
			--[[
			frame=1
		end
		--]]
	end
	--[[
	lastNumber=9.5+0.5*sin(tick())
	thisNumber=10.5+0.5*sin(tick()/3^0.5)
	MotionShader:send("n0",lastNumber)
	MotionShader:send("n1",thisNumber)
	--]]
	clear()
	setShader(MotionShader)
	rect("fill",0,0,w,h)
	setShader()
	gprint("n0: "..lastNumber,0,0)
	gprint("n1: "..thisNumber,0,20)
end

local b1d=isDown'l'
function love.update()
	local new_b1d=isDown'l'
	if new_b1d and not b1d then
		pause=not pause
	end
	b1d=new_b1d
end

function love.resize(x,y)
	w,h=x,y
	--Recache TopDown pixels for new number width?
	MotionShader:send("DSize",{base*h*NumberWidth/NumberHeight,h})
end
--]==]
