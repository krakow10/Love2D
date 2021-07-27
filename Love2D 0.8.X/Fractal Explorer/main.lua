--Made by xXxMoNkEyMaNxXx
local version=0.5

local vs={love.graphics.getWidth(),love.graphics.getHeight()}
local effect=love.graphics.newPixelEffect(love.filesystem.read'glsl/Fractal.glsl')
local send=effect.send
send(effect,"maxi",1e3)
send(effect,"vs",vs)
--send(effect,"limit",4)
send(effect,"limit",625)


local thumb={pos={5,5},view={100*vs[1]/vs[2],100}}
local viewsize={pos={0,0},view={vs[1],vs[2]}}

local default={pos={-vs[1]/vs[2]*3/2-0.75,-1.5},view={3*vs[1]/vs[2],3}}
local window={pos={-vs[1]/vs[2]*3/2-0.75,-1.5},view={3*vs[1]/vs[2],3}}

local rect=love.graphics.rectangle
local function render(fractal,screen)
	send(effect,"pos",fractal.pos)
	send(effect,"view",fractal.view)
	send(effect,"spot",screen.pos)
	send(effect,"size",screen.view)
	rect("fill",screen.pos[1],screen.pos[2],screen.view[1],screen.view[2])
end

local base=7
local min=math.min
local log=math.log
local ceil=math.ceil
local line=love.graphics.line
local colour=love.graphics.setColor
local setEffect=love.graphics.setPixelEffect
function love.draw()
	setEffect(effect)
	render(window,viewsize)
	render(default,thumb)
	local xZoom=min(0,ceil(log(window.view[2]/default.view[2])/log(base)))
	local percent={(window.pos[1]-default.pos[1])/(default.view[1]-window.view[1]),(window.pos[2]-default.pos[2])/(default.view[2]-window.view[2])}
	local last=default
	for z=-1,xZoom,-1 do
		local mul=base^z
		local area={
			pos={default.pos[1]+percent[1]*default.view[1]*(1-mul),default.pos[2]+percent[2]*default.view[2]*(1-mul)},
			view={default.view[1]*mul,default.view[2]*mul}
		}
		setEffect()
		local box={pos={thumb.pos[1]+thumb.view[1]*(area.pos[1]-last.pos[1])/last.view[1],thumb.pos[2]-thumb.view[2]*(z+1)+thumb.view[2]*(area.pos[2]-last.pos[2])/last.view[2]},view={thumb.view[1]*area.view[1]/last.view[1],thumb.view[2]*area.view[2]/last.view[2]}}
		local cell={pos={thumb.pos[1],thumb.pos[2]-thumb.view[2]*z},view=thumb.view}
		colour(255,255,255,192)
		rect("line",cell.pos[1]-1,cell.pos[2]-1,cell.view[1]+2,cell.view[2]+2)
		colour(255,0,0,96)
		rect("line",box.pos[1],box.pos[2],box.view[1],box.view[2])
		line(box.pos[1],box.pos[2],cell.pos[1],cell.pos[2])
		line(box.pos[1]+box.view[1],box.pos[2],cell.pos[1]+cell.view[1],cell.pos[2])
		--line(box.pos[1],box.pos[2]+box.view[2],cell.pos[1],cell.pos[2]+cell.view[2])
		--line(box.pos[1]+box.view[1],box.pos[2]+box.view[2],cell.pos[1]+cell.view[1],cell.pos[2]+cell.view[2])
		last=area
		setEffect(effect)
		render(area,cell)
	end
	setEffect()
	colour(255,255,255,192)
	rect("line",thumb.pos[1]-1,thumb.pos[2]-1,thumb.view[1]+2,thumb.view[2]+2)
	colour(255,0,0,96)
	rect("line",thumb.pos[1]+thumb.view[1]*(window.pos[1]-last.pos[1])/last.view[1],thumb.pos[2]-thumb.view[2]*xZoom+thumb.view[2]*(window.pos[2]-last.pos[2])/last.view[2],thumb.view[1]*window.view[1]/last.view[1],thumb.view[2]*window.view[2]/last.view[2])
end

local fps=love.timer.getFPS
local isBtn=love.mouse.isDown
local isKey=love.keyboard.isDown
local getp=love.mouse.getPosition
local setc=love.graphics.setCaption

local grab
local zoomsec=0.78
local scrollsec=0.25
function love.update(t)
	local mx,my=getp()

	local scroll={0,0}
	if isKey'right' then scroll[1]=scroll[1]+1 end
	if isKey'left' then scroll[1]=scroll[1]-1 end
	if isKey'up' then scroll[2]=scroll[2]+1 end
	if isKey'down' then scroll[2]=scroll[2]-1 end

	local mul=1
	if isKey'i' then mul=mul*zoomsec^t end
	if isKey'o' then mul=mul/zoomsec^t end

	local newview={window.view[1]*mul,window.view[2]*mul}
	window.pos={window.pos[1]+(window.view[1]-newview[1])*(mx-viewsize.pos[1])/viewsize.view[1]+newview[1]*scroll[1]*scrollsec*t,window.pos[2]+(window.view[2]-newview[2])*(my-viewsize.pos[2])/viewsize.view[2]-newview[2]*scroll[2]*scrollsec*t}
	window.view=newview

	if isBtn'l' then
		if not grab then
			grab={window.pos[1]+(mx-viewsize.pos[1])/viewsize.view[1]*window.view[1],window.pos[2]+(my-viewsize.pos[2])/viewsize.view[2]*window.view[2]}
		end
		window.pos[1]=grab[1]-(mx-viewsize.pos[1])/viewsize.view[1]*window.view[1]
		window.pos[2]=grab[2]-(my-viewsize.pos[2])/viewsize.view[2]*window.view[2]
	elseif grab then
		window.pos[1]=grab[1]-(mx-viewsize.pos[1])/viewsize.view[1]*window.view[1]
		window.pos[2]=grab[2]-(my-viewsize.pos[2])/viewsize.view[2]*window.view[2]
		grab=nil
	end
	setc("Mandelbrot Explorer v"..version.." - "..fps().." FPS")
end

local zoomstep=0.94
function love.mousepressed(x,y,button)
	if button=="wu" then
		local newview={window.view[1]*zoomstep,window.view[2]*zoomstep}
		window.pos={window.pos[1]+(window.view[1]-newview[1])*(x-viewsize.pos[1])/viewsize.view[1],window.pos[2]+(window.view[2]-newview[2])*(y-viewsize.pos[2])/viewsize.view[2]}
		window.view=newview
	elseif button=="wd" then
		local newview={window.view[1]/zoomstep,window.view[2]/zoomstep}
		window.pos={window.pos[1]+(window.view[1]-newview[1])*(x-viewsize.pos[1])/viewsize.view[1],window.pos[2]+(window.view[2]-newview[2])*(y-viewsize.pos[2])/viewsize.view[2]}
		window.view=newview
	end
end
