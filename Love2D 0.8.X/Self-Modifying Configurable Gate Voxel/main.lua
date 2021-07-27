--By xXxMoNkEyMaNxXx
--modifyz

math.randomseed(os.time())
math.random()

local tau=2*math.pi
local floor=math.floor
local rand=math.random

local fps=love.timer.getFPS

local mX,mY=love.mouse.getX,love.mouse.getY
local isBtn=love.mouse.isDown
local isKey=love.keyboard.isDown

local draw=love.graphics.draw
local line=love.graphics.line
local point=love.graphics.point
local rect=love.graphics.rectangle
local title=love.graphics.setCaption

local newCanvas=love.graphics.newCanvas
local newEffect=love.graphics.newPixelEffect

local colour=love.graphics.setColor
local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect
local setCaption=love.graphics.setCaption

local noise=newEffect(love.filesystem.read'noise.frag')
local iterate=newEffect(love.filesystem.read'iterate.frag')
local send=noise.send

local noisy=newCanvas(256,256)
local gid=noisy.getImageData
noisy:renderTo(function()
	local wtf=love.image.newImageData(256,256)
	wtf:mapPixel(function()
		return rand()*255,rand()*255,rand()*255,rand()*255
	end)
	local omg=love.graphics.newImage(wtf)
	draw(omg)
end)

local function pseudo(canvas)
	colour(rand()*255,rand()*255,rand()*255,rand()*255)
	setCanvas(canvas)
	draw(noisy)
	colour(rand()*255,rand()*255,rand()*255,rand()*255)
	setCanvas(noisy)
	draw(noisy)
	return canvas
end

local N=8

setEffect(noise)
local states={}
local config={}
local input0={}
local input1={}
for l=1,N do
	states[l]=pseudo(newCanvas(256,256))
	config[l]=pseudo(newCanvas(256,256))
	input0[l]=pseudo(newCanvas(256,256))
	input1[l]=pseudo(newCanvas(256,256))
	---[[
	send(iterate,"states["..(l-1).."]",states[l])
	---]]
end
setEffect()
setCanvas()

config[2]:clear()


local layer=1
local increment=false
function love.draw()
	colour(255,255,255,255)
	draw(states[layer],0,0)
	draw(config[layer],256,0)
	draw(input0[layer],0,256)
	draw(input1[layer],256,256)
	if increment then
		layer=layer%N+1
	end
end

local function bitsToByte(_0,_1,_2,_3,_4,_5,_6,_7)
	return floor(_0/255+0.5)+2*floor(_1/255+0.5)+4*floor(_2/255+0.5)+8*floor(_3/255+0.5)+16*floor(_4/255+0.5)+32*floor(_5/255+0.5)+64*floor(_6/255+0.5)+128*floor(_7/255+0.5)
end

local why=gid(states[1])
local pixel=why.getPixel
---[[
local function modify(j)
	local a0,a1=pixel(why,j,0)
	local b0,b1=a0>127,a1>127
	if b0 or b1 then
		local sx0,sx1=pixel(why,j,1)
		local sx2,sx3=pixel(why,j,2)
		local sx4,sx5=pixel(why,j,3)
		local sx6,sx7=pixel(why,j,4)
		local sx=bitsToByte(sx0,sx1,sx2,sx3,sx4,sx5,sx6,sx7)
		local sy0,sy1=pixel(why,j,5)
		local sy2,sy3=pixel(why,j,6)
		local sy4,sy5=pixel(why,j,7)
		local sy6,sy7=pixel(why,j,8)
		local sy=bitsToByte(sy0,sy1,sy2,sy3,sy4,sy5,sy6,sy7)
		local sz0,sz1=pixel(why,j,9)
		local sz2,sz3=pixel(why,j,10)
		local sz4,sz5=pixel(why,j,11)
		local sz6,sz7=pixel(why,j,12)
		local sz=bitsToByte(sz0,sz1,sz2,sz3,sz4,sz5,sz6,sz7)
		if b0 and b1 then
			local cr0,cr1=pixel(why,j,13)
			local cr2,cr3=pixel(why,j,14)
			local cr4,cr5=pixel(why,j,15)
			local cr6,cr7=pixel(why,j,16)
			local cg0,cg1=pixel(why,j,17)
			local cg2,cg3=pixel(why,j,18)
			local cg4,cg5=pixel(why,j,19)
			local cg6,cg7=pixel(why,j,20)
			local cb0,cb1=pixel(why,j,21)
			local cb2,cb3=pixel(why,j,22)
			local cb4,cb5=pixel(why,j,23)
			local cb6,cb7=pixel(why,j,24)
			local ca0,ca1=pixel(why,j,25)
			local ca2,ca3=pixel(why,j,26)
			local ca4,ca5=pixel(why,j,27)
			local ca6,ca7=pixel(why,j,28)
			colour(bitsToByte(cr0,cr1,cr2,cr3,cr4,cr5,cr6,cr7),bitsToByte(cg0,cg1,cg2,cg3,cg4,cg5,cg6,cg7),bitsToByte(cb0,cb1,cb2,cb3,cb4,cb5,cb6,cb7),bitsToByte(ca0,ca1,ca2,ca3,ca4,ca5,ca6,ca7))
			setCanvas(config[floor(N*sz/255)])
			point(0.5+sx,0.5+sy)
			setCanvas()
		elseif b0 then
			local i0x0,i0x1=pixel(why,j,29)
			local i0x2,i0x3=pixel(why,j,30)
			local i0x4,i0x5=pixel(why,j,31)
			local i0x6,i0x7=pixel(why,j,32)
			local i0y0,i0y1=pixel(why,j,33)
			local i0y2,i0y3=pixel(why,j,34)
			local i0y4,i0y5=pixel(why,j,35)
			local i0y6,i0y7=pixel(why,j,36)
			local i0z0,i0z1=pixel(why,j,37)
			local i0z2,i0z3=pixel(why,j,38)
			local i0z4,i0z5=pixel(why,j,39)
			local i0z6,i0z7=pixel(why,j,40)
			colour(bitsToByte(i0x0,i0x1,i0x2,i0x3,i0x4,i0x5,i0x6,i0x7),bitsToByte(i0y0,i0y1,i0y2,i0y3,i0y4,i0y5,i0y6,i0y7),bitsToByte(i0z0,i0z1,i0z2,i0z3,i0z4,i0z5,i0z6,i0z7),255)
			setCanvas(input0[floor(N*sz/255)])
			point(0.5+sx,0.5+sy)
			setCanvas()
		elseif b1 then
			local i1x0,i1x1=pixel(why,j,41)
			local i1x2,i1x3=pixel(why,j,42)
			local i1x4,i1x5=pixel(why,j,43)
			local i1x6,i1x7=pixel(why,j,44)
			local i1y0,i1y1=pixel(why,j,45)
			local i1y2,i1y3=pixel(why,j,46)
			local i1y4,i1y5=pixel(why,j,47)
			local i1y6,i1y7=pixel(why,j,48)
			local i1z0,i1z1=pixel(why,j,49)
			local i1z2,i1z3=pixel(why,j,50)
			local i1z4,i1z5=pixel(why,j,51)
			local i1z6,i1z7=pixel(why,j,52)
			colour(bitsToByte(i1x0,i1x1,i1x2,i1x3,i1x4,i1x5,i1x6,i1x7),bitsToByte(i1y0,i1y1,i1y2,i1y3,i1y4,i1y5,i1y6,i1y7),bitsToByte(i1z0,i1z1,i1z2,i1z3,i1z4,i1z5,i1z6,i1z7),255)
			setCanvas(input1[floor(N*sz/255)])
			point(0.5+sx,0.5+sy)
			setCanvas()
		end
	end
end

local lx,ly=0,0
function love.update()
	colour(255,255,255,255)
	setEffect(iterate)
	for l=1,N do
		setCanvas(states[l])
		send(iterate,"input0",input0[l])
		send(iterate,"input1",input1[l])
		draw(config[l])
	end
	setEffect()
	setCanvas()
	why=gid(states[1])
	for x=0,255 do
		modify(x)
	end
	local x,y=mX(),mY()
	local d_0,d_1=isBtn'l',isBtn'r'
	if d_0 or d_1 then
		local a,b=x<256,y<256
		if a and b then
			setCanvas(states[layer])
		elseif b then
			setCanvas(config[layer])
		elseif a then
			setCanvas(input0[layer])
		else
			setCanvas(input1[layer])
		end
		colour(rand()*255,rand()*255,rand()*255,rand()*255)
		if d_0 then
			if x==lx and y==ly then
				point(0.5+x%256,0.5+y%256)
			else
				line(0.5+x%256,0.5+y%256,0.5+lx%256,0.5+ly%256)
			end
		end
		if d_1 then
			setEffect(noise)
			draw(noisy,x%256,y%256,tau*rand(),0.25,0.25,128,128)
			setEffect()
		end
		setCanvas()
		colour(255,255,255,255)
	end
	lx,ly=x,y
	setCaption("Self-Modifying Configurable Gate Voxel - "..fps().." FPS")
	collectgarbage()
end
--]]

function love.keypressed(k)
	if k=="return" then
		increment=not increment
	elseif k==" " then
		layer=layer%N+1
	elseif k=="kpenter" then
		layer=N
	end
end
