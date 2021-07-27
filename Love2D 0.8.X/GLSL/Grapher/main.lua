--By xXxMoNkEyMaNxXx
require'vec'
local View={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}
local Window={{0,0},{20,20}}

local Drag={0,0}
local isBtn=love.mouse.isDown
local getX,getY=love.mouse.getX,love.mouse.getY

local rect=love.graphics.rectangle
local setEffect=love.graphics.setPixelEffect
local s=love.graphics.newPixelEffect(love.filesystem.read'GPU.frag')

s:send("BackColour",{1,1,1,1})
s:send("LineColour",{0.25,0,0,1})
s:send("GridColour",{0.8,0.8,0.8,1})
s:send("Thickness",4.9)
s:send("View",View)
s:send("Window",Window)

math.randomseed(os.time()+os.clock())
math.random()
local rand=math.random
local function r()
	return 2*rand()-1
end

local degree=15--degree must agree with degree in shader (for my polynomials)

function love.draw()
	s:send("RANDOM",rand())
	setEffect(s)
	rect("fill",View[1][1],View[1][2],View[2][1],View[2][2])
	setEffect()
end

function love.update(t)
	local m={getX()-View[1][1],View[2][2]-getY()-View[1][2]}
	if isBtn'l' and Drag then
		Window[1]=vec.sub(Drag,vec.mul(Window[2],vec.divNum(vec.sub(m,vec.divNum(View[2],2)),View[2][2])))
		s:send("Window",Window)
	end
end

function love.keypressed(k)
	if k=="right" then--Take out/Comment out my polynomial stuff if you want to graph your own functions.
		local P1={}
		local P2={}
		for d=1,degree do
			P1[d]=r()
			P2[d]=r()
		end
		s:send("poly1",unpack(P1))
		s:send("poly2",unpack(P2))
	elseif k=="r" then
		Window={{0,0},{10,10}}
	end
end
love.keypressed'right'

local zoomStep=1.1
function love.mousepressed(x,y,btn)
	local m={x-View[1][1],View[2][2]-y-View[1][2]}
	if btn=="l" then
		--Window[1]+Window[2]*(m-View[1]-View[2]/2)/View[2].y
		Drag=vec.add(Window[1],vec.mul(Window[2],vec.divNum(vec.sub(m,vec.divNum(View[2],2)),View[2][2])))
	elseif btn=="wu" then
		local newWindowSize=vec.divNum(Window[2],zoomStep)
		Window[1]=vec.add(Window[1],vec.mul(vec.sub(Window[2],newWindowSize),vec.divNum(vec.sub(m,vec.divNum(View[2],2)),View[2][2])))
		Window[2]=newWindowSize
		s:send("Window",Window)
	elseif btn=="wd" then
		local newWindowSize=vec.mulNum(Window[2],zoomStep)
		Window[1]=vec.add(Window[1],vec.mul(vec.sub(Window[2],newWindowSize),vec.divNum(vec.sub(m,vec.divNum(View[2],2)),View[2][2])))
		Window[2]=newWindowSize
		s:send("Window",Window)
	end
end

function love.mousereleased(x,y,btn)
	local m={x-View[1][1],View[2][2]-y-View[1][2]}
	if btn=="l" then
		Window[1]=vec.sub(Drag,vec.mul(Window[2],vec.divNum(vec.sub(m,vec.divNum(View[2],2)),View[2][2])))
		Drag=nil
	end
end
