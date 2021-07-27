--By xXxMoNkEyMaNxXx
--doz elsez
local unpack=unpack

local abs=math.abs
local max,min=math.max,math.min

local remove=table.remove

local draw=love.graphics.draw
local rect=love.graphics.rectangle
local setColor=love.graphics.setColor
local newCanvas=love.graphics.newCanvas
local setCanvas=love.graphics.setCanvas
local newShader=love.graphics.newShader
local setShader=love.graphics.setShader
local setBlendMode=love.graphics.setBlendMode

local isBtn=love.mouse.isDown
local getX,getY=love.mouse.getX,love.mouse.getY

local isKey=love.keyboard.isDown

local tick=love.timer.getTime
local fps=love.timer.getFPS

local vec=require'vec'
local ui=require'ui'
local eventHandler=require'callback'
local ctrl=eventHandler(require'ctrl')

local k=8987549572.1175700865287374323633--Needs to be more accurate

local options={
	show_layers={true,true,false,true},

	draw_equipotentialModulo=true,
	auto_maxPotential=true,
	equipotential=0,
	equipotentialModulo=1,
	animationSpeed=0,
	maxPotential=10,

	draw_fieldModulo=false,
	draw_fieldArrows=true,
	linearConstraint=false,
	cte=0,
	cteModulo=1;

	pointChargeRadius=0.1,
	pointChargeTextureSize={100,100},

	ZoomStep=1.1,
	zoomSpeed=2,
	ScrollSpeed=10,
}

local redraw={true,true,true,true}

local dir={1,0,0}
local pos={0,0,0}

local maxObjects=96
local n=0
local objectPosition={}
local objectCharge={}

local h=love.graphics.getHeight()
local ScreenOffset={0,0}
local ScreenView={love.graphics.getDimensions()}
local WorldOffset={-1.5,-1.5,0}
local WorldView={3*ScreenView[1]/ScreenView[2],3}

local function toWorld(ScreenPoint)
	return vec.add(WorldOffset,vec.mul(vec.sub(ScreenPoint,ScreenOffset),vec.div(WorldView,ScreenView)))
end
local function toScreen(WorldPoint)
	return vec.add(ScreenOffset,vec.mul(vec.sub(WorldPoint,WorldOffset),vec.div(ScreenView,WorldView),0))
end

local mouseScreenPos={getX(),h-getY()}
local mouseWorldPos=toWorld(mouseScreenPos)

local mouseTarget
local WorldDrag
local objectDrag

local potentialGenerator=newShader'potentialGenerator.frag'

PositiveCharge=love.graphics.newImage'Plus.png'
NegativeCharge=love.graphics.newImage'Minus.png'

potentialGenerator:send("WorldOffset",WorldOffset)
potentialGenerator:send("WorldView",WorldView)
potentialGenerator:send("ScreenOffset",ScreenOffset)
potentialGenerator:send("ScreenView",ScreenView)

potentialGenerator:send("animationSpeed",options.animationSpeed)
potentialGenerator:send("draw_equipotentialModulo",options.draw_equipotentialModulo)

potentialGenerator:send("maxPotential",options.maxPotential)
potentialGenerator:send("equipotential",options.equipotential)
potentialGenerator:send("equipotentialModulo",options.equipotentialModulo)

local layer_blendMode={
	"alpha",
	"alpha",
	"alpha",
	"alpha",
}
layers={
	newCanvas(ScreenView[1],ScreenView[2],"hdr"),--Ep
	newCanvas(ScreenView[1],ScreenView[2],"hdr"),--equipotential
	newCanvas(ScreenView[1],ScreenView[2],"hdr"),--field lines
	newCanvas(ScreenView[1],ScreenView[2],"hdr"),--objects
}

love.graphics.setBackgroundColor(255,255,255,255)

local function get_Ep(WorldPoint,no_k)
	local Ep=0
	for i=1,n do
		Ep=Ep+objectCharge[i]/vec.length(vec.sub(objectPosition[i],WorldPoint))
	end
	if no_k then
		return Ep
	else
		return k*Ep
	end
end

local function get_Ec(WorldPoint)
	local Ec={0,0,0}
	for i=1,n do
		Ec=vec.add(Ec,vec.mulNum(vec.normalize(vec.sub(WorldPoint,objectPosition[i])),objectCharge[i]))
	end
	return vec.dot(Ec,dir)
end

local function new_object(charge,position)
	if n<maxObjects then
		n=n+1
		if options.linearConstraint then
			objectPosition[n]=vec.add(pos,vec.mulNum(dir,vec.dot(dir,vec.sub(position,pos))))
		else
			objectPosition[n]=position
		end
		objectCharge[n]=charge
		redraw[4]=true
	end
end

local window=ui.connect(ctrl.newWindow(ScreenOffset[1],ScreenOffset[2],ScreenView[1],ScreenView[2]))

function window:draw()
	local show=options.show_layers
	if show[4] and redraw[4] then
		layers[4]:clear()
		setBlendMode'alpha'
		setShader()
		setCanvas(layers[4])
		local auto_maxPotential=options.auto_maxPotential
		local new_maxPotential=0
		for i=1,n do
			local ScreenPoint=toScreen(objectPosition[i])
			draw(objectCharge[i]<0 and NegativeCharge or PositiveCharge,ScreenOffset[1]+ScreenPoint[1],h-(ScreenOffset[2]+ScreenPoint[2]),0,2*options.pointChargeRadius*ScreenView[1]/(WorldView[1]*options.pointChargeTextureSize[1]),2*options.pointChargeRadius*ScreenView[2]/(WorldView[2]*options.pointChargeTextureSize[2]),options.pointChargeTextureSize[1]/2,options.pointChargeTextureSize[2]/2)
			if auto_maxPotential then
				new_maxPotential=max(new_maxPotential,abs(objectCharge[i]))
			end
		end
		if auto_maxPotential then
			potentialGenerator:send("maxPotential",new_maxPotential/options.pointChargeRadius)
		end
	end
	if (show[1] or show[2] or show[3]) and (redraw[1] or redraw[2] or redraw[3] or redraw[4]) then
		potentialGenerator:sendInt("n",n)
		if n>0 then
			potentialGenerator:send("objectPosition",unpack(objectPosition))
			potentialGenerator:send("objectCharge",unpack(objectCharge))
		end
		potentialGenerator:send("WorldOffset",WorldOffset)
		potentialGenerator:send("WorldView",WorldView)
		local drawing_layers={}
		for l=1,3 do
			if show[l] then
				drawing_layers[#drawing_layers+1]=layers[l]
			end
		end
		potentialGenerator:send("enabled_canvases",unpack(show,1,3))
		setBlendMode'replace'
		setShader(potentialGenerator)
		setCanvas(unpack(drawing_layers))
		rect("fill",0,0,ScreenView[1],ScreenView[2])
	end

	setCanvas()
	setShader()
	for l=1,#layers do
		if show[l] then
			setBlendMode(layer_blendMode[l])
			draw(layers[l],ScreenOffset[1],ScreenOffset[2])
		end
		redraw[l]=false
	end


	setBlendMode'alpha'
	setShader()
	setColor(0,0,0,128)
	rect("fill",0,0,200,20)
	setColor(255,255,255,255)
	local text={}
	for i=1,#show do
		if show[i] then
			text[#text+1]=i
		end
	end
	love.graphics.print(table.concat(text,", "),0,0)
end


function window:update(dt)
	local new_mouseScreenPos={getX(),h-getY()}
	local new_mouseWorldPos=toWorld(new_mouseScreenPos)

	if new_mouseScreenPos[1]~=mouseScreenPos[1] or new_mouseScreenPos[2]~=mouseScreenPos[2] then
		mouseScreenPos=new_mouseScreenPos
	end

	if new_mouseWorldPos[1]~=mouseWorldPos[1] or new_mouseWorldPos[2]~=mouseWorldPos[2] then
		mouseWorldPos=new_mouseWorldPos
		if isBtn'l' then
			if objectDrag then
				local new_position=vec.add(mouseWorldPos,objectDrag)
				if options.linearConstraint then
					if n==2 then
						objectPosition[mouseTarget]=new_position
						pos=objectPosition[1]
						dir=vec.normalize(vec.sub(objectPosition[2],pos))
						potentialGenerator:send("dir",dir)
					else
						objectPosition[mouseTarget]=vec.add(pos,vec.mulNum(dir,vec.dot(dir,vec.sub(new_position,pos))))
					end
				else
					objectPosition[mouseTarget]=new_position
				end
				redraw[4]=true
			elseif isKey'lshift' then
				options.equipotentialModulo=abs(options.equipotential-get_Ep(mouseWorldPos,true))
				potentialGenerator:send("equipotentialModulo",options.equipotentialModulo)
				redraw[2]=true
			elseif isKey'rshift' then
				options.cteModulo=abs(options.cte-get_Ec(mouseWorldPos))
				potentialGenerator:send("cteModulo",options.cteModulo)
				redraw[3]=true
			else
				options.equipotential=get_Ep(mouseWorldPos,true)
				potentialGenerator:send("equipotential",options.equipotential)
				redraw[2]=true

				options.cte=get_Ec(mouseWorldPos)
				potentialGenerator:send("cte",options.cte)
				redraw[3]=true
			end
		end

		if isBtn'r' then
			if WorldDrag then
				WorldOffset=vec.add(WorldOffset,vec.sub(WorldDrag,mouseWorldPos))
				redraw[4]=true
			end
		end

		redraw[4]=true
	end

	if options.animationSpeed~=0 then
		potentialGenerator:send("t",tick())
		redraw[2]=true
		redraw[3]=true
	end
end

function window:mousepressed(b)
	if b=="l" then
		if not (isKey'lshift' or isKey'rshift') then
			local rsq=options.pointChargeRadius*options.pointChargeRadius
			local blank=true
			for i=n,1,-1 do
				local d=vec.sub(objectPosition[i],mouseWorldPos)
				if vec.dot(d,d)<=rsq then
					mouseTarget=i
					objectDrag=d
					blank=false
					break
				end
			end
			if blank then
				options.equipotential=get_Ep(mouseWorldPos,true)
				potentialGenerator:send("equipotential",options.equipotential)
				redraw[2]=true

				options.cte=get_Ec(mouseWorldPos)
				potentialGenerator:send("cte",options.cte)
				redraw[3]=true
			end
		end
	elseif b=="r" then
		WorldDrag=mouseWorldPos
	end
end

function window:MouseWheelForward()
	WorldOffset=vec.add(WorldOffset,vec.mulNum(vec.sub(WorldOffset,mouseWorldPos),1/options.ZoomStep-1))
	WorldView[1]=WorldView[1]/options.ZoomStep
	WorldView[2]=WorldView[2]/options.ZoomStep
	redraw[4]=true
end
function window:MouseWheelBackward()
	WorldOffset=vec.add(WorldOffset,vec.mulNum(vec.sub(WorldOffset,mouseWorldPos),options.ZoomStep-1))
	WorldView[1]=WorldView[1]*options.ZoomStep
	WorldView[2]=WorldView[2]*options.ZoomStep
	redraw[4]=true
end

function window:mousereleased(b)
	if b=="l" then
		if objectDrag then
			objectDrag=nil
		end
	elseif b=="r" then
		if WorldDrag then
			WorldDrag=nil
		end
	end
end

function window:keypressed(k)
	if k=="m" then
		new_object(1,mouseWorldPos)
	elseif k=="n" then
		new_object(-1,mouseWorldPos)
	elseif k=="delete" then
		local rsq=options.pointChargeRadius*options.pointChargeRadius
		for i=n,1,-1 do
			local d=vec.sub(objectPosition[i],mouseWorldPos)
			if vec.dot(d,d)<=rsq then
				remove(objectPosition,i)
				remove(objectCharge,i)
				n=n-1
				redraw[4]=true
				break
			end
		end
	elseif k=="z" then
		options.equipotential=0
		options.animationSpeed=0
		potentialGenerator:send("animationSpeed",options.animationSpeed)
		potentialGenerator:send("equipotential",0)
		redraw[2]=true
	elseif k=="a" then
		options.animationSpeed=0.5
		potentialGenerator:send("animationSpeed",options.animationSpeed)
		redraw[2]=true
	elseif k=="kp+" then
		options.animationSpeed=options.animationSpeed*options.ZoomStep
		potentialGenerator:send("animationSpeed",options.animationSpeed)
	elseif k=="kp-" then
		options.animationSpeed=options.animationSpeed/options.ZoomStep
		potentialGenerator:send("animationSpeed",options.animationSpeed)
	elseif k=="f" then
		options.draw_equipotentialModulo=not options.draw_equipotentialModulo
		potentialGenerator:send("draw_equipotentialModulo",options.draw_equipotentialModulo)
		redraw[2]=true
	elseif k=="g" then
		options.draw_fieldModulo=not options.draw_fieldModulo
		potentialGenerator:send("draw_fieldModulo",options.draw_fieldModulo)
		redraw[3]=true
	elseif k=="l" then
		options.linearConstraint=not options.linearConstraint
		if options.linearConstraint then
			if n==2 then
				pos=objectPosition[1]
				dir=vec.normalize(vec.sub(objectPosition[2],pos))
				redraw[3]=true
			else
				local avg={0,0,0}
				for i=1,n do
					avg=vec.add(avg,objectPosition[i])
				end
				pos=vec.divNum(avg,n)
				for i=1,n do
					objectPosition[i]=vec.add(pos,vec.mulNum(dir,vec.dot(dir,vec.sub(objectPosition[i],pos))))
				end
				redraw[4]=true
			end
		end
	elseif k=="1" then
		options.show_layers[1]=not options.show_layers[1]
		redraw[1]=true
	elseif k=="2" then
		options.show_layers[2]=not options.show_layers[2]
		redraw[2]=true
	elseif k=="3" then
		options.show_layers[3]=not options.show_layers[3]
		redraw[3]=true
	elseif k=="4" then
		options.show_layers[4]=not options.show_layers[4]
		redraw[4]=true
--[[
	elseif k=="5" then
		options.show_layers[5]=not options.show_layers[5]
		redraw[5]=true
	elseif k=="6" then
		options.show_layers[6]=not options.show_layers[6]
		redraw[6]=true
--]]
	end
end

--UIs
local settingsFrame=ui.new(ui.ROOT)
settingsFrame.Pos=ui.SO(0,0,0,0)
settingsFrame.Size=ui.SO(0,1,200,0)

local settingsScroll=ui.new()

local scroll=ui.scroll(settingsScroll,settingsFrame)

window.update=scroll.update

function love.resize(x,y)
	h=y
	WorldView[1]=x/y*WorldView[2]
	ScreenView={x,y}
	window.View[2][1],window.View[2][2]=x,y
	potentialGenerator:send("WorldView",WorldView)
	potentialGenerator:send("ScreenView",ScreenView)
	layers[1]=newCanvas(x,y,"hdr")
	layers[2]=newCanvas(x,y,"hdr")
	layers[3]=newCanvas(x,y,"hdr")
	layers[4]=newCanvas(x,y,"hdr")
	redraw={true,true,true,true}
end

local event=love.event
local pump=event.pump
local poll=event.poll

local handlers=love.handlers

local step=love.timer.step
local sleep=love.timer.sleep
local getDelta=love.timer.getDelta

local isCreated=love.window.isCreated

local clear=love.graphics.clear
local present=love.graphics.present

function love.run()
    while true do
		pump()
		for e,a,b,c,d in poll() do
			if e=="quit" then
				if not (love.quit and love.quit()) then
					if love.audio then
						love.audio.stop()
					end
					return
				end
			end
			handlers[e](a,b,c,d)
		end

		step()
        love.update(getDelta())

		local any=false
		for l=1,#redraw do
			if redraw[l] then
				any=true
				break
			end
		end
        if any and isCreated() then
			setCanvas()
            clear()
            love.draw()
            present()
        end

        sleep(0.001)
    end
end
