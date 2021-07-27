--By xXxMoNkEyMaNxXx

local folderContents=love.filesystem.enumerate

local ui=loader.open'ui.lua'

local window=ui.connect(ctrl.newWindow())
window.Control._BringToFront={"MDl","MDr"}
local wrapper=ui.wrapper(window)
wrapper.TitleBar.Text="Scroll Box"

local fc=folderContents''

local frame=ui.new(ui.ROOT)
frame.Pos=ui.SO(0,0,40,40)
frame.Size=ui.SO(1,1,-80,-80)
frame.BackgroundColour={50,13,1,255}

local list=ui.new()
list.Size[2]={250,1+21*#fc}
list.BackgroundColour={121,76,61,255}
for i=1,#fc do
	local item=ui.new(list)
	item.Pos[2]={1,1+(i-1)*21}
	item.Size=ui.SO(1,0,-2,20)
	item.TextPos={6,6}
	item.Text=fc[i]
	item.TextColour={255,255,255,255}
	item.BackgroundColour={69,37,27,255}
end

local scroll=ui.scroll(list,frame)
scroll.Frame.Pos[2]={3,25}
scroll.Frame.Size=ui.SO(1,1,-6,-28)
window.update=scroll.update
