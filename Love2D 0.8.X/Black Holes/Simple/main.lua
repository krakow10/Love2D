--By xXxMoNkEyMaNxXx
local w,h=love.graphics.getWidth(),love.graphics.getHeight()
local shader=love.graphics.newPixelEffect(love.filesystem.read'BH.frag')
local sky=love.graphics.newImage'Skymap.png'
local p={0,0,-1e5}
local mx,my,mz={1,0,0},{0,1,0},{0,0,1}
shader:send("sky",sky)
shader:send("Ms",1)
shader:send("vs",{w,h})
shader:send("pos",p)
shader:send("mx",mx)
shader:send("my",my)
shader:send("mz",mz)
love.graphics.setPixelEffect(shader)

local rot=math.pi/4
local speed=1e4

local rect=love.graphics.rectangle
function love.draw()
	rect("fill",0,0,w,h)
end
local sin,cos=math.sin,math.cos
local isKey=love.keyboard.isDown
function love.update(t)
	if isKey'left' then
		local ang=rot*t
		local s,c=sin(ang),cos(ang)
		mx,mz={c*mx[1]+s*mz[1],c*mx[2]+s*mz[2],c*mx[3]+s*mz[3]},{c*mz[1]-s*mx[1],c*mz[2]-s*mx[2],c*mz[3]-s*mx[3]}
	end
	if isKey'right' then
		local ang=-rot*t
		local s,c=sin(ang),cos(ang)
		mx,mz={c*mx[1]+s*mz[1],c*mx[2]+s*mz[2],c*mx[3]+s*mz[3]},{c*mz[1]-s*mx[1],c*mz[2]-s*mx[2],c*mz[3]-s*mx[3]}
	end
	if isKey'up' then
		local ang=-rot*t
		local s,c=sin(ang),cos(ang)
		mz,my={c*mz[1]+s*my[1],c*mz[2]+s*my[2],c*mz[3]+s*my[3]},{c*my[1]-s*mz[1],c*my[2]-s*mz[2],c*my[3]-s*mz[3]}
	end
	if isKey'down' then
		local ang=rot*t
		local s,c=sin(ang),cos(ang)
		mz,my={c*mz[1]+s*my[1],c*mz[2]+s*my[2],c*mz[3]+s*my[3]},{c*my[1]-s*mz[1],c*my[2]-s*mz[2],c*my[3]-s*mz[3]}
	end
	if isKey'w' then
		local dis=speed*t
		p={p[1]+dis*mz[1],p[2]+dis*mz[2],p[3]+dis*mz[3]}
	end
	if isKey's' then
		local dis=speed*t
		p={p[1]-dis*mz[1],p[2]-dis*mz[2],p[3]-dis*mz[3]}
	end
	if isKey'a' then
		local dis=speed*t
		p={p[1]-dis*mx[1],p[2]-dis*mx[2],p[3]-dis*mx[3]}
	end
	if isKey'd' then
		local dis=speed*t
		p={p[1]+dis*mx[1],p[2]+dis*mx[2],p[3]+dis*mx[3]}
	end
	if isKey'lshift' then
		local dis=speed*t
		p={p[1]+dis*my[1],p[2]+dis*my[2],p[3]+dis*my[3]}
	end
	if isKey' ' then
		local dis=speed*t
		p={p[1]-dis*my[1],p[2]-dis*my[2],p[3]-dis*my[3]}
	end
	if isKey'r' then
		p={0,0,-1e5}
		mx,my,mz={1,0,0},{0,1,0},{0,0,1}
	end
	shader:send("mx",mx)
	shader:send("my",my)
	shader:send("mz",mz)
	shader:send("pos",p)
end
