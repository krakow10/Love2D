--By xXxMoNkEyMaNxXx
local min,max=math.min,math.max
local sub=string.sub

local vec=require'vec'

local draw=love.graphics.draw
local text=love.graphics.print
local rect=love.graphics.rectangle
local colour=love.graphics.setColor
local newImage=love.graphics.newImage
local getScissor=love.graphics.getScissor
local setScissor=love.graphics.setScissor

local function SO(sx,sy, ox,oy)--ScaleOffset
	return {{sx,sy},{ox,oy}}
end

local ui={
	ROOT={
		Pos=SO(0,0,0,0),
		Size=SO(1,1,0,0),
		Visible=true,
	},
	SO=SO,
}

local function Destroy(obj)
	local p=obj.Parent
	if p then
		local shift=false
		for i=1,#p-1 do
			if shift then
				p[i]=p[i+1]
			elseif p[i]==obj then
				shift=true
			end
		end
		p[#p]=nil
	end
end

local function reParent(obj,newParent)
	if obj.Parent then
		Destroy(obj)
	end
	if newParent then
		obj.Parent=newParent
		newParent[#newParent+1]=obj
	else
		print'Use Object:Destroy() instead of Object:reParent(nil)'
	end
end

function ui.new(Parent)
	local obj={
		Pos={
			{0,0},--Scale: %Parent's size
			{0,0}--Offset: Pixel Offset
		},
		Size={
			{0,0},--Scale: %Parent's size
			{0,0}--Offset: Pixel Offset
		},
		--Read Only--
		Area={{0,0},{0,0}},
		Key={},
		Btn={},
		Btns=0,
		Keys=0,
		-------------
		reParent=reParent,
		Parent=Parent,
		Destroy=Destroy,
		Visible=true,
	}
	if Parent then
		Parent[#Parent+1]=obj
	end
	return obj
end

local function render(obj,area)
	local view={vec.add(area[1],vec.add(vec.mul(obj.Pos[1],area[2]),obj.Pos[2])),vec.add(vec.mul(obj.Size[1],area[2]),obj.Size[2])}--Whew!

	--Read only--
	obj.Area=view
	-------------

	if obj.BackgroundColour then
		colour(obj.BackgroundColour)
		rect("fill",view[1][1],view[1][2],view[2][1],view[2][2])
	end
	if obj.Image then
		colour(255,255,255,255)
		local Window=obj.ImagePortion or {{1,1},{0,0}}
		draw(obj.Image,view[1][1],view[1][2],(obj.Angle or 0)+(obj.ImageAngle or 0),view[2][1]/(Window[1][1]*obj.ImageSize[1]),view[2][2]/(Window[1][2]*obj.ImageSize[2]),Window[2][1],Window[2][2])
	end
	if obj.Text then
		if obj.TextColour then
			colour(obj.TextColour)
		else
			colour(255,255,255,255)
		end
		local TextPos=obj.TextPos or {0,0}
		text(obj.Text,view[1][1]+TextPos[1],view[1][2]+TextPos[2])
	end
	local sc={getScissor()}
	if obj.ClipsDescendants then
		local _ox,_oy=max(sc[1],view[1][1]),max(sc[2],view[1][2])
		local _sx,_sy=min(sc[1]+sc[3]-_ox,view[2][1]),min(sc[2]+sc[4]-_oy,view[2][2])
		setScissor(min(_ox,_ox+_sx),min(_oy,_oy+_sy),max(0,_sx),max(0,_sy))
	end
	for i=1,#obj do
		if obj[i].Visible then
			render(obj[i],view)
		end
	end
	if obj.ClipsDescendants then
		if #sc==4 then
			setScissor(sc[1],sc[2],sc[3],sc[4])
		else
			setScissor()
		end
	end
end
local function drawDebug()
	if ui.MFocus then
		colour(255,255,0,128)
		rect("line",ui.MFocus.Area[1][1]+0.5,ui.MFocus.Area[1][2]+0.5,ui.MFocus.Area[2][1]-1,ui.MFocus.Area[2][2]-1)
	end
	if ui.KFocus then
		colour(0,0,255,128)
		rect("line",ui.KFocus.Area[1][1]+0.5,ui.KFocus.Area[1][2]+0.5,ui.KFocus.Area[2][1]-1,ui.KFocus.Area[2][2]-1)
	end
end
function ui.draw(area)
	render(ui.ROOT,area)
	if DebugMode then
		drawDebug()
	end
end

local noclip={0,0,math.huge,math.huge}--lololo
local function cast(obj,pos,area,event,eArgs,clipping)
	if obj.Visible then
		local view={vec.add(area[1],vec.add(vec.mul(obj.Pos[1],area[2]),obj.Pos[2])),vec.add(vec.mul(obj.Size[1],area[2]),obj.Size[2])}
		if obj.ClipsDescendants then
			clipping=clipping or noclip
			local _ox,_oy=max(clipping[1],view[1][1]),max(clipping[2],view[1][2])
			local _sx,_sy=min(clipping[1]+clipping[3]-_ox,view[2][1]),min(clipping[2]+clipping[4]-_oy,view[2][2])
			clipping={_ox,_oy,_sx,_sy}
		end
		if not clipping or pos[1]>=clipping[1] and pos[2]>=clipping[2] and pos[1]<=clipping[1]+clipping[3] and pos[2]<=clipping[2]+clipping[4] then
			for i=#obj,1,-1 do
				local test=cast(obj[i],pos,view,event,eArgs,clipping)
				if test then
					return test
				end
			end
		end
		if obj~=ui.ROOT and ((not obj.Angle or obj.Angle==0) and (pos[1]>=view[1][1] and pos[2]>=view[1][2] and pos[1]<=view[1][1]+view[2][1] and pos[2]<=view[1][2]+view[2][2])) and (not event or obj[event] and not obj[event](unpack(eArgs))) then--No rotation casting yet
			return obj
		end
	end
end

function ui.cast(pos,area)
	return cast(ui.ROOT,pos,area)
end

local function addEvent(window,Event,Control)
	local device=sub(Control,1,1)
	window.Control[Event]=Control
	window.Event[Event]=function(self,...)
		if device=="M" and ui.MFocus and ui.MFocus[Event] then
			return ui.MFocus[Event](...)
		elseif device=="K" and ui.KFocus and ui.KFocus[Event] then
			return ui.KFocus[Event](...)
		else
			if not cast(ui.ROOT,ctrl.m,self.View,Event,{...}) then
				return true--Nothing happened, continue to next window if all other controls fired return true.
			end
		end
	end
end

function ui.connect(window)
	addEvent(window,"MouseMoved","MSmove")
	addEvent(window,"MouseButton1Down","MDl")
	addEvent(window,"MouseButton1Up","MUl")
	addEvent(window,"MouseButton2Down","MDr")
	addEvent(window,"MouseButton2Up","MUr")
	addEvent(window,"MouseButton3Down","MDm")
	addEvent(window,"MouseButton3Up","MUm")
	addEvent(window,"MouseWheelForward","MSwu")
	addEvent(window,"MouseWheelBackward","MSwd")
	addEvent(window,"KeyDown","KD")
	addEvent(window,"KeyUp","KU")

	window.mousepressed=function(self,c)
		if ui.MFocus then
			ui.MFocus.Btn[c]=true
			ui.MFocus.Btns=ui.MFocus.Btns+1
		else
			local hit=cast(ui.ROOT,ctrl.m,self.View)
			if hit then
				if hit.Btns==0 then
					ui.MFocus=hit
					if ui.KFocus and ui.KFocus~=hit then
						local ku=ui.KFocus.KeyUp
						local kd=hit.KeyDown
						local temp=ui.KFocus.Key
						hit.Key,hit.Keys,ui.KFocus.Key,ui.KFocus.Keys=ui.KFocus.Key,ui.KFocus.Keys,{},0
						for c,state in next,temp do
							if state then
								if ku then
									ku(c)
								end
								if kd then
									kd(c)
								end
							end
						end
						ui.KFocus=hit
					end
				end
				hit.Btn[c]=true
				hit.Btns=hit.Btns+1
			end
		end
	end
	window.mousereleased=function(self,c)
		if ui.MFocus then
			ui.MFocus.Btn[c]=nil
			ui.MFocus.Btns=max(0,ui.MFocus.Btns-1)
			if ui.MFocus.Btns==0 then
				ui.MFocus=nil
			end
		end
	end

	window.keypressed=function(self,c)
		if ui.KFocus then
			ui.KFocus.Key[c]=true
			ui.KFocus.Keys=ui.KFocus.Keys+1
		else
			local hit=cast(ui.ROOT,ctrl.m,self.View)
			if hit then
				if hit.Keys==0 then
					ui.KFocus=hit
				end
				hit.Key[c]=true
				hit.Keys=hit.Keys+1
			end
		end
	end
	window.keyreleased=function(self,c)
		if ui.KFocus then
			ui.KFocus.Key[c]=nil
			ui.KFocus.Keys=max(0,ui.KFocus.Keys-1)
			if ui.KFocus.Keys==0 then
				ui.KFocus=nil
			end
		end
	end
	window.draw=function(self)
		render(ui.ROOT,self.View)
		if DebugMode then
			drawDebug()
		end
	end
	return window
end

function ui.wrapper(window)
	local TitleBar=ui.new(ui.ROOT)
	TitleBar.Size=SO(1,0,0,30)
	TitleBar.TextPos={9,9}
	TitleBar.Text="TitleBar.Text"
	TitleBar.TextColour={255,255,255,255}
	TitleBar.BackgroundColour={51,147,191,192}
	TitleBar.MouseButton1Down=function()
		window.ViewDragOffset=vec.sub(window.View[1],ctrl.m)
	end
	TitleBar.MouseButton1Up=function()
		if window.ViewDragOffset then
			window.View[1]=vec.add(ctrl.m,window.ViewDragOffset)
			window.ViewDragOffset=nil
		end
	end

	local Close=ui.new(TitleBar)
	Close.Pos=SO(1,0,-27.5,2.5)
	Close.Size=SO(0,0,25,25)
	Close.Image=newImage'gfx/close.png'
	Close.ImageSize={Close.Image:getWidth(),Close.Image:getHeight()}
	Close.MouseButton1Down=function()
		window:Destroy()
	end

	local Resize=ui.new(ui.ROOT)
	Resize.Pos=SO(1,1,-40,-20)
	Resize.Size=SO(0,0,40,20)
	Resize.TextColour={0,0,0,255}
	Resize.Text="Resize"
	Resize.BackgroundColour={192,192,192,192}
	Resize.MouseButton1Down=function()
		window.ViewResizeOffset=vec.sub(vec.add(window.View[1],window.View[2]),ctrl.m)
	end
	Resize.MouseButton1Up=function()
		if window.ViewResizeOffset then
			window.View[2]=vec.max(vec.sub(vec.add(ctrl.m,window.ViewResizeOffset),window.View[1]),{40,30})
			window.ViewResizeOffset=nil
		end
	end
	window.update=function(self)
		if self.ViewDragOffset then
			self.View[1]=vec.add(ctrl.m,self.ViewDragOffset)
		end
		if self.ViewResizeOffset then
			self.View[2]=vec.max(vec.sub(vec.add(ctrl.m,self.ViewResizeOffset),self.View[1]),{40,30})
		end
	end
	return {
		TitleBar=TitleBar,
		Close=Close,
		Resize=Resize,
	}
end

function ui.scroll(obj,Parent,Options)--'obj' scrolls in 'Frame'
	local Frame=ui.new(Parent)
	Frame.ClipsDescendants=true
	obj:reParent(Frame)

	local Options=Options or {}
	Options.Size=Options.Size or {20,20}--Scrollbar size
	Options.Step=Options.Step or {-30,21}--Amount in pixels that 'obj' moves when the scrollwheel is turned.
	Options.Speed=Options.Speed or {30,30}--pixels/second that the arrows (not currently implemented) will move 'obj'

	local Displacement={0,0}

	local ScrollX=ui.new(Frame)
	ScrollX.Pos=SO(0,1,0,-Options.Size[1])
	ScrollX.Size=SO(1,0,0,Options.Size[1])
	ScrollX.BackgroundColour={220,220,220,220}
	ScrollX.Visible=false

	local OffsetX
	ScrollX.MouseButton1Down=function()
		OffsetX=ScrollX.Area[1][1]-ctrl.m[1]
	end
	ScrollX.MouseButton1Up=function()
		OffsetX=nil
	end

	local ScrollY=ui.new(Frame)
	ScrollY.Pos=SO(1,0,-Options.Size[2],0)
	ScrollY.Size=SO(0,1,Options.Size[2],0)
	ScrollY.BackgroundColour={220,220,220,220}
	ScrollY.Visible=false

	local OffsetY
	ScrollY.MouseButton1Down=function()
		OffsetY=ScrollY.Area[1][2]-ctrl.m[2]
	end
	ScrollY.MouseButton1Up=function()
		OffsetY=nil
	end

	Frame.MouseWheelForward=function()
		if ScrollY.Visible then
			local percentY=(obj.Area[1][2]-Frame.Area[1][2]+Options.Step[2])/(Frame.Area[2][2]-obj.Area[2][2])
			local constrained=max(0,min(percentY,1))
			ScrollY.Pos[2][2]=constrained*(Frame.Area[2][2]+Displacement[2]-ScrollY.Area[2][2])
			obj.Pos[2][2]=constrained*(Frame.Area[2][2]-obj.Area[2][2])
		elseif ScrollX.Visible then
			local percentX=(obj.Area[1][1]-Frame.Area[1][1]+Options.Step[1])/(Frame.Area[2][1]-obj.Area[2][1])
			local constrained=max(0,min(percentX,1))
			ScrollX.Pos[2][1]=constrained*(Frame.Area[2][1]+Displacement[1]-ScrollX.Area[2][1])
			obj.Pos[2][1]=constrained*(Frame.Area[2][1]-obj.Area[2][1])
		end
	end
	Frame.MouseWheelBackward=function()
		if ScrollY.Visible then
			local percentY=(obj.Area[1][2]-Frame.Area[1][2]-Options.Step[2])/(Frame.Area[2][2]-obj.Area[2][2])
			local constrained=max(0,min(percentY,1))
			ScrollY.Pos[2][2]=constrained*(Frame.Area[2][2]+Displacement[2]-ScrollY.Area[2][2])
			obj.Pos[2][2]=constrained*(Frame.Area[2][2]-obj.Area[2][2])
		elseif ScrollX.Visible then
			local percentX=(obj.Area[1][1]-Frame.Area[1][1]-Options.Step[1])/(Frame.Area[2][1]-obj.Area[2][1])
			local constrained=max(0,min(percentX,1))
			ScrollX.Pos[2][1]=constrained*(Frame.Area[2][1]+Displacement[1]-ScrollX.Area[2][1])
			obj.Pos[2][1]=constrained*(Frame.Area[2][1]-obj.Area[2][1])
		end
	end

	ScrollX.MouseMoved=function()
		if OffsetX then
			local percentX=(ctrl.m[1]+OffsetX-Frame.Area[1][1])/(Frame.Area[2][1]+Displacement[1]-ScrollX.Area[2][1])
			local constrained=max(0,min(percentX,1))
			ScrollX.Pos[2][1]=constrained*(Frame.Area[2][1]+Displacement[1]-ScrollX.Area[2][1])
			obj.Pos[2][1]=constrained*(Frame.Area[2][1]-obj.Area[2][1])
			if percentX<0 then
				OffsetX=min(-1,Frame.Area[1][1]-ctrl.m[1])
			elseif percentX>1 then
				OffsetX=max(1-ScrollX.Area[2][1],Frame.Area[1][1]+Frame.Area[2][1]+Displacement[1]-ScrollX.Area[2][1]-ctrl.m[1])
			end
		end
	end
	ScrollY.MouseMoved=function()
		if OffsetY then
			local percentY=(ctrl.m[2]+OffsetY-Frame.Area[1][2])/(Frame.Area[2][2]+Displacement[2]-ScrollY.Area[2][2])
			local constrained=max(0,min(percentY,1))
			ScrollY.Pos[2][2]=constrained*(Frame.Area[2][2]+Displacement[2]-ScrollY.Area[2][2])
			obj.Pos[2][2]=constrained*(Frame.Area[2][2]-obj.Area[2][2])
			if percentY<0 then
				OffsetY=min(-1,Frame.Area[1][2]-ctrl.m[2])
			elseif percentY>1 then
				OffsetY=max(1-ScrollY.Area[2][2],Frame.Area[1][2]+Frame.Area[2][2]+Displacement[2]-ScrollY.Area[2][2]-ctrl.m[2])
			end
		end
	end

	local lastSize={Frame.Area[2][1],Frame.Area[2][2]}
	local function update()
		if obj.Area[2][1]>Frame.Area[2][1] then
			if not ScrollX.Visible then
				ScrollX.Visible=true
				Displacement[2]=-Options.Size[1]
			end
			ScrollX.Size[1][1]=(1+Displacement[1]/Frame.Area[2][1])*Frame.Area[2][1]/obj.Area[2][1]
		else
			if ScrollX.Visible then
				ScrollX.Visible=false
				obj.Pos[2][1]=0
				Displacement[2]=0
			end
		end
		if obj.Area[2][2]>Frame.Area[2][2] then
			if not ScrollY.Visible then
				ScrollY.Visible=true
				Displacement[1]=-Options.Size[2]
			end
			ScrollY.Size[1][2]=(1+Displacement[2]/Frame.Area[2][2])*Frame.Area[2][2]/obj.Area[2][2]
		else
			if ScrollY.Visible then
				ScrollY.Visible=false
				obj.Pos[2][2]=0
				Displacement[1]=0
			end
		end

		if Frame.Area[2][1]~=lastSize[1] and ScrollX.Visible then
			lastSize[1]=Frame.Area[2][1]
			ScrollX.Size[1][1]=(1+Displacement[1]/Frame.Area[2][1])*Frame.Area[2][1]/obj.Area[2][1]
			local percentX=(obj.Pos[2][1])/(Frame.Area[2][1]-obj.Area[2][1])
			local constrained=max(0,min(percentX,1))
			ScrollX.Pos[2][1]=constrained*(Frame.Area[2][1]+Displacement[1]-ScrollX.Area[2][1])
			obj.Pos[2][1]=constrained*(Frame.Area[2][1]-obj.Area[2][1])
		end
		if Frame.Area[2][2]~=lastSize[2] and ScrollY.Visible then
			lastSize[2]=Frame.Area[2][2]
			ScrollY.Size[1][2]=(1+Displacement[2]/Frame.Area[2][2])*Frame.Area[2][2]/obj.Area[2][2]
			local percentY=(obj.Pos[2][2])/(Frame.Area[2][2]-obj.Area[2][2])
			local constrained=max(0,min(percentY,1))
			ScrollY.Pos[2][2]=constrained*(Frame.Area[2][2]+Displacement[2]-ScrollY.Area[2][2])
			obj.Pos[2][2]=constrained*(Frame.Area[2][2]-obj.Area[2][2])
		end
	end

	return {
		Frame=Frame,
		ScrollX=ScrollX,
		ScrollY=ScrollY,
		update=update,
	}
end
return ui
