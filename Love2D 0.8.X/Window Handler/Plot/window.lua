--By xXxMoNkEyMaNxXx

local concat=table.concat

local cont=love.filesystem.enumerate
local israel=love.filesystem.exists
local isfd=love.filesystem.isDirectory

local vec=require'vec'
local ui=loader.open'ui.lua'
local window=ui.connect(ctrl.newWindow())
local wrapper=ui.wrapper(window)
wrapper.TitleBar.Text="Data Plot"
--ctrl.worldDrag(window)

local updaters={}

local function getFile(ext)
	local path={}
	local Offset
	local setFolder

	local frame=ui.new(ui.ROOT)
	frame.Size[2]={200,350}
	frame.BackgroundColour={50,13,1,255}
	frame.MouseButton1Down=function()
		Offset=vec.sub(frame.Area[1],ctrl.m)
	end
	frame.MouseMoved=function()
		if Offset then
			frame.Pos[2]=vec.sub(vec.add(ctrl.m,Offset),window.View[1])
		end
	end
	frame.MouseButton1Up=function()
		frame.MouseMoved()
		Offset=nil
	end

	local up=ui.new(frame)
	up.Pos=ui.SO(1,0,-19-22-25,3)
	up.Size=ui.SO(0,0,19+22,19)
	up.BackgroundColour={128,128,128,200}
	up.MouseButton1Down=function()
		path[#path]=nil
		setFolder(cont(concat(path,"/")))
		print'Up one level'
	end

	local list=ui.new()
	list.Size=ui.SO(1,0,0,0)
	list.BackgroundColour={121,76,61,255}
	list.ClipsDescendants=true

	local scroll=ui.scroll(list,frame)
	scroll.Frame.Pos=ui.SO(0,0,3,25)
	scroll.Frame.Size=ui.SO(1,1,-6,-28)
	window.update=scroll.update

	local function listItem(n)
		local item=ui.new(list)
		item.Pos[2]={1,21*(n-1)}
		item.Size=ui.SO(1,0,-2,20)
		item.TextColour={255,255,255,255}
		item.BackgroundColour={69,37,27,255}
		item.MouseButton1Down=function()
			local newfd=concat(path,"/").."/"..item.Text
			if isfd(newfd) then
				path[#path+1]=item.Text
				setFolder(cont(newfd))
				print("Folder '"..newfd.."' selected.")
			else
				print("File "..item.Text.." was clicked.")
			end
		end
		return item
	end
	function setFolder(fd)
		for i=1,#fd do
			list[i]=list[i] or listItem(i)
			list[i].Text=fd[i]
		end
		list.Size[2][2]=1+21*#fd
	end
	setFolder(cont'')

	local close=ui.new(frame)
	close.Pos=ui.SO(1,0,-3-19,3)
	close.Size=ui.SO(0,0,19,19)
	close.BackgroundColour={224,0,0,200}
	close.MouseButton1Down=function()
		frame:Destroy()
		window:unhook("update",scroll.update)
	end
end

local press=ui.new(ui.ROOT)
press.Pos=ui.SO(0.5,1,-100,-50)
press.Size=ui.SO(0,0,200,50)
press.Text="Press Me"
press.BackgroundColour={0,0,0,128}
press.MouseButton1Down=function()
	getFile'csv'
end
