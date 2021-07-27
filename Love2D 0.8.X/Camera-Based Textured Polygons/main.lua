--Surface Texture Demo

--localize
local sin,cos=math.sin,math.cos

--Load module
local texture=require'TextureSurface'

--Store camera info
local cam_pos,cam_axis={0,0,0},{1,0,1}

--Store object info
local surf_image=love.graphics.newImage'Breaking Benjamin.png'
local surf_pos,surf_quat,surf_size={0,0,0},{0,0,0,1},{7,7}

function love.load()
	love.graphics.setBackgroundColor(192,192,255,255)
	texture.preload(true)--Sets the pixel effect
	texture.prepare(surf_image,{7,7},surf_pos, texture.QuaternionToMatrix(surf_quat))--Sends the data to the shader (Image, Repeat, Position, Right, Up, Normal)
end

local next_randomization=0
function love.draw()
	love.graphics.quad("fill",texture.vertices(surf_size))--10,10,650,10,650,490,10,490)--Compute the current polygon's vertices on the screen by specifying the size.
end

function love.update()
	local t=love.timer.getTime()%(math.pi*2)
	cam_pos={15*cos(sin(t)),5*sin(t/3),15*sin(sin(t))}
	if love.timer.getTime()>next_randomization then
		--cam_axis={2*math.random()-1,2*math.random()-1,2*math.random()-1}
		texture.setCamera(cam_pos,cam_axis,math.random()*2*math.pi)--Moves the camera (Position [<, Axis, Angle> OR <, Quaternion>])
		next_randomization=love.timer.getTime()+2
	else
		texture.setCamera(cam_pos)
	end
end
