--Made by xXxMoNkEyMaNxXx
local version=0.5

local vec=require'vec'
local ui=loader.open'ui.lua'

local w=ui.connect(ctrl.newWindow())
ctrl.worldDrag(w)
local wrapper=ui.wrapper(w)
w.Window={{-0.5,0},{2,2}}
wrapper.TitleBar.Text="Mandelbrot Explorer"


local effect=love.graphics.newPixelEffect(love.filesystem.read'Mandelbrot/Mandelbrot.glsl')
local send=effect.send
send(effect,"maxi",1e3)
send(effect,"h",love.graphics.getHeight())


local thumb={pos={5,5},{120,100}}

local default={{-2,-1},{3,2}}

local rect=love.graphics.rectangle
local function render(fractal,screen)
	send(effect,"pos",fractal[1])
	send(effect,"view",fractal[2])
	send(effect,"spot",screen[1])
	send(effect,"size",screen[2])
	rect("fill",screen[1][1],screen[1][2],screen[2][1],screen[2][2])
end

local base=7
local min=math.min
local log=math.log
local ceil=math.ceil
local line=love.graphics.line
local colour=love.graphics.setColor
local setEffect=love.graphics.setPixelEffect
function w:draw()
	setEffect(effect)
	render(self.Window,self.View)
	--[[
	render(default,thumb)
	local xZoom=min(0,ceil(log(w.Window[2][2]/default[2][2])/log(base)))
	local percent={(w.Window[1][1]-default[1][1])/(default[2][1]-w.Window[2][1]),(w.Window[1][2]-default[1][2])/(default[2][2]-w.Window[2][2])}
	local last=default
	for z=-1,xZoom,-1 do
		local mul=base^z
		local area={
			{default[1][1]+percent[1]*default[2][1]*(1-mul),default[1][2]+percent[2]*default[2][2]*(1-mul)},
			{default[2][1]*mul,default[2][2]*mul}
		}
		setEffect()
		local box={{thumb[1][1]+thumb[2][1]*(area[1][1]-last[1][1])/last[2][1],thumb[1][2]-thumb[2][2]*(z+1)+thumb[2][2]*(area[1][2]-last[1][2])/last[2][2]},{thumb[2][1]*area[2][1]/last[2][1],thumb[2][2]*area[2][2]/last[2][2]}}
		local cell={{thumb[1][1],thumb[1][2]-thumb[2][2]*z},thumb[2]}
		colour(255,255,255,192)
		rect("line",cell[1][1]-1,cell[1][2]-1,cell[2][1]+2,cell[2][2]+2)
		colour(255,0,0,64)
		rect("line",box[1][1],box[1][2],box[2][1],box[2][2])
		line(box[1][1],box[1][2],cell[1][1],cell[1][2])
		line(box[1][1]+box[2][1],box[1][2],cell[1][1]+cell[2][1],cell[1][2])
		--line(box[1][1],box[1][2]+box[2][2],cell[1][1],cell[1][2]+cell[2][2])
		--line(box[1][1]+box[2][1],box[1][2]+box[2][2],cell[1][1]+cell[2][1],cell[1][2]+cell[2][2])
		last=area
		setEffect(effect)
		render(area,cell)
	end
	--]]
	setEffect()
	--[[
	colour(255,255,255,192)
	rect("line",thumb[1][1]-1,thumb[1][2]-1,thumb[2][1]+2,thumb[2][2]+2)
	colour(255,0,0,64)
	rect("line",thumb[1][1]+thumb[2][1]*(w.Window[1][1]-last[1][1])/last[2][1],thumb[1][2]-thumb[2][2]*xZoom+thumb[2][2]*(w.Window[1][2]-last[1][2])/last[2][2],thumb[2][1]*w.Window[2][1]/last[2][1],thumb[2][2]*w.Window[2][2]/last[2][2])
	--]]
end

local fps=love.timer.getFPS
---[[
local zoomsec=0.78
local scrollsec=0.25
--]]
function w:update(t)
	local scroll={0,0}
	if self.Key.right then scroll[1]=scroll[1]+1 end
	if self.Key.left then scroll[1]=scroll[1]-1 end
	if self.Key.up then scroll[2]=scroll[2]-1 end
	if self.Key.down then scroll[2]=scroll[2]+1 end

	local mul=1
	if self.Key.i then mul=mul*zoomsec^t end
	if self.Key.o then mul=mul/zoomsec^t end

	local newview={w.Window[2][1]*mul,w.Window[2][2]*mul}
	local worldScroll=vec.mulNum(vec.mul(scroll,newview),scrollsec*t)
	if w.WorldDragOffset then
		w.WorldDragOffset=vec.add(w.WorldDragOffset,worldScroll)
	end
	w.Window[1]={w.Window[1][1]+(w.Window[2][1]-newview[1])*(w.m[1]-w.View[2][1]/2)/w.View[2][2]+worldScroll[1],w.Window[1][2]+(w.Window[2][2]-newview[2])*(w.m[2]-w.View[2][2]/2)/w.View[2][2]+worldScroll[2]}
	w.Window[2]=newview

	wrapper.TitleBar.Text="Mandelbrot Explorer v"..version.." - "..fps().." FPS"
end

w.Control._BringToFront={"MDl","MDr"}
