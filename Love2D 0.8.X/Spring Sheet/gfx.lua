local gfx={}
gfx.View={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}
gfx.camPos={0,0,-10}
gfx.camRot={{1,0,0},{0,1,0},{0,0,1}}
gfx.Zoom=0
gfx.Speed=15
gfx.info=false

local pow=2
local rad=1.5
local sin,cos=math.sin,math.cos
local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition
local setPos=love.mouse.setPosition
local isVisible=love.mouse.isVisible
local setVisible=love.mouse.setVisible
local isKey=love.keyboard.isDown
local centre=vec.divNum(gfx.View[2],2)

local shader=love.graphics.newPixelEffect(love.filesystem.read'gfx.frag')
shader:send("BackColour",{0,0,0,1})
shader:send("PointColour",{1,1,1,1})
shader:send("View",gfx.View)
shader:send("Zoom",gfx.Zoom)
shader:send("camPos",gfx.camPos)
shader:send("camRot",gfx.camRot)

local rect=love.graphics.rectangle
local setEffect=love.graphics.setPixelEffect
function gfx.displayData(data)
	shader:send("DATA",unpack(data))
	shader:send("Size",{64,64})
	setEffect(shader)
	rect("fill",gfx.View[1][1],gfx.View[1][2],gfx.View[2][1],gfx.View[2][2])
	setEffect()
end

local print=love.graphics.print
function gfx.draw()
	if gfx.info then
		print(vec.tostring(gfx.camPos),0,0)
		print(mat.tostring(gfx.camRot),0,20)
	end
end

function gfx.update(t)
	local m={getPos()}
	if isBtn'r' then
		if isVisible() then
			setVisible(false)
		else
			local delta=vec.mulNum(vec.sub(m,centre),rad/(gfx.View[2][2]*pow^gfx.Zoom))
			gfx.camRot=mat.mulMat(gfx.camRot,{
				{cos(delta[1]),0,-sin(delta[1])},
				{0,cos(delta[2]),sin(delta[2])},
				{sin(delta[1]),-sin(delta[2]),cos(delta[1])*cos(delta[2])}
			})
			shader:send("camRot",gfx.camRot)
		end
		setPos(centre[1],centre[2])
	elseif not isVisible() then
		setVisible(true)
	end
	if isKey'd' then
		gfx.camPos=vec.add(gfx.camPos,vec.mulNum(gfx.camRot[1],t*gfx.Speed))
	end
	if isKey'a' then
		gfx.camPos=vec.sub(gfx.camPos,vec.mulNum(gfx.camRot[1],t*gfx.Speed))
	end
	if isKey' ' then
		gfx.camPos=vec.add(gfx.camPos,vec.mulNum(gfx.camRot[2],t*gfx.Speed))
	end
	if isKey'lshift' then
		gfx.camPos=vec.sub(gfx.camPos,vec.mulNum(gfx.camRot[2],t*gfx.Speed))
	end
	if isKey'w' then
		gfx.camPos=vec.add(gfx.camPos,vec.mulNum(gfx.camRot[3],t*gfx.Speed))
	end
	if isKey's' then
		gfx.camPos=vec.sub(gfx.camPos,vec.mulNum(gfx.camRot[3],t*gfx.Speed))
	end
	shader:send("camPos",gfx.camPos)
end

function gfx.keyDown(k)
	if k=="escape" then
		love.event.quit()
	elseif k=="r" then
		gfx.camPos={0,0,-10}
		gfx.camRot={{1,0,0},{0,1,0},{0,0,1}}
		shader:send("camPos",gfx.camPos)
		shader:send("camRot",gfx.camRot)
	elseif k=="tab" then
		gfx.info=not gfx.info
	end
end

function gfx.mouseDown(b)
	if b=="wu" then
		gfx.Zoom=gfx.Zoom+0.1
		shader:send("Zoom",gfx.Zoom)
	elseif b=="wd" then
		gfx.Zoom=gfx.Zoom-0.1
		shader:send("Zoom",gfx.Zoom)
	elseif b=="m" then
		gfx.Zoom=0
		shader:send("Zoom",gfx.Zoom)
	end
end

_G.gfx=gfx
