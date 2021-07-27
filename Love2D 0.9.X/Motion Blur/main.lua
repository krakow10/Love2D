--By xXxMoNkEyMaNxXx
local abs=math.abs
local max=math.max
local sqrt=math.sqrt
local floor=math.floor

local getX,getY=love.mouse.getX,love.mouse.getY

local fps=love.timer.getFPS

local draw=love.graphics.draw
local print=love.graphics.print
local setShader=love.graphics.setShader

local size={love.graphics.getDimensions()}

local Offset={0,0}

local blur=love.graphics.newShader'blur.frag'
blur:send("CanvasSize",size)
blur:send("Offset",Offset)

image=love.graphics.newImage'hl2.png'

function love.draw()
	setShader(blur)
	draw(image)
	setShader()
	print("FPS: "..fps(),0,0)
	print(string.format("Offset: %.2f, %.2f",Offset[1],Offset[2]),0,20)
	print("Iterations/Pixel: "..max(1,floor(abs(Offset[1]))+floor(abs(Offset[2]))),0,40)
end

local sensitivity=0.1
local zeroRadius=25
function love.update(dt)
	local mx,my=getX()-size[1]/2,getY()-size[2]/2
	local msq=mx*mx+my*my
	if msq<zeroRadius*zeroRadius then
		Offset={0,0}
		blur:send("Offset",Offset)
	else
		local mult=sensitivity*(1-zeroRadius/sqrt(msq))
		Offset={mult*mx,mult*my}
		blur:send("Offset",Offset)
	end
end

function love.resize(x,y)
	size={x,y}
	blur:send("CanvasSize",size)
end
