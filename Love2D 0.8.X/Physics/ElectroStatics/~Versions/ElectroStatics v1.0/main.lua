--By xXxMoNkEyMaNxXx

local tau=2*math.pi
local sin,cos=math.sin,math.cos
local min=math.min
local sqrt=math.sqrt
local ceil=math.ceil
local floor=math.floor
local r=math.random
local sign=function(x)
	if x>0 then
		return 1
	end
	if x<0 then
		return -1
	end
	return 0
end

local insert=table.insert
local remove=table.remove

local create=coroutine.create
local start=coroutine.resume
local pause=coroutine.yield
local status=coroutine.status

local tick=love.timer.getMicroTime
local sleep=love.timer.sleep

local View={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}
local Window={{0,0},{0.2,0.2}}--1m x 1m

local thumbView={{10,10},{125,75}}
local thumbWindow={{0,0},{0.25,0.25}}

require'vec'

local neu=love.graphics.newImage'None.png'
local pos=love.graphics.newImage'Plus.png'
local neg=love.graphics.newImage'Minus.png'

local maxParticles=100
local k=9e9
local me=9.10938291e-31
local C=1.602176487e-19
local particles={
	num=1,
	mass={0.01},
	positions={{0,0}},
	velocities={{0,0}},
	charges={1e-6},
}
local options={
	help=true,
	field=true,
	lines=10,
	potential=true,
	partSize=0.01,--1cm
	texSize={100,100},--texture size
	arrowsEnabled=true,
	arrowSpacing=95,-- ~95 iterations per arrow
	accuracy=1000,
	simulation=false,
	simSpeed=0.001,
}

local refresh=false
local totalRenderTime=0
local totalFramesRendered=0
local totalProcessTime=0
local totalFramesProcessed=0

---[[
local S=love.graphics.newPixelEffect(love.filesystem.read'shader.frag')
S:send("PlusColour",{1,0,0,1})
S:send("MinusColour",{0,0,1,1})
S:send("h",love.graphics.getHeight())
S:send("View",View)
S:send("Window",Window)
S:send("k",9e9)
S:send("particleRadius",options.partSize)
S:send("pnum",particles.num)
S:send("positions",unpack(particles.positions,1,particles.num))
S:send("charges",unpack(particles.charges,1,particles.num))
--]]

local function getParticle(w)
	for n=1,particles.num do
		local diff=vec.sub(particles.positions[n],w)
		if vec.length(diff)<=options.partSize then
			return n
		end
	end
end

local hk={
	{
		Title="Reset view",
		Key="q",
		Action=function()
			Window={{0,0},{1,1}}
			S:send("Window",Window)
		end
	},
	{
		Title="Set thumbnail view",
		Key="return",
		Action=function()
			thumbWindow={{Window[1][1],Window[1][2]},{Window[2][1],Window[2][2]}}
		end
	},
	{
		Title="Toggle potential",
		Key="w",
		Action=function()
			options.potential=not options.potential
		end
	},
	{
		Title="Toggle lines",
		Key="e",
		Action=function()
			options.field=not options.field
		end
	},
	{
		Title="Toggle arrows",
		Key="a",
		Action=function()
			options.arrowsEnabled=not options.arrowsEnabled
		end
	},
	{
		Title="Toggle simulation",
		Key="s",
		Action=function()
			options.simulation=not options.simulation
		end
	},
	{
		Title="More field lines",
		Key="d",
		Action=function()
			options.lines=options.lines+1
		end
	},
	{
		Title="Less field lines",
		Key="c",
		Action=function()
			options.lines=options.lines-1
		end
	},
	{
		Title="Add positive particle",
		Key="m",
		Action=function(w)
			local n1=particles.num+1
			if n1<=maxParticles then
				particles.positions[n1]=w
				particles.velocities[n1]={0,0}
				particles.charges[n1]=1e-6
				particles.mass[n1]=0.01
				particles.num=n1
				---[[
				S:send("pnum",n1)
				S:send("positions["..(n1-1).."]",particles.positions[n1])
				S:send("charges["..(n1-1).."]",particles.charges[n1])
				--]]
			end
		end
	},
	{
		Title="Add negative particle",
		Key="n",
		Action=function(w)
			local n1=particles.num+1
			if n1<=maxParticles then
				particles.positions[n1]=w
				particles.velocities[n1]={0.002*r()-0.001,0.002*r()-0.001}
				particles.charges[n1]=-1e-6
				particles.mass[n1]=0.01
				particles.num=n1
				---[[
				S:send("pnum",n1)
				S:send("positions["..(n1-1).."]",particles.positions[n1])
				S:send("charges["..(n1-1).."]",particles.charges[n1])
				--]]
			end
		end
	},
	{
		Title="Add to charge of particle under mouse",
		Key="j"
	},
	{
		Title="Sub from charge of particle under mouse",
		Key="h"
	},
	{
		Title="Delete particle under mouse",
		Key="delete",
		Action=function(w)
			local n=getParticle(w)
			if n then
				local n1=particles.num-1
				for n2=n,n1 do
					particles.positions[n2]=particles.positions[n2+1]
					particles.velocities[n2]=particles.velocities[n2+1]
					particles.charges[n2]=particles.charges[n2+1]
					particles.mass[n2]=particles.mass[n2+1]
				end
				particles.num=n1
				S:send("pnum",n1)
				if n1>0 then
					S:send("positions",unpack(particles.positions,1,particles.num))
					S:send("charges",unpack(particles.charges,1,particles.num))
				end
			end
		end
	},
	{
		Title="Toggle hotkey reference",
		Key="tab",
		Action=function()
			options.help=not options.help
		end
	},
	{
		Title="Refresh lines  [Space]->",
		Key=" ",
		Action=function()
			refresh=true
		end
	},
	{
		Title="Clear all particles",
		Key="backspace",
		Action=function()
			particles.num=0
			S:send("pnum",0)
		end
	},
	{
		Title="Quit",
		Key="escape",
		Action=function()
			print(totalFramesRendered/totalRenderTime.." renders/s")
			print(totalFramesProcessed/totalProcessTime.." frames processed/s")
			love.event.quit()
		end
	},
}

local dt=0.0025
local iterations=1000
local lines={}

local turn=1
local threads=10
local renderQueue={}
local renderedLines={}
local renderer={}

local vadd=vec.add
local vsub=vec.sub
local vdot=vec.dot
local vlen=vec.length
local vmul=vec.mulNum
local vdiv=vec.divNum
local function lineRenderer(id)
	repeat
		while #renderQueue>0 do
			--print'Processing data ...'
			if turn==id then
				local q=remove(renderQueue,min(#renderQueue,particles.num))--If the queue is overwhelmed (somehow), do recent requests first.
				turn=turn%threads+1

				local qlines={}
				local qc=sign(particles.charges[q.n])
				local lmul=0.5+0.5*qc
				for pn=1,#q.points do
					local finish
					local pos=q.points[pn]
					local line={pos}
					for i=1,iterations do
						local a={0,0}
						for n=1,particles.num do
							local diff=vsub(pos,particles.positions[n])--Move away from same charge
							local dis=vlen(diff)
							local charge=particles.charges[n]
							if charge~=0 then
								a=vadd(a,vmul(vdiv(diff,dis),qc*k*charge/vdot(diff,diff)))
								local sc=sign(charge)
								if dis<options.partSize and sc==-qc then
									finish=sc--This should really help things along.
								end
							end
						end
						pos=vadd(pos,vmul(vdiv(a,vlen(a)),dt))
						insert(line,lmul*#line+1,pos)
						if finish then
							break
						end
						--[[Doesn't seem to reduce lag :/
						if i%100==0 then
							sleep(0.001)
						end
						--]]
					end
					if not(finish==1 and qc==-1) then
						qlines[#qlines+1]=line
					end
				end

				--print'Complete!'
				renderedLines[#renderedLines+1]={n=q.n,stamp0=q.stamp,stamp1=tick(),lines=qlines}
			else
				sleep(0.001)
			end
		end
		pause()
	until nil
end

for id=1,threads do
	local co=create(lineRenderer)
	renderer[id]=co
	local ran,err=start(co,id)
	if not ran then
		print(err)
	end
end

local function requestLines(particle)
	--print("! data requested for particle "..particle)
	local data={n=particle,stamp=tick(),points={}}
	if options.field then
		for d=1,options.lines do
			local angle=tau*d/options.lines
			data.points[#data.points+1]=vec.add(particles.positions[particle],vec.mulNum({cos(angle),sin(angle)},options.partSize))
		end
	end
	local nq=#renderQueue
	insert(renderQueue,1,data)
	if nq==0 then
		if status(renderer[turn])=="suspended" then
			local ran,err=start(renderer[turn])
			if not ran then
				print(err)
			end
		end
	else
		for i=#renderQueue,1,-1 do
			if renderQueue[i].n==particle and renderQueue[i].stamp<data.stamp then
				remove(renderQueue,i)
			end
		end
	end
end

local draw=love.graphics.draw
local line=love.graphics.line
local poly=love.graphics.polygon
local rect=love.graphics.rectangle
local setColour=love.graphics.setColor
local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect
local lprint=love.graphics.print

local fps=love.timer.getFPS
local setCaption=love.graphics.setCaption

local frame=1
local frequent=7

local function show(screen,world,enable)
	S:send("View",screen)
	S:send("Window",world)
	setColour(0,0,0,128)
	rect("line",screen[1][1]-1,screen[1][2]-1,screen[2][1]+2,screen[2][2]+2)
	setColour(255,255,255,255)

	if enable then
		setEffect(S)
	end
	rect("fill",screen[1][1],screen[1][2],screen[2][1],screen[2][2])
	if enable then
		setEffect()
	end
end

function love.draw()
	if particles.num>0 then
		frame=frame%(particles.num*frequent)+1
	end
	show(View,Window,options.potential)
	local ar=vec.div(View[2],Window[2])
	for n=1,particles.num do
		local p=particles.positions[n]
		local pixelRadius=options.partSize*ar[2]
		local screenPos=vec.add(View[1],vec.add(vec.mulNum(vec.div(vec.sub(p,Window[1]),Window[2]),View[2][2]),vec.divNum(View[2],2)))
		if options.field and lines[n] and particles.charges[n]~=0 then
			local linesPos=vec.add(View[1],vec.add(vec.mulNum(vec.div(vec.sub(lines[n].worldPos,Window[1]),Window[2]),View[2][2]),vec.divNum(View[2],2)))
			draw(lines[n].raster,linesPos[1],linesPos[2],0,lines[n].worldSize[1]*ar[1]/lines[n].rasterSize[1],lines[n].worldSize[2]*ar[2]/lines[n].rasterSize[2],lines[n].rasterSize[1]/2,lines[n].rasterSize[2]/2)
		end
		if screenPos[1]>=View[1][1]-pixelRadius and screenPos[2]>=View[1][2]-pixelRadius and screenPos[1]<=View[1][1]+View[2][1]+pixelRadius and screenPos[2]<=View[1][2]+View[2][2]+pixelRadius then
			--Particle is visible
			draw(particles.charges[n]>0 and pos or particles.charges[n]<0 and neg or neu,screenPos[1]-pixelRadius,screenPos[2]-pixelRadius,0,2*pixelRadius/options.texSize[1],2*pixelRadius/options.texSize[2])
			if options.field and particles.charges[n]~=0 and (frame/frequent==n or refresh) then
				requestLines(n)
			end
		elseif options.field and refresh and particles.charges[n]~=0 then
			requestLines(n)
		elseif floor(frame/frequent)==n then
			frame=frame+frequent-frame%frequent
		end
	end
	if not options.help then
		show(thumbView,thumbWindow,true)
	end
	if options.help then
		setColour(0,255,0,192)
		for h=1,#hk do
			lprint(hk[h].Title.." ("..hk[h].Key:gsub("^%l",string.upper)..")",0,(h-1)*15)
		end
		lprint("Render queue: "..#renderQueue,View[1][1],View[1][2]+View[2][2]-40)
		lprint("Processing queue: "..#renderedLines,View[1][1],View[1][2]+View[2][2]-20)
		setColour(255,255,255,255)
	end
	refresh=false
	setCaption("Rhys Lloyd's ElectroStatic Simulator - "..fps().." FPS")
end

local function simStep(dt)
	local a={}
	for n=1,particles.num do
		a[n]={0,0}
	end
	for n1=1,particles.num do
		for n2=n1+1,particles.num do
			local Q1=particles.charges[n1]
			local Q2=particles.charges[n2]
			if Q1<0 or Q2<0 then--ONLY ELECTRONS MOVE :)
				local diff=vsub(particles.positions[n2],particles.positions[n1])
				local dis=vlen(diff)
				if dis>0 then--just in case...
					local F_E=k*Q1*Q2/vdot(diff,diff)
					local dnorm=vdiv(diff,dis)
					if Q1<0 then
						a[n1]=vsub(a[n1],vmul(dnorm,F_E))--Opposite direction
					end
					if Q2<0 then
						a[n2]=vadd(a[n2],vmul(dnorm,F_E))--F_net=sum(Forces)
					end
				end
			end
		end
	end
	for n=1,particles.num do
		if particles.charges[n]<0 then
			local newPos=vadd(particles.positions[n],vmul(particles.velocities[n],dt))
			local newVel=vadd(particles.velocities[n],vmul(a[n],dt/particles.mass[n]))
			if newPos[1]-options.partSize<Window[1][1]-Window[2][1]/2 then
				newPos[1]=Window[1][1]-Window[2][1]/2+options.partSize-(newPos[1]-options.partSize-Window[1][1]+Window[2][1]/2)--%Window[2][1]
				newVel[1]=-newVel[1]*0.7
			end
			if newPos[2]-options.partSize<Window[1][2]-Window[2][2]/2 then
				newPos[2]=Window[1][2]-Window[2][2]/2+options.partSize-(newPos[2]-options.partSize-Window[1][2]+Window[2][2]/2)--%Window[2][2]
				newVel[2]=-newVel[2]*0.7
			end
			if newPos[1]+options.partSize>Window[1][1]+Window[2][1]/2 then
				newPos[1]=Window[1][1]+Window[2][1]/2-options.partSize-(newPos[1]+options.partSize-Window[1][1]-Window[2][1]/2)--%Window[2][1]
				newVel[1]=-newVel[1]*0.7
			end
			if newPos[2]+options.partSize>Window[1][2]+Window[2][2]/2 then
				newPos[2]=Window[1][2]+Window[2][2]/2-options.partSize-(newPos[2]+options.partSize-Window[1][2]-Window[2][2]/2)--%Window[2][2]
				newVel[2]=-newVel[2]*0.7
			end
			particles.positions[n]=newPos
			particles.velocities[n]=newVel
		end
	end
	S:send("positions",unpack(particles.positions,1,particles.num))
end

local r303=3^0.5/3

local lPart
local lDrag
local rDrag
local isBtn=love.mouse.isDown
local isKey=love.keyboard.isDown
local newCanvas=love.graphics.newCanvas
local getX,getY=love.mouse.getX,love.mouse.getY

function love.update(dt)
	if #renderedLines>0 then
		for _=1,ceil(sqrt(#renderedLines)) do
		local data=remove(renderedLines,1)
		totalFramesRendered=totalFramesRendered+1
		totalRenderTime=totalRenderTime+data.stamp1-data.stamp0
		local n=data.n
		if not lines[n] then
			lines[n]={raster=newCanvas()}
			lines[n].rasterSize={lines[n].raster:getWidth(),lines[n].raster:getHeight()}
		end
		local t0=tick()
		lines[n].raster:clear()
		lines[n].worldPos={Window[1][1],Window[1][2]}
		lines[n].worldSize={Window[2][1],Window[2][2]}
		setColour(0,0,0,255)
		setCanvas(lines[n].raster)
		local ar=View[2][2]/Window[2][2]
		for l=1,#data.lines do
			local points={}
			local lineL=data.lines[l]
			local arrz=#lineL/floor(#lineL/options.arrowSpacing+1)
			for i=1,#lineL do
				points[2*i-1],points[2*i]=unpack(vec.add(vec.mulNum(vsub(lineL[i],lines[n].worldPos),ar),vec.divNum(lines[n].rasterSize,2)))
				if options.arrowsEnabled and #points>10 and i==floor((floor(i/arrz)+0.5)*arrz+0.5) then
					local p1,p0={points[2*i-1],points[2*i]},{points[2*i-11],points[2*i-10]}
					local diff=vmul(vsub(p1,p0),r303)
					poly("fill",p0[1]-diff[2],p0[2]+diff[1],p1[1],p1[2],p0[1]+diff[2],p0[2]-diff[1])
				end
			end
			line(points)
		end
		setCanvas()
		setColour(255,255,255,255)
		local t1=tick()
		totalFramesProcessed=totalFramesProcessed+1
		totalProcessTime=totalProcessTime+t1-t0
		end
	end
	local m={getX()-View[1][1],getY()-View[1][2]}--View[2][2]-
	if isBtn'r' and rDrag then
		Window[1]=vec.sub(rDrag,vec.mul(Window[2],vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
	end
	local worldPos=vec.add(Window[1],vec.mul(Window[2],vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
	if isBtn'l' and lDrag and lPart then
		particles.positions[lPart]=vec.add(worldPos,lDrag)
		S:send("positions["..(lPart-1).."]",particles.positions[lPart])
		if particles.charges[lPart]~=0 then
			requestLines(lPart)
		end
	end
	if isKey'j' then
		local n=getParticle(worldPos)
		if n then
			particles.charges[n]=particles.charges[n]+1e-6*dt
			S:send("charges["..(n-1).."]",particles.charges[n])
		end
	end
	if isKey'h' then
		local n=getParticle(worldPos)
		if n then
			particles.charges[n]=particles.charges[n]-1e-6*dt
			S:send("charges["..(n-1).."]",particles.charges[n])
		end
	end
	if options.simulation and particles.num>0 then
		simStep(dt*options.simSpeed)
	end
end

function love.keypressed(k)
	local m={getX()-View[1][1],getY()-View[1][2]}--View[2][2]-
	local worldPos=vec.add(Window[1],vec.mul(Window[2],vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
	for h=1,#hk do
		if hk[h].Key==k and hk[h].Action then
			hk[h].Action(worldPos)
			break
		end
	end
end

local zoomStep=1.1
function love.mousepressed(x,y,btn)
	local m={x-View[1][1],y-View[1][2]}--View[2][2]-
	if btn=="l" then
		local worldPos=vec.add(Window[1],vec.mul(Window[2],vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
		for n=particles.num,1,-1 do
			local diff=vec.sub(particles.positions[n],worldPos)
			if vec.length(diff)<=options.partSize then
				lDrag=diff
				lPart=n
				break
			end
		end
	elseif btn=="r" then
		rDrag=vec.add(Window[1],vec.mul(Window[2],vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
	elseif btn=="wu" then
		local newWindowSize=vec.divNum(Window[2],zoomStep)
		Window[1]=vec.add(Window[1],vec.mul(vec.sub(Window[2],newWindowSize),vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
		Window[2]=newWindowSize
	elseif btn=="wd" then
		local newWindowSize=vec.mulNum(Window[2],zoomStep)
		Window[1]=vec.add(Window[1],vec.mul(vec.sub(Window[2],newWindowSize),vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
		Window[2]=newWindowSize
	end
end

function love.mousereleased(x,y,btn)
	local m={x-View[1][1],y-View[1][2]}--View[2][2]-
	if btn=="l" then
		if lDrag and lPart then
			local worldPos=vec.add(Window[1],vec.mul(Window[2],vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
			particles.positions[lPart]=vec.add(worldPos,lDrag)
			S:send("positions["..(lPart-1).."]",particles.positions[lPart])
			if particles.charges[lPart]>0 then
				requestLines(lPart)
			end
		end
		lDrag=nil
		lPart=nil
	elseif btn=="r" then
		Window[1]=vec.sub(rDrag,vec.mul(Window[2],vec.divNum(vec.sub(vec.sub(m,View[1]),vec.divNum(View[2],2)),View[2][2])))
		rDrag=nil
	end
end
