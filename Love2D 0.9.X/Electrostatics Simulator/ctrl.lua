--By xXxMoNkEyMaNxXx elsez
local next=next
local type=type
local rawset=rawset
local setmetatable=setmetatable

local max=math.max
local min=math.min

local sub=string.sub
local match=string.match

local insert=table.insert
local remove=table.remove


local vec=require'vec'

local isBtn=love.mouse.isDown
local isKey=love.keyboard.isDown
local getPos=love.mouse.getPosition

local rect=love.graphics.rectangle
local getColour=love.graphics.getColor
local setColour=love.graphics.setColor
local getScissor=love.graphics.getScissor
local setScissor=love.graphics.setScissor

local function clone(t,recursive)
	local new={}
	for i,v in next,t do
		if type(v)=="table" and recursive then
			new[i]=clone(v,recursive)
		else
			new[i]=v
		end
	end
	return new
end

local function Order(id,z)
	z=z or 1
	if z<id then
		local w=ctrl.Windows[id]
		if w then
			w.ZIndex=z
			for i=id-1,z,-1 do
				local wi=ctrl.Windows[i]
				wi.ZIndex=i+1
				ctrl.Windows[i+1]=wi
			end
			ctrl.Windows[z]=w
		end
	elseif z>id then
		local w=ctrl.Windows[id]
		if w then
			w.ZIndex=z
			for i=id+1,z do
				local wi=ctrl.Windows[i]
				wi.ZIndex=i-1
				ctrl.Windows[i-1]=wi
			end
			ctrl.Windows[z]=w
		end
	end
end

local ctrl={
	Windows={},
	m={getPos()},
	Order=Order,
}
ctrl.DestroyWindow=function(w)
	if w.ZIndex>=1 then
		local n=#ctrl.Windows
		for i=w.ZIndex,n-1 do
			local wi=ctrl.Windows[i+1]
			wi.ZIndex=i
			ctrl.Windows[i]=wi
		end
		ctrl.Windows[n]=nil
		w.ZIndex=0
		if ctrl.MFocus==w then
			ctrl.MFocus=nil
		end
		if ctrl.KFocus==w then
			ctrl.KFocus=nil
		end
	end
end

ctrl.Default={--Default Settings
	View={{100,100},{320,240}},--Area of the screen that the window will take up.
	Control={},--Use the form [MK][UDS]constant for the value, E.g. MDr is activated when the right mouse button goes down
	Event={},--Functions fired when a control with the same index is activated.
	Colour={255,255,255,255},--Last colour set by the window's draw function.
	--Read Only--
	m={0,0},--Position of mouse in window
	Btn={},--States of each mouse constant
	Key={},--States of each keyboard constant
	Keys=0,--How many keys are down
	Btns=0,--How many mouse buttons are down
	-------------
	--Don't touch--
	cb={},
	cbf={},
	---------------
	BringToFront=function(self)
		Order(self.ZIndex,1)
	end,
	SendToBack=function(self)
		Order(self.ZIndex,#ctrl.Windows)
	end,
	Destroy=ctrl.DestroyWindow,--Removes the window from the drawing list (not from memory)
	unhook=function(self,event,f)--used to disconnect functions like update from firing.
		local cb=self.cb
		if cb then
			for e,c in next,cb do
				if e==event and c then
					local shift=false
					for i=1,#c do
						if c[i]==f then
							shift=true
						elseif shift then
							c[i-1]=c[i]
						end
					end
					break
				end
			end
		end
	end,
	Visible=true,
	ZIndex=1,
}

local function ncbf(cbName)
	return function(self,...)
		local cb=self.cb
		if cb then
			local cbi=cb[cbName]
			if cbi then
				local ncb=#cbi
				if ncb>0 then
					for i=ncb,1,-1 do
						cbi[i](self,...)
					end
				end
			end
		end
	end
end

ctrl.metatable={
	__index=function(self,i)
		local cbf=self.cbf
		if cbf then
			local cbfi=cbf[i]
			if cbfi then
				return cbfi
			end
		end
	end,
	__newindex=function(self,i,v)--A bit over cautious considering I labeled cb and cbf "Don't touch"...
		if (i=="draw" or i=="update" or i=="mousepressed" or i=="mousereleased" or i=="keypressed" or i=="keyreleased") and type(v)=="function" then
			local cb=self.cb
			if cb then
				local cbi=cb[i]
				if cbi then
					cbi[#cbi+1]=v
				else
					cb[i]={v}
				end
			else
				self.cb={[i]={v}}
			end
			local cbf=self.cbf
			if cbf then
				if not cbf[i] then
					cbf[i]=ncbf(i)
				end
			else
				self.cbf={[i]=ncbf(i)}
			end
		else
			rawset(self,i,v)
		end
	end,
}

function ctrl.newWindow(Ox,Oy,Sx,Sy)
	local w=setmetatable(clone(ctrl.Default,true),ctrl.metatable)
	w.View={{Ox or ctrl.Default.View[1][1],Oy or ctrl.Default.View[1][2]},{Sx or ctrl.Default.View[2][1],Sy or ctrl.Default.View[2][2]}}
	for i=#ctrl.Windows+1,2,-1 do
		local w=ctrl.Windows[i-1]
		ctrl.Windows[i]=w
		w.ZIndex=i
	end
	ctrl.Windows[1]=w
	return w
end

function ctrl.viewDrag(window)
	window.Control.ViewDragInit="MDl"
	window.Control.ViewDragMove="MSmove"
	window.Control.ViewDragStop="MUl"
	window.Event.ViewDragInit=function(self)
		self.ViewDragOffset=vec.sub(self.View[1],ctrl.m)
	end
	window.Event.ViewDragMove=function(self)
		if self.ViewDragOffset then
			self.View[1]=vec.add(ctrl.m,self.ViewDragOffset)
		end
	end
	window.Event.ViewDragStop=function(self)
		if self.ViewDragOffset then
			self.View[1]=vec.add(ctrl.m,self.ViewDragOffset)
			self.ViewDragOffset=nil
		end
	end
end

function ctrl.worldDrag(window)
	window.Window={{0,0},{20,20}}--View of world
	window.ZoomStep=1.1--World magnification per Zoom
	window.Control.WorldDragInit="MDr"--Mouse_Down_Right
	window.Control.WorldDragMove="MSmove"--Mouse_Special_Move
	window.Control.WorldDragStop="MUr"--Mouse_Up_Right
	window.Control.WorldZoomIn="MSwu"--Mouse_Special_WheelUp
	window.Control.WorldZoomOut="MSwd"--Mouse_Special_WheelDown
	window.Event.WorldDragInit=function(self)
		self.WorldDragOffset=vec.add(self.Window[1],vec.mul(self.Window[2],vec.divNum(vec.sub(self.m,vec.divNum(self.View[2],2)),self.View[2][2])))
	end
	window.Event.WorldDragMove=function(self)
		if self.WorldDragOffset then
			self.Window[1]=vec.sub(self.WorldDragOffset,vec.mul(self.Window[2],vec.divNum(vec.sub(self.m,vec.divNum(self.View[2],2)),self.View[2][2])))
		end
	end
	window.Event.WorldDragStop=function(self)
		if self.WorldDragOffset then
			self.Window[1]=vec.sub(self.WorldDragOffset,vec.mul(self.Window[2],vec.divNum(vec.sub(self.m,vec.divNum(self.View[2],2)),self.View[2][2])))
			self.WorldDragOffset=nil
		end
	end
	window.Event.WorldZoomIn=function(self)
		local newWindowSize=vec.divNum(self.Window[2],self.ZoomStep)
		self.Window[1]=vec.add(self.Window[1],vec.mul(vec.sub(self.Window[2],newWindowSize),vec.divNum(vec.sub(self.m,vec.divNum(self.View[2],2)),self.View[2][2])))
		self.Window[2]=newWindowSize
	end
	window.Event.WorldZoomOut=function(self)
		local newWindowSize=vec.mulNum(self.Window[2],self.ZoomStep)
		self.Window[1]=vec.add(self.Window[1],vec.mul(vec.sub(self.Window[2],newWindowSize),vec.divNum(vec.sub(self.m,vec.divNum(self.View[2],2)),self.View[2][2])))
		self.Window[2]=newWindowSize
	end
	window.toWorld=function(self,screenPos)
		return vec.add(self.Window[1],vec.mul(self.Window[2],vec.divNum(vec.sub(screenPos,vec.divNum(self.View[2],2)),self.View[2][2])))
	end
	window.toScreen=function(self,worldPos)
		return vec.add(vec.mulNum(vec.div(vec.sub(worldPos,self.Window[1]),self.Window[2]),self.View[2][2]),vec.divNum(self.View[2],2))
	end
	window.toWorldArea=function(self,screenArea)
		return {vec.add(self.Window[1],vec.mul(self.Window[2],vec.divNum(vec.sub(screenArea[1],vec.divNum(self.View[2],2)),self.View[2][2]))),vec.mul(vec.divNum(screenArea[2],self.View[2][2]),self.Window[2])}
	end
	window.toScreenArea=function(self,worldArea)
		return {vec.add(vec.mulNum(vec.div(vec.sub(worldArea[1],self.Window[1]),self.Window[2]),self.View[2][2]),vec.divNum(self.View[2],2)),vec.mulNum(vec.div(worldArea[2],self.Window[2]),self.View[2][2])}
	end
end

local function Input(device,edgeName,constant,...)
	local control=device..edgeName..constant
	local isEdge=device and edgeName=="D" or edgeName=="U" and constant
	if device=="M" and ctrl.MFocus then
		local w=ctrl.MFocus
		local we=w.Event
		w.m=vec.sub(ctrl.m,w.View[1])
		if isEdge then
			local edge=edgeName=="D"
			w.Btn[constant]=edge or nil
			if edge then
				w.Btns=w.Btns+1
			else
				w.Btns=max(0,w.Btns-1)
				if w.Btns==0 then
					ctrl.MFocus=nil
				end
			end
		end
		for e,c in next,w.Control do
			local iscontrol=c==control
			if type(c)=="table" then
				for ci=1,#c do
					if c[ci]==control then
						iscontrol=true
						break
					end
				end
			end
			if iscontrol then
				if e=="_BringToFront" then
					Order(w.ZIndex,1)
				elseif e=="_SendToBack" then
					Order(w.ZIndex,#ctrl.Windows)
				else
					local f=we[e]
					if f then
						f(w,...)
					end
				end
			end
		end
		if edgeName=="D" and w.mousepressed then
			w.mousepressed(w,constant,...)
		elseif edgeName=="U" and w.mousereleased then
			w.mousereleased(w,constant,...)
		end
	elseif device=="K" and ctrl.KFocus then
		local w=ctrl.KFocus
		local we=w.Event
		w.m=vec.sub(ctrl.m,w.View[1])
		if isEdge then
			local edge=edgeName=="D"
			w.Key[constant]=edge or nil
			if edge then
				w.Keys=w.Keys+1
			else
				w.Keys=max(0,w.Keys-1)
				if w.Keys==0 and not w.HasKFocus then--window.HasKFocus will mean that the window requested keyfocus (perhaps for a textbox.)
					ctrl.KFocus=nil
				end
			end
		end
		for e,c in next,w.Control do
			local iscontrol=c==control
			if type(c)=="table" then
				for ci=1,#c do
					if c[ci]==control then
						iscontrol=true
						break
					end
				end
			end
			if iscontrol then
				if e=="_BringToFront" then
					Order(w.ZIndex,1)
				elseif e=="_SendToBack" then
					Order(w.ZIndex,#ctrl.Windows)
				else
					local f=we[e]
					if f then
						f(w,...)
					end
				end
			end
		end
		if edgeName=="D" and w.keypressed then
			w.keypressed(w,constant,...)
		elseif edgeName=="U" and w.keyreleased then
			w.keyreleased(w,constant,...)
		end
	else
		local wcopy=clone(ctrl.Windows)
		for i=1,#wcopy do
			local w=wcopy[i]
			local we=w.Event
			w.m=vec.sub(ctrl.m,w.View[1])
			if we and (w.m[1]>=0 and w.m[2]>=0 and w.m[1]<=w.View[2][1] and w.m[2]<=w.View[2][2]) then
				local invoked=false
				local continue=true
				if isEdge then
					local edge=edgeName=="D"
					if device=="M" then
						w.Btn[constant]=edge or nil
						if edge then
							if w.Btns==0 and not ctrl.MFocus then
								ctrl.MFocus=w
								if ctrl.KFocus and ctrl.KFocus~=w then
									local states={}
									for c,state in next,ctrl.KFocus.Key do
										if state then
											Input("K","U",c)
											states[#states+1]=c
										end
									end
									ctrl.KFocus=w
									for i=1,#states do
										Input("K","D",states[i])
									end
								end
							end
							w.Btns=w.Btns+1
						else
							w.Btns=max(0,w.Btns-1)
							if w.Btns==0 and ctrl.MFocus==w then
								ctrl.MFocus=nil
							end
						end
					elseif device=="K" then
						w.Key[constant]=edge or nil
						if edge then
							if w.Keys==0 and not ctrl.KFocus then
								ctrl.KFocus=w
							end
							w.Keys=w.Keys+1
						else
							w.Keys=max(0,w.Keys-1)
							if w.Keys==0 and ctrl.KFocus==w and not w.HasKFocus then
								ctrl.KFocus=nil
							end
						end
					end
				end
				for e,c in next,w.Control do
					local isControl=c==control
					if type(c)=="table" then
						for ci=1,#c do
							if c[ci]==control then
								isControl=true
								break
							end
						end
					end
					if isControl then
						if e=="_BringToFront" then
							Order(w.ZIndex,1)
						elseif e=="_SendToBack" then
							Order(w.ZIndex,#ctrl.Windows)
						else
							local f=we[e]
							if f then
								continue=f(w,...) and continue--Return true to pass event through window. (rounded corner or something)
								invoked=true
							end
						end
					end
				end
				if device=="K" then
					if edgeName=="D" and w.keypressed then
						continue=w.keypressed(w,constant,...) and continue
						invoked=true
					elseif edgeName=="U" and w.keyreleased then
						continue=w.keyreleased(w,constant,...) and continue
						invoked=true
					end
				elseif device=="M" then
					if edgeName=="D" and w.mousepressed then
						continue=w.mousepressed(w,constant,...) and continue
						invoked=true
					elseif edgeName=="U" and w.mousereleased then
						continue=w.mousereleased(w,constant,...) and continue
						invoked=true
					end
				end
				if not (invoked and continue) then
					break
				end
			end
		end
	end
end

local function uMouse(p)
	if p[1]==ctrl.m[1] and p[2]==ctrl.m[2] then
		Input("M","S","idle")
	else
		ctrl.m=p
		Input("M","S","move")
	end
end

function ctrl.draw()
	for i=#ctrl.Windows,1,-1 do
		local w=ctrl.Windows[i]
		if w and w.Visible then
			local d=w.draw
			if d then
				setColour(w.Colour)
				setScissor(w.View[1][1],w.View[1][2],w.View[2][1],w.View[2][2])
				d(w)
				w.Colour={getColour()}
			end
		end
	end
	setColour(255,255,255,255)
	setScissor()
	if DebugMode and ctrl.MFocus then
		love.graphics.setColor(0,255,0,128)
		love.graphics.rectangle("line",ctrl.MFocus.View[1][1]+0.5,ctrl.MFocus.View[1][2]+0.5,ctrl.MFocus.View[2][1]-1,ctrl.MFocus.View[2][2]-1)
	end
	if DebugMode and ctrl.KFocus then
		love.graphics.setColor(255,0,0,128)
		love.graphics.rectangle("line",ctrl.KFocus.View[1][1]+0.5,ctrl.KFocus.View[1][2]+0.5,ctrl.KFocus.View[2][1]-1,ctrl.KFocus.View[2][2]-1)
	end
end

function ctrl.update(t)
	uMouse{getPos()}
	for i=1,#ctrl.Windows do
		local w=ctrl.Windows[i]
		if w and w.Visible then
			local u=w.update
			if u then
				u(w,t)
			end
		end
	end
end

function ctrl.focus(edge)
	if edge then
		--Focus gained
	else
		for i=1,#ctrl.Windows do
			local w=ctrl.Windows[i]
			for c,state in next,w.Btn do
				if state then
					Input("M","U",c)
				end
			end
			for c,state in next,w.Key do
				if state then
					Input("K","U",c)
				end
			end
		end
		ctrl.KFocus=nil
		ctrl.MFocus=nil
	end
end

function ctrl.keypressed(k)
	if k~="capslock" and k~="scrollock" and k~="numlock" then
		Input("K","D",k)
	end
end

function ctrl.keyreleased(k)
	if k~="capslock" and k~="scrollock" and k~="numlock" then
		Input("K","U",k)
	end
end

function ctrl.mousepressed(x,y,b)
	uMouse{x,y}
	if b=="wu" or b=="wd" then
		Input("M","S",b)
	else
		Input("M","D",b)
	end
end

function ctrl.mousereleased(x,y,b)
	uMouse{x,y}
	if b~="wd" and b~="wu" then
		Input("M","U",b)
	end
end

_G.ctrl=ctrl
return ctrl
