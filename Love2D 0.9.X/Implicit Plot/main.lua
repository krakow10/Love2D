--By xXxMoNkEyMaNxXx
local sqrt=math.sqrt

local isBtn=love.mouse.isDown
local getX,getY=love.mouse.getX,love.mouse.getY

local isKey=love.keyboard.isDown

local rect=love.graphics.rectangle
local setShader=love.graphics.setShader

local shader=love.graphics.newShader'plot.frag'

local h=love.graphics.getHeight()

local ScreenOffset={0,0}
local ScreenView={love.graphics.getDimensions()}

local WorldOffset={-10*ScreenView[1]/ScreenView[2],-10}
local WorldView={20*ScreenView[1]/ScreenView[2],20}

local function getWorldPos(x,y)
	return {WorldOffset[1]+WorldView[1]*(x-ScreenOffset[1])/ScreenView[1],WorldOffset[2]+WorldView[2]*(y-ScreenOffset[2])/ScreenView[2]}
end

shader:send("ScreenOffset",ScreenOffset)
shader:send("ScreenView",ScreenView)
shader:send("WorldOffset",WorldOffset)
shader:send("WorldView",WorldView)

love.graphics.setBackgroundColor(255,255,255,255)

function love.draw()
	setShader(shader)
	rect("fill",ScreenOffset[1],ScreenOffset[2],ScreenView[1],ScreenView[2])
	setShader()
end

local WorldGrab

local ZoomStep=1.1
local ZoomSpeed=1.4
local ScrollSpeed=100

local q1=1
local q2=-1
local q3=-2
local r1={2,0}
local r2={0,0}
local r3={4,0}

function love.update(dt)
	local zoom=1
	local move={0,0}
	local moveUnit={WorldView[1]*ScrollSpeed/ScreenView[1]*dt,WorldView[2]*ScrollSpeed/ScreenView[2]*dt}
	if isKey'd' then
		move[1]=move[1]+moveUnit[1]
	end
	if isKey'a' then
		move[1]=move[1]-moveUnit[1]
	end
	if isKey'w' then
		move[2]=move[2]+moveUnit[2]
	end
	if isKey's' then
		move[2]=move[2]-moveUnit[2]
	end

	if isKey'i' then
		zoom=zoom/ZoomSpeed^dt
	end
	if isKey'o' then
		zoom=zoom*ZoomSpeed^dt
	end

	local WorldPos=getWorldPos(getX(),h-getY())
	if isBtn'l' then
		local d1x,d1y=WorldPos[1]-r1[1],WorldPos[2]-r1[2]
		local d2x,d2y=WorldPos[1]-r2[1],WorldPos[2]-r2[2]
		local d3x,d3y=WorldPos[1]-r3[1],WorldPos[2]-r3[2]
		local l1,l2,l3=sqrt(d1x*d1x+d1y*d1y),sqrt(d2x*d2x+d2y*d2y),sqrt(d3x*d3x+d3y*d3y)
		local x,y=q1*d1x/l1+q2*d2x/l2+q3*d3x/l3,0--q1*d1y/l1+q2*d2y/l2+q3*d3y/l3
		shader:send("omg",sqrt(x*x+y*y))
	end
	if WorldGrab then
		WorldGrab[1]=WorldGrab[1]+move[1]
		WorldGrab[2]=WorldGrab[2]+move[2]
		WorldOffset[1]=WorldOffset[1]+WorldGrab[1]-WorldPos[1]
		WorldOffset[2]=WorldOffset[2]+WorldGrab[2]-WorldPos[2]
	elseif move[1]~=0 or move[2]~=0 then
		WorldOffset[1]=WorldOffset[1]+move[1]
		WorldOffset[2]=WorldOffset[2]+move[2]
	end
	if zoom~=1 then
		WorldOffset[1]=WorldOffset[1]+(WorldOffset[1]-WorldPos[1])*(zoom-1)
		WorldOffset[2]=WorldOffset[2]+(WorldOffset[2]-WorldPos[2])*(zoom-1)
		WorldView[1]=WorldView[1]*zoom
		WorldView[2]=WorldView[2]*zoom
	end
	shader:send("WorldOffset",WorldOffset)
	shader:send("WorldView",WorldView)
end

function love.mousepressed(x,y,b)
	local WorldPos=getWorldPos(x,h-y)
	if b=="l" then
		--
	elseif b=="r" then
		WorldGrab=WorldPos
	elseif b=="wu" then
		WorldOffset[1]=WorldOffset[1]+(WorldOffset[1]-WorldPos[1])*(1/ZoomStep-1)
		WorldOffset[2]=WorldOffset[2]+(WorldOffset[2]-WorldPos[2])*(1/ZoomStep-1)
		WorldView[1]=WorldView[1]/ZoomStep
		WorldView[2]=WorldView[2]/ZoomStep
		shader:send("WorldOffset",WorldOffset)
		shader:send("WorldView",WorldView)
	elseif b=="wd" then
		WorldOffset[1]=WorldOffset[1]+(WorldOffset[1]-WorldPos[1])*(ZoomStep-1)
		WorldOffset[2]=WorldOffset[2]+(WorldOffset[2]-WorldPos[2])*(ZoomStep-1)
		WorldView[1]=WorldView[1]*ZoomStep
		WorldView[2]=WorldView[2]*ZoomStep
		shader:send("WorldOffset",WorldOffset)
		shader:send("WorldView",WorldView)
	end
end

function love.mousereleased(x,y,b)
	if b=="r" then
		WorldGrab=nil
	end
end

function love.resize(x,y)
	h=y
	ScreenView={x,y}
	WorldView[1]=WorldView[2]*x/y
	shader:send("ScreenView",ScreenView)
	shader:send("WorldView",WorldView)
end
