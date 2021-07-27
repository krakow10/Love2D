--By xXxMoNkEyMaNxXx
local max,min=math.max,math.min
local sqrt=math.sqrt
local cos,sin=math.cos,math.sin
local atan2=math.atan2

local cap=love.window.setTitle
local rect=love.graphics.rectangle
local show=love.graphics.print
local setEffect=love.graphics.setShader

local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition

local isKey=love.keyboard.isDown
local fps=love.timer.getFPS


--THIS IS FUCKING IMPORTANT THAT THIS IS NOT LOCAL
image=love.graphics.newImage'nature.jpg'
local render=love.graphics.newShader(love.filesystem.read'render.glsl')
local linear=love.graphics.newShader(love.filesystem.read'linear.glsl')
local nearest=love.graphics.newShader(love.filesystem.read'nearest.glsl')

local scale=1
local theta=-1

local size={image:getWidth(),image:getHeight()}
local view={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}
local offset={0,0}

local on=1
local shader
local function prepare(frag)
	shader=frag
	shader:send("img",image)
	shader:send("sizei",size)
	shader:send("sizef",view[2])
	shader:send("offset",offset)
	shader:send("mat",{{scale*cos(theta),scale*sin(theta)},{-scale*sin(theta),scale*cos(theta)}})
end
prepare(render)

function love.draw()
	setEffect(shader)
	rect("fill",view[1][1],view[1][2],view[2][1],view[2][2])
	setEffect()
	cap("Perfect Image Transform - "..fps().." FPS")
	if on==1 then
		show("Perfect",0,0)
	elseif on==2 then
		show("Linear interpolation",0,0)
	elseif on==3 then
		show("Nearest neighbor",0,0)
	end
end

local zoomStep=1.1

local zoomSpeed=1.1
local spinSpeed=0.1
local scrollSpeed=10

local mPos={getPos()}
function love.update(t)
	local newPos={getPos()}
	local deltaPos={newPos[1]-mPos[1],newPos[2]-mPos[2]}

	if deltaPos[1]~=0 or deltaPos[2]~=0 then
		if isBtn'l' then
			offset={offset[1]+deltaPos[1],offset[2]+deltaPos[2]}
			shader:send("offset",offset)
		elseif isBtn'r' then
			local d1,d2={mPos[1]-(view[1][1]+view[2][1]/2+offset[1]),mPos[2]-(view[1][2]+view[2][2]/2+offset[2])},{newPos[1]-(view[1][1]+view[2][1]/2+offset[1]),newPos[2]-(view[1][2]+view[2][2]/2+offset[2])}
			theta=theta+atan2(d2[2],d2[1])-atan2(d1[2],d1[1])
			if scale==0 then
				scale=sqrt(d2[1]*d2[1]+d2[2]*d2[2])
			else
				scale=scale*sqrt((d2[1]*d2[1]+d2[2]*d2[2])/(d1[1]*d1[1]+d1[2]*d1[2]))
			end
		end
	end
	mPos=newPos

	local scroll={0,0}
	if isKey'a' then
		scroll[1]=scroll[1]-1
	end
	if isKey'd' then
		scroll[1]=scroll[1]+1
	end
	if isKey's' then
		scroll[2]=scroll[2]+1
	end
	if isKey'w' then
		scroll[2]=scroll[2]-1
	end
	offset={offset[1]+scroll[1]*scrollSpeed*t,offset[2]+scroll[2]*scrollSpeed*t}

	local spin=0
	if isKey'left' then
		spin=spin-1
	end
	if isKey'right' then
		spin=spin+1
	end
	local dtheta=spin*spinSpeed*t
	theta=theta+dtheta
	local d={mPos[1]-(view[1][1]+view[2][1]/2+offset[1]),mPos[2]-(view[1][2]+view[2][2]/2+offset[2])}
	offset={offset[1]-(d[1]*cos(dtheta)-d[2]*sin(dtheta)-d[1]),offset[2]-(d[1]*sin(dtheta)+d[2]*cos(dtheta)-d[2])}

	local zoom=0
	if isKey'up' then
		zoom=zoom+1
	end
	if isKey'down' then
		zoom=zoom-1
	end
	local dzoom=zoomSpeed^(zoom*t)
	scale=scale*dzoom
	offset={offset[1]-(mPos[1]-(view[1][1]+view[2][1]/2+offset[1]))*(dzoom-1),offset[2]-(mPos[2]-(view[1][2]+view[2][2]/2+offset[2]))*(dzoom-1)}

	shader:send("offset",offset)
	shader:send("mat",{{scale*cos(theta),scale*sin(theta)},{-scale*sin(theta),scale*cos(theta)}})
end

function love.mousepressed(_,_,b)
	if b=="wu" then
		scale=scale*zoomStep
		offset={offset[1]-(mPos[1]-(view[1][1]+view[2][1]/2+offset[1]))*(zoomStep-1),offset[2]-(mPos[2]-(view[1][2]+view[2][2]/2+offset[2]))*(zoomStep-1)}
	elseif b=="wd" then
		scale=scale/zoomStep
		offset={offset[1]-(mPos[1]-(view[1][1]+view[2][1]/2+offset[1]))*(1/zoomStep-1),offset[2]-(mPos[2]-(view[1][2]+view[2][2]/2+offset[2]))*(1/zoomStep-1)}
	end
end

function love.keypressed(k)
	if k==" " then
		on=on%3+1
		if on==1 then
			prepare(render)
		elseif on==2 then
			prepare(linear)
		elseif on==3 then
			prepare(nearest)
		end
	elseif k=="1" then
		on=1
		prepare(render)
	elseif k=="2" then
		on=2
		prepare(linear)
	elseif k=="3" then
		on=3
		prepare(nearest)
	end
end

function love.resize(w,h)
	view[2]={w,h}
	if on==1 then
		prepare(render)
	elseif on==2 then
		prepare(linear)
	elseif on==3 then
		prepare(nearest)
	end
end
