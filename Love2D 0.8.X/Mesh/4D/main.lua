--By xXxMoNkEyMaNxXx
require'lib/vec'
require'lib/mat'
require'lib/mesh4d'

--local test=mesh4d.read'meshes/steve/steve.mesh'
local test=mesh4d.read'meshes/Format/Format.mesh'

local meshPos={-0.5,0,0,0}
local meshRot={
	{1,0,0,0},
	{0,1,0,0},
	{0,0,1,0},
	{0,0,0,1}
}

local camPos={0,0,-2,0}
local camRot={
	{1,0,0,0},
	{0,1,0,0},
	{0,0,1,0},
	{0,0,0,1}
}

local N=0
local showtext=false
local vs={love.graphics.getWidth(),love.graphics.getHeight()}


function love.draw()
	mesh4d.setWindow({0,0},{vs[1]/2,vs[2]})
	mesh4d.updateCamera(vec.add(camPos,mat.mulVec(camRot,{-0.01,0,0,0})),camRot)
	mesh4d.render(test,N,meshPos,meshRot)

	mesh4d.setWindow({vs[1]/2,0},{vs[1]/2,vs[2]})
	mesh4d.updateCamera(vec.add(camPos,mat.mulVec(camRot,{0.01,0,0,0})),camRot)
	mesh4d.render(test,N,meshPos,meshRot)

	if showtext then
		love.graphics.print("FPS - "..love.timer.getFPS(),0,0)
		love.graphics.print(vec.tostring(camPos),0,20)
		love.graphics.print(mat.tostring(camRot),0,40)

		love.graphics.print("FPS - "..love.timer.getFPS(),vs[1]/2,0)
		love.graphics.print(vec.tostring(camPos),vs[1]/2,20)
		love.graphics.print(mat.tostring(camRot),vs[1]/2,40)
	end
end

local pow=2
local zoom=0

local rad=1.8--How many radians to rotate the camera per screen height or mouse movement.
local rot=1--Key based radians per second
local sin,cos=math.sin,math.cos
local time=love.timer.getTime
local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition
local setPos=love.mouse.setPosition
local isVisible=love.mouse.isVisible
local setVisible=love.mouse.setVisible
local isKey=love.keyboard.isDown
local centre=vec.divNum(vs,2)
function love.update(t)
	local mousePos={getPos()}
	if isBtn'r' then
		if isVisible() then
			setVisible(false)
		else
			local delta=vec.mulNum(vec.sub(mousePos,centre),rad/(vs[2]*pow^zoom))
			camRot=mat.mulMat(camRot,{
				{cos(delta[1]),0,-sin(delta[1]),0},
				{0,cos(delta[2]),sin(delta[2]),0},
				{sin(delta[1]),-sin(delta[2]),cos(delta[1])*cos(delta[2]),0},
				{0,0,0,1}
			})
		end
		setPos(centre[1],centre[2])
	elseif not isVisible() then
		setVisible(true)
	end
	local delta=t*rad/pow^zoom
	if isKey'y' then-- XW+
		camRot=mat.mulMat(camRot,{
			{cos(delta),0,0,sin(delta)},
			{0,1,0,0},
			{0,0,1,0},
			{-sin(delta),0,0,cos(delta)}
		})
	end
	if isKey'h' then-- XW-
		camRot=mat.mulMat(camRot,{
			{cos(delta),0,0,-sin(delta)},
			{0,1,0,0},
			{0,0,1,0},
			{sin(delta),0,0,cos(delta)}
		})
	end
	if isKey'u' then-- YW+
		camRot=mat.mulMat(camRot,{
			{1,0,0,0},
			{0,cos(delta),0,-sin(delta)},
			{0,0,1,0},
			{0,sin(delta),0,cos(delta)}
		})
	end
	if isKey'j' then-- YW-
		camRot=mat.mulMat(camRot,{
			{1,0,0,0},
			{0,cos(delta),0,sin(delta)},
			{0,0,1,0},
			{0,-sin(delta),0,cos(delta)}
		})
	end
	if isKey'i' then-- ZW+
		camRot=mat.mulMat(camRot,{
			{1,0,0,0},
			{0,1,0,0},
			{0,0,cos(delta),sin(delta)},
			{0,0,-sin(delta),cos(delta)}
		})
	end
	if isKey'k' then-- ZW-
		camRot=mat.mulMat(camRot,{
			{1,0,0,0},
			{0,1,0,0},
			{0,0,cos(delta),-sin(delta)},
			{0,0,sin(delta),cos(delta)}
		})
	end

	if isKey'kp4' then--Mesh XW+
		meshRot=mat.mulMat(meshRot,{
			{cos(delta),0,0,sin(delta)},
			{0,1,0,0},
			{0,0,1,0},
			{-sin(delta),0,0,cos(delta)}
		})
	end
	if isKey'kp1' then--Mesh XW-
		meshRot=mat.mulMat(meshRot,{
			{cos(delta),0,0,-sin(delta)},
			{0,1,0,0},
			{0,0,1,0},
			{sin(delta),0,0,cos(delta)}
		})
	end
	if isKey'kp5' then--Mesh YW+
		meshRot=mat.mulMat(meshRot,{
			{1,0,0,0},
			{0,cos(delta),0,-sin(delta)},
			{0,0,1,0},
			{0,sin(delta),0,cos(delta)}
		})
	end
	if isKey'kp2' then--Mesh YW-
		meshRot=mat.mulMat(meshRot,{
			{1,0,0,0},
			{0,cos(delta),0,sin(delta)},
			{0,0,1,0},
			{0,-sin(delta),0,cos(delta)}
		})
	end
	if isKey'kp6' then--Mesh ZW+
		meshRot=mat.mulMat(meshRot,{
			{1,0,0,0},
			{0,1,0,0},
			{0,0,cos(delta),sin(delta)},
			{0,0,-sin(delta),cos(delta)}
		})
	end
	if isKey'kp3' then--Mesh ZW-
		meshRot=mat.mulMat(meshRot,{
			{1,0,0,0},
			{0,1,0,0},
			{0,0,cos(delta),-sin(delta)},
			{0,0,sin(delta),cos(delta)}
		})
	end

	if isKey'd' then
		camPos=vec.add(camPos,vec.mulNum(camRot[1],t))
	end
	if isKey'a' then
		camPos=vec.sub(camPos,vec.mulNum(camRot[1],t))
	end
	if isKey' ' then
		camPos=vec.add(camPos,vec.mulNum(camRot[2],t))
	end
	if isKey'lshift' then
		camPos=vec.sub(camPos,vec.mulNum(camRot[2],t))
	end
	if isKey'w' then
		camPos=vec.add(camPos,vec.mulNum(camRot[3],t))
	end
	if isKey's' then
		camPos=vec.sub(camPos,vec.mulNum(camRot[3],t))
	end
	if isKey'e' then
		camPos=vec.add(camPos,vec.mulNum(camRot[4],t))
	end
	if isKey'q' then
		camPos=vec.sub(camPos,vec.mulNum(camRot[4],t))
	end
end

function love.keypressed(k)
	if k=="escape" then
		love.event.quit()
	elseif k=="r" then
		camPos={0,0,-2,0}
		camRot={{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}}
	elseif k=="tab" then
		showtext=not showtext
	end
end

function love.mousepressed(_,_,b)
	if b=="wu" then
		zoom=zoom+0.1
		mesh4d.setZoom(pow^zoom)
	elseif b=="wd" then
		zoom=zoom-0.1
		mesh4d.setZoom(pow^zoom)
	elseif b=="m" then
		zoom=0
		mesh4d.setZoom(pow^zoom)
	end
end
