--By xXxMoNkEyMaNxXx
local pi2=math.pi/2
local rand=math.random

local fps=love.timer.getFPS
local isBtn=love.mouse.isDown
local printl=love.graphics.print
local getp=love.mouse.getPosition
local setc=love.graphics.setCaption
local newImage=love.graphics.newImage
local setColor=love.graphics.setColor
local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect

local draw=love.graphics.draw
local line=love.graphics.line
local point=love.graphics.point
local rect=love.graphics.rectangle

local vs={love.graphics.getWidth(),love.graphics.getHeight()}
local life=love.graphics.newPixelEffect(love.filesystem.read'glsl/GOL.glsl')
local paste=love.graphics.newPixelEffect(love.filesystem.read'glsl/Paste.glsl')
local random=love.graphics.newPixelEffect(love.filesystem.read'glsl/random.glsl')
local magnify=love.graphics.newPixelEffect(love.filesystem.read'glsl/magnify.glsl')
local send=life.send

local pow=2
local mag=0

local go=true
local tick=false

local dir=0
local drawevent

local last={getp()}

local primary={0,0,0,255}
local secondary={255,255,255,255}
local function img(fname,ext)
	return newImage("presets/"..fname.."."..(ext or "png"))
end
--	[""]=img'presets/.png',
local presets={
	["q"]=img'glider',
	["w"]=img'space ship',
	["e"]=img'glider gun',
	["g"]=img'Golly',
	["c"]=img("lenaC","jpg"),
	["1"]=img'U1',
	["2"]=img'U2',
	["3"]=img'U3',
	["4"]=img'U4',
	["5"]=img'wtf',
}

send(life,"vs",vs)
send(life,"primary",{primary[1]/255,primary[2]/255,primary[3]/255,primary[4]/255})
send(life,"secondary",{secondary[1]/255,secondary[2]/255,secondary[3]/255,secondary[4]/255})

--send(paste,"primary",{primary[1]/255,primary[2]/255,primary[3]/255,primary[4]/255})
--send(paste,"secondary",{secondary[1]/255,secondary[2]/255,secondary[3]/255,secondary[4]/255})

send(magnify,"vs",vs)
send(magnify,"mag",pow^mag)
send(magnify,"radius0",150)
send(magnify,"radius1",200)

love.graphics.setPointSize(1)
love.graphics.setBackgroundColor(secondary)

local to=love.graphics.newCanvas()
local from=love.graphics.newCanvas()


function love.draw()
	local m={getp()}
	send(magnify,"icentre",m)
	if isBtn'l' then
		setColor(primary)
		setCanvas(from)
		if last[1]==m[1] and last[2]==m[2] then
			point(m[1]+0.5,m[2]+0.5)
		else
			line(last[1]+0.5,last[2]+0.5,m[1]+0.5,m[2]+0.5)
		end
		setCanvas()
	elseif isBtn'r' then
		setColor(secondary)
		setCanvas(from)
		if last[1]==m[1] and last[2]==m[2] then
			point(m[1]+0.5,m[2]+0.5)
		else
			line(last[1]+0.5,last[2]+0.5,m[1]+0.5,m[2]+0.5)
		end
		setCanvas()
	elseif drawevent then
		local image=presets[drawevent]
		if image then
			setCanvas(from)
			setEffect(paste)
			draw(image,m[1],m[2],dir*pi2)
			setCanvas()
			setEffect()
		end
		drawevent=nil
	end
	last=m

	setColor(255,255,255,255)
	if go or tick then
		setCanvas(to)
		setEffect(life)
		draw(from)
		setCanvas()
		setEffect(magnify)
		draw(to)
		setEffect()
		from,to=to,from--olo
		tick=false
	else
		setEffect(magnify)
		draw(from)
		setEffect()
	end

	local frames=fps()
	setColor(255,255,255,255)
	printl("FPS:"..frames,1,1)
	setColor(0,0,0,255)
	printl("FPS:"..frames,0,0)
	setc("Game of Life - "..frames.." FPS")
end

function love.keypressed(key)

	if key=="escape" then
		love.event.quit()

	--pause
	elseif key==" " then
		go=not go

	--Iterate once
	elseif key=="return" then
		tick=true

	--Clear
	elseif key=="delete" then
		from:clear()

	elseif key=="insert" then
		send(random,"lol",{rand()*2^16,rand()*2^16,rand()*2^16,rand()*2^16})
		from:renderTo(function()
			setEffect(random)
			rect("fill",0,0,vs[1],vs[2])
			setEffect()
		end)

	--Direction
	elseif key=="right" then
		dir=0
	elseif key=="down" then
		dir=1
	elseif key=="left" then
		dir=2
	elseif key=="up" then
		dir=3

	--Shooting with numpad
	elseif key=="kp6" then
		dir=0
		drawevent="w"
	elseif key=="kp9" then
		dir=0
		drawevent="q"
	elseif key=="kp8" then
		dir=3
		drawevent="w"
	elseif key=="kp7" then
		dir=3
		drawevent="q"
	elseif key=="kp4" then
		dir=2
		drawevent="w"
	elseif key=="kp1" then
		dir=2
		drawevent="q"
	elseif key=="kp2" then
		dir=1
		drawevent="w"
	elseif key=="kp3" then
		dir=1
		drawevent="q"

	--Direct drawing an image
	elseif presets[key] then
		drawevent=key
	end
end

function love.mousepressed(_,_,btn)
	if btn=="wu" then
		mag=mag+0.1
		send(magnify,"mag",pow^mag)
	elseif btn=="wd" then
		mag=mag-0.1
		send(magnify,"mag",pow^mag)
	elseif btn=="m" then
		mag=0
		send(magnify,"mag",pow^mag)
	end
end
