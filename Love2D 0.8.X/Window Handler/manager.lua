--By xXxMoNkEyMaNxXx
local vec=require'vec'
local ui=loader.open'ui.lua'

local israel=love.filesystem.exists--ololo
local newImage=love.graphics.newImage

local manager={}

local window=ui.connect(ctrl.newWindow())
window.View={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}

ui.ROOT.Image=newImage'gfx/Perry.jpg'
ui.ROOT.ImageSize={ui.ROOT.Image:getWidth(),ui.ROOT.Image:getHeight()}

local MenuBar=ui.new(ui.ROOT)
MenuBar.Pos=ui.SO(0,1,0,-50)
MenuBar.Size=ui.SO(1,0,0,50)
MenuBar.BackgroundColour={82,99,209,224}

local function programButton(name,f,icon)
	local b=ui.new(MenuBar)
	b.Pos=ui.SO(0,0,2+(#MenuBar-1)*75,2)
	b.Size=ui.SO(0,1,73,-4)
	b.TextColour={255,255,255,255}
	b.Text=name
	b.BackgroundColour={0,0,0,224}
	b.MouseButton1Down=function()
		loader.run(f)
	end
	if icon then
		b.Image=icon
		b.ImageSize={b.Image:getWidth(),b.Image:getHeight()}
	end
	return b
end

function manager.addProgram(folder)
	if israel(folder) and israel(folder.."/window.lua") then
		local f=loader.load(folder.."/window.lua")
		if f then
			local icon
			if israel(folder.."/icon.png") then
				icon=newImage(folder.."/icon.png")
			end
			programButton(folder,f,icon)
		end
	end
end

return manager
