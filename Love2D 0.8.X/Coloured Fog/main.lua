--By xXxMoNkEyMaNxXx
local vec=require'vec'
local mat=require'mat'

local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition

local isKey=love.keyboard.isDown

local setCaption=love.graphics.setCaption

local fps=love.timer.getFPS

local setCanvas=love.graphics.setCanvas

local h=love.graphics.getHeight()
local View={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}
local pos={0,1,0}
local rot={{1,0,0},{0,1,0},{0,0,1}}

local speed=1

img=love.graphics.newImage'CPU.png'
local shader=love.graphics.newPixelEffect(love.filesystem.read'litfog2.frag')
love.graphics.setPixelEffect(shader)

shader:send("View",View)
shader:send("pos",pos)
shader:send("rot",rot)
shader:send("maxd",20)
--shader:send("dx",0.6)
shader:send("ground",img)

local abc=false
local sq=100
local i,j=0,0
local rect=love.graphics.rectangle
function love.draw()
	if abc then
		local iw,jw=View[2][1]/sq,View[2][2]/sq
		for j=0,jw do
			for i=0,iw do
				rect("fill",i*sq,j*sq,sq,sq)
			end
		end
	else
		rect("fill",View[1][1],View[1][2],View[2][1],View[2][2])
	end
	setCaption("Coloured Fog - "..fps().." FPS")
end

local mPos={getPos()}
local mDir=vec.normalize{mPos[1]-View[1][1]-View[2][1]/2,h-mPos[2]-View[1][2]-View[2][2]/2,View[2][2]}
function love.update(t)
	local move={0,0,0}
	if isKey'd' then
		move[1]=move[1]+1
	end
	if isKey'a' then
		move[1]=move[1]-1
	end
	if isKey' ' then
		move[2]=move[2]+1
	end
	if isKey'lshift' then
		move[2]=move[2]-1
	end
	if isKey'w' then
		move[3]=move[3]+1
	end
	if isKey's' then
		move[3]=move[3]-1
	end
	pos=vec.add(pos,mat.mulVec(rot,vec.mulNum(move,speed*t)))
	pos[2]=math.max(0.001,pos[2])

	---[[
	local newPos={getPos()}
	local newDir=vec.normalize{newPos[1]-View[1][1]-View[2][1]/2,h-newPos[2]-View[1][2]-View[2][2]/2,View[2][2]}
	if isBtn'r' then
		local msq=mDir[1]*mDir[1]+mDir[2]*mDir[2]+mDir[3]*mDir[3]
		local w,x,y,z=(newDir[1]*mDir[1]+newDir[2]*mDir[2]+newDir[3]*mDir[3])/msq,(newDir[3]*mDir[2]-newDir[2]*mDir[3])/msq,(newDir[1]*mDir[3]-newDir[3]*mDir[1])/msq,(newDir[2]*mDir[1]-newDir[1]*mDir[2])/msq
		rot=mat.mulMat(rot,{{w*w+x*x-y*y-z*z,2*(x*y+w*z),2*(x*z-w*y)},{2*(x*y-w*z),w*w-x*x+y*y-z*z,2*(y*z+w*x)},{2*(x*z+w*y),2*(y*z-w*x),w*w-x*x-y*y+z*z}})
	end
	mPos=newPos
	mDir=newDir
	shader:send("rot",rot)
	--]]
	shader:send("pos",pos)
end

function love.keypressed(k)
	if k=="escape" then
		love.event.quit()
	end
end
