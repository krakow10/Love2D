--By xXxMoNkEyMaNxXx

local fps=love.timer.getFPS

local getPos=love.mouse.getPosition

local setTitle=love.window.setTitle

local rect=love.graphics.rectangle

local shader=love.graphics.newShader'gaussian.frag'

local k=100

local View={love.window.getDimensions()}--Returns the size of the window x,y
local Offset={0,0}

shader:send("k",k)
shader:send("h",love.window.getHeight())--The coordinate system is flipped
--shader:send("View",View)
--shader:send("Offset",Offset)

love.graphics.setShader(shader)

function love.draw()
	rect("fill",Offset[1],Offset[2],View[1],View[2])
	setTitle("Noob - "..fps().." FPS")
end

local perSecond=0.1
local kMul=1.1

local mPos={getPos()}
local smoothedPos=mPos
function love.update(dt)
	newPos={getPos()}
	smoothedPos={newPos[1]+(smoothedPos[1]-newPos[1])*perSecond^dt,newPos[2]+(smoothedPos[2]-newPos[2])*perSecond^dt}
	shader:send("mPos",smoothedPos)
	mPos=newPos
end

function love.mousepressed(x,y,b)
	if b=="wu" then--WheelUp
		k=k*kMul
		shader:send("k",k)
	elseif b=="wd" then
		k=k/kMul
		shader:send("k",k)
	end
end

function love.resize(x,y)
	View={x,y}
	shader:send("h",y)
end
