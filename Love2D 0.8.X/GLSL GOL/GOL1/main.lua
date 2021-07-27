--By xXxMoNkEyMaNxXx
local vs={love.graphics.getWidth(),love.graphics.getHeight()}
local life=love.graphics.newPixelEffect(love.filesystem.read'GOL.glsl')
local send=life.send
local setEffect=love.graphics.setPixelEffect

send(life,"vs",vs)
send(life,"primary",{1,1,1,1})
send(life,"secondary",{0,0,0,1})

local fps=love.timer.getFPS
local isBtn=love.mouse.isDown
local printl=love.graphics.print
local getp=love.mouse.getPosition
local setc=love.graphics.setCaption
local setCanvas=love.graphics.setCanvas

local from=love.graphics.newCanvas()
local to=love.graphics.newCanvas()

local last={getp()}

local go=true
local ipf=1

local draw=love.graphics.draw
local line=love.graphics.line
local rect=love.graphics.rectangle
function love.draw()
	local m={getp()}
	if isBtn'l' then
		setCanvas(from)
		line(last[1],last[2],m[1],m[2])
		setCanvas()
	end
	last=m

	if go then
		for _=1,ipf do
			setCanvas(to)
			setEffect(life)
			draw(from)
			setCanvas()
			setEffect()
			draw(to)
			from,to=to,from--olo
		end
	else
		draw(from)
	end
	printl("FPS:"..fps(),0,0)
	printl("Iterations per frame:"..ipf,0,20)
	setc'Game of Life'
end

function love.keypressed(key)
	if key=="escape" then
		love.event.quit()
	elseif key==" " then
		go=not go
	elseif key=="up" then
		ipf=ipf+1
	elseif key=="down" then
		ipf=ipf>1 and ipf-1 or 1
	end
end

function love.mousepressed(_,_,btn)
	if btn=="r" then
		go=not go
	elseif btn=="wu" then
		ipf=ipf+1
	elseif btn=="wd" then
		ipf=ipf>1 and ipf-1 or 1
	end
end
