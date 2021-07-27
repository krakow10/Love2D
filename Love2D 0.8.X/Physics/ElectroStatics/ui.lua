--By xXxMoNkEyMaNxXx
local vec=require'vec'

local draw=love.graphics.draw
local text=love.graphics.print
local rect=love.graphics.rectangle
local newImage=love.graphics.newImage
local setColour=love.graphics["set".."Color"]--annoying when it doesn't suggest it.

local ui={
	ROOT={
		View={
			{
				{0,0},
				{0,0}
			},
			{
				{1,1},
				{0,0}
			}
		}
	}
}

function ui.new(parent)
	parent=parent or ui.ROOT
	local obj={
		View={
			{--Pos
				{0,0},--Scale
				{0,0}--Offset
			},
			{--Size
				{0,0},--Scale
				{0,0}--Offset
			}
		},
		Parent=parent,
		Visible=true,
	}
	parent[#parent+1]=obj
	return obj
end

local function render(obj,area)
	local View={vec.add(area[1],vec.add(vec.mul(obj.View[1][1],area[2]),obj.View[1][2])),vec.add(vec.mul(obj.View[2][1],area[2]),obj.View[2][2])}--Whew!
	if obj.BackgroundColour then
		setColour(obj.BackgroundColour)
		rect("fill",View[1][1],View[1][2],View[2][1],View[2][2])
	end
	if obj.Image then
		setColour(255,255,255,255)
		local Window=obj.ImagePortion or {{1,1},{0,0}}
		draw(obj.Image,View[1][1],View[1][2],obj.Angle or 0,View[2][1]/(Window[1][1]*obj.ImageSize[1]),View[2][2]/(Window[1][2]*obj.ImageSize[2]),Window[2][1],Window[2][2])
	end
	if obj.Text then
		if obj.TextColour then
			setColour(obj.TextColour)
		end
		local TextPos=obj.TextPos or {0,0}
		text(obj.Text,View[1][1]+TextPos[1],View[1][2]+TextPos[2])
	end
	for i=1,#obj do
		if obj[i].Visible then
			render(obj[i],View)
		end
	end
end

function ui.draw(area)
	render(ui.ROOT,area)
end

local function cast(obj,area,pos)
	local View={vec.add(area[1],vec.add(vec.mul(obj.View[1][1],area[2]),obj.View[1][2])),vec.add(vec.mul(obj.View[2][1],area[2]),obj.View[2][2])}
	for i=#obj,1,-1 do
		local test=cast(obj[i],View,pos)
		if test then
			return test
		end
	end
	if obj~=ui.ROOT and ((not obj.Angle or obj.Angle==0) and pos[1]>=View[1][1] and pos[2]>=View[1][2] and pos[1]<=View[1][1]+View[2][1] and pos[2]<=View[1][2]+View[2][2] or (false)) then--No rotation casting yet
		return obj
	end
end

function ui.cast(area,pos)
	return cast(ui.ROOT,area,pos)
end

local function eFunc(name)
	return function(self)
		local hit=cast(ui.ROOT,self.View,ctrl.m)
		if hit and hit[name] then
			hit[name]()
		end
	end
end

function ui.connect(window)
	window.Event.MouseMoved=eFunc'MouseMoved'
	window.Event.MouseButton1Down=eFunc'MouseButton1Down'
	window.Event.MouseButton1Up=eFunc'MouseButton1Up'
	window.Event.MouseButton2Down=eFunc'MouseButton2Down'
	window.Event.MouseButton2Up=eFunc'MouseButton2Up'
	window.Control.MouseMoved="MSmove"
	window.Control.MouseButton1Down="MDl"
	window.Control.MouseButton1Up="MUl"
	window.Control.MouseButton2Down="MDr"
	window.Control.MouseButton2Up="MUr"
end

function ui.wrapper(window)
	local TitleBar=ui.new()
	TitleBar.View={
		{
			{0,0},
			{0,0}
		},
		{
			{1,0},
			{0,30}
		}
	}
	TitleBar.TextPos={9,9}
	TitleBar.Text="TitleBar.Text"
	TitleBar.TextColour={255,255,255,255}
	TitleBar.BackgroundColour={51,147,191,192}
	TitleBar.MouseButton1Down=function()
		window.ViewDragOffset=vec.sub(window.View[1],ctrl.m)
		if not ctrl.Focus then
			ctrl.Focus=window
		end
	end
	TitleBar.MouseButton1Up=function()
		if window.ViewDragOffset then
			window.View[1]=vec.add(ctrl.m,window.ViewDragOffset)
			window.ViewDragOffset=nil
			if ctrl.Focus==window and not window.ViewResizeOffset then
				ctrl.Focus=nil
			end
		end
	end

	local Close=ui.new(TitleBar)
	Close.View={
		{
			{1,0},
			{-27.5,2.5}
		},
		{
			{0,0},
			{25,25}
		}
	}
	Close.Image=newImage'gfx/close.png'
	Close.ImageSize={Close.Image:getWidth(),Close.Image:getHeight()}
	Close.MouseButton1Down=function()
		window:Destroy()
	end

	local Resize=ui.new()
	Resize.View={
		{
			{1,1},
			{-40,-20}
		},
		{
			{0,0},
			{40,20}
		}
	}
	Resize.TextColour={0,0,0,255}
	Resize.Text="Resize"
	Resize.BackgroundColour={192,192,192,192}
	Resize.MouseButton1Down=function()
		window.ViewResizeOffset=vec.sub(vec.add(window.View[1],window.View[2]),ctrl.m)
		if not ctrl.Focus then
			ctrl.Focus=window
		end
	end
	Resize.MouseButton1Up=function()
		if window.ViewResizeOffset then
			window.View[2]=vec.sub(vec.add(ctrl.m,window.ViewResizeOffset),window.View[1])
			window.ViewResizeOffset=nil
			if ctrl.Focus==window and not window.ViewDragOffset then
				ctrl.Focus=nil
			end
		end
	end
	return {
		TitleBar=TitleBar,
		Close=Close,
		Resize=Resize,
		update=function(self)
			if self.ViewDragOffset then
				self.View[1]=vec.add(ctrl.m,self.ViewDragOffset)
			end
			if self.ViewResizeOffset then
				self.View[2]=vec.sub(vec.add(ctrl.m,self.ViewResizeOffset),self.View[1])
			end
		end,
	}
end

return ui
