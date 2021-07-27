--By xXxMoNkEyMaNxXx
local vec=require'vec'
local quat=require'quat'

local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition
local isKey=love.keyboard.isDown

local fps=love.timer.getFPS
local title=love.graphics.setCaption

local render
local function setRender(r)
	render=r
end

local mPos={getPos()}
local mDir={0,0,0}
local function update()
	local newPos={getPos()}
	local dPos=vec.sub(newPos,mPos)
	if not (dPos[1]==0 and dPos[2]==0) then
		local newDir=render.toWorld(newPos)
		local dDir=vec.sub(newDir,mDir)
		if isBtn'r' then
			for i=1,#render.scene do
				local cube=render.scene[i]
				cube.quat=quat.mul(quat.axisAngleP(vec.cross(vec.normalize(vec.sub(cube.pos,render.cam.pos)),dDir)),cube.quat)
			end
		end
		mDir=newDir
	end
	mPos=newPos
	title("Rubik's Cube Simulator - "..fps().." FPS")
end

return {
	setRender=setRender,
	update=update,
}
