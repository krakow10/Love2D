--By xXxMoNkEyMaNxXx
local sqrt=math.sqrt

local getX,getY=love.mouse.getX,love.mouse.getY

local fps=love.timer.getFPS

local setTitle=love.window.setTitle

local draw=love.graphics.draw
local setColor=love.graphics.setColor
local setCanvas=love.graphics.setCanvas
local newShader=love.graphics.newShader
local setShader=love.graphics.setShader

local size={love.window.getDimensions()}

image=love.graphics.newImage'hl2.png'
local h,v=newShader'bloomH.frag',newShader'bloomV.frag'
h:send("size",{1920,1080})
v:send("size",{1920,1080})
local bloomCanvas=love.graphics.newCanvas(1920,1080,"hdr")

function love.draw()
	setCanvas(bloomCanvas)
	setShader(h)
	draw(image)
	setShader(v)
	draw(bloomCanvas)
	setCanvas()
	setShader()
	setColor(255,255,255,255)
	draw(image)
	setColor(255,255,255,64)
	draw(bloomCanvas)
	setTitle("Bloom - "..fps().." FPS")
end

local zeroRadius=25
function love.update(dt)
	local mx,my=getX()-size[1]/2,getY()-size[2]/2
	local msq=mx*mx+my*my
	if msq<zeroRadius*zeroRadius then
		h:send("violence",0)
		v:send("violence",0)
	else
		local violence=(sqrt(msq)-zeroRadius)/12
		h:send("violence",violence)
		v:send("violence",violence)
	end
end

function love.resize(x,y)
	size={x,y}
end
