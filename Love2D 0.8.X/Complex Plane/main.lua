--By xXxMoNkEyMaNxXx
require'Complex'

local function eq(z)
	return cmath.acos(z)
end

local cos=math.cos
local sin=math.sin
local min=math.min
local max=math.max
local modf=math.modf
local ceil=math.ceil
local floor=math.floor

local file="img/place.jpg"

local scale=0
local theta=0
local rspeed=1
local speed=200
local offset={0,0}
local viewsize={love.graphics.getWidth(),love.graphics.getHeight()}
local shader=love.graphics.newPixelEffect(love.filesystem.read'glsl/shader.glsl')
local img=love.graphics.newImage(file)
local imgwh={img:getWidth(),img:getHeight()}
local window={2,2*imgwh[2]/imgwh[1]}

shader:send("window",window)

love.graphics.setPixelEffect(shader)
local fps=love.timer.getFPS
local draw=love.graphics.draw
local setc=love.graphics.setCaption
function love.draw()
	local s=10^scale
	draw(img,viewsize[1]/2,viewsize[2]/2,theta,s,s,imgwh[1]/2+offset[1],imgwh[2]/2+offset[2])
	setc("Complex Image Remapping - "..fps())
end
function love.mousepressed(_,_,b)
	if b=="wu" then
		scale=scale+0.1
	elseif b=="wd" then
		scale=scale-0.1
	end
end

local isKey=love.keyboard.isDown
function love.update(t)
	local o=speed*t/10^scale
	if isKey'lshift' then
		o=o*4
	end
	if isKey'w' then
		offset[1]=offset[1]+o*sin(-theta)
		offset[2]=offset[2]-o*cos(-theta)
	end
	if isKey'a' then
		offset[1]=offset[1]-o*cos(-theta)
		offset[2]=offset[2]-o*sin(-theta)
	end
	if isKey's' then
		offset[1]=offset[1]-o*sin(-theta)
		offset[2]=offset[2]+o*cos(-theta)
	end
	if isKey'd' then
		offset[1]=offset[1]+o*cos(-theta)
		offset[2]=offset[2]+o*sin(-theta)
	end
	if isKey'q' then
		theta=theta+rspeed*t
	end
	if isKey'e' then
		theta=theta-rspeed*t
	end
end
function love.keypressed(k)
	if k=="escape" then
		love.event.quit()
	elseif k=="r" then
		offset[1]=0
		offset[2]=0
		theta=0
		scale=0
	end
end

local input=love.image.newImageData(file)

local getPixel=input.getPixel
local getWidth=input.getWidth
local getHeight=input.getHeight

local iwh={getWidth(input),getHeight(input)}
local owh={iwh[1]*2,iwh[2]*2}

local output=love.image.newImageData(owh[1],owh[2])

local function Pixel(data,x,y,w,h,m)
	local r,g,b,a=getPixel(data,max(0,min(w-1,x)),max(0,min(h-1,y)))
	if x<0 or y<0 or x>w or y>h then
		return r*m,g*m,b*m,0
	else
		return r*m,g*m,b*m,a*m
	end
end

local function Texel(data,x,y,w,h)
	local fx,IX=modf(x)
	local fy,IY=modf(y)
	local ix,iy=1-IX,1-IY
	local cx,cy=ceil(x),ceil(y)
	local p00r,p00g,p00b,p00a=Pixel(data,fx,fy,w,h,ix*iy)
	local p01r,p01g,p01b,p01a=Pixel(data,fx,cy,w,h,ix*IY)
	local p10r,p10g,p10b,p10a=Pixel(data,cx,fy,w,h,IX*iy)
	local p11r,p11g,p11b,p11a=Pixel(data,cx,cy,w,h,IX*IY)
	return p00r+p01r+p10r+p11r,p00g+p01g+p10g+p11g,p00b+p01b+p10b+p11b,p00a+p01a+p10a+p11a
end

local re,im=cmath.re,cmath.im
local ri=cmath.complex
output:mapPixel(function(x,y)--,r,g,b,a
	local z=ri(((x)/owh[1]-0.5)*window[1],(0.5-(y)/owh[2])*window[2])
	local n=eq(z)
	return Texel(input,(re(n)/window[1]+0.5)*iwh[1]-0.5,(0.5-im(n)/window[2])*iwh[2],iwh[1],iwh[2])
end)

love.filesystem.setIdentity'Results'
local exists=love.filesystem.exists
local n=1
while exists("Output"..n..".png") do
	n=n+1
	if n>1e2 then
		break
	end
end
local fname="Output"..n..".png"
local outfile=love.filesystem.newFile(fname)
outfile:open'w'
output:encode(fname)
outfile:close()
