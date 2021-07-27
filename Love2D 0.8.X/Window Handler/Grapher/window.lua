--By xXxMoNkEyMaNxXx
local vec=require'vec'
local ui=loader.open'ui.lua'
local window=ctrl.newWindow()
window.Control._BringToFront={"MDl","MDr"}
ctrl.worldDrag(window)
window.Window={{0,0},{2,2}}
ui.connect(window)
local wrapper=ui.wrapper(window)
wrapper.TitleBar.Text="Unsolved Equation Grapher"

local rect=love.graphics.rectangle
local setEffect=love.graphics.setPixelEffect
local s=love.graphics.newPixelEffect(love.filesystem.read'Grapher/GPU.frag')

s:send("BackColour",{1,1,1,1})
s:send("LineColour",{0.25,0,0,1})
s:send("GridColour",{0.8,0.8,0.8,1})
s:send("Thickness",4.9)
s:send("h",love.graphics.getHeight())
s:send("View",window.View)
s:send("Window",window.Window)

math.randomseed(os.time()+os.clock())
math.random()
local rand=math.random
local function r()
	return 2*rand()-1
end

local degree=15--degree must agree with degree in shader (for my polynomials)

function window:draw()
	s:send("RANDOM",rand())
	setEffect(s)
	rect("fill",self.View[1][1],self.View[1][2],self.View[2][1],self.View[2][2])
	setEffect()
end

function window:update(t)
	s:send("View",self.View)
	s:send("Window",self.Window)
end

function window:keypressed(k)
	if k=="r" then
		self.Window={{0,0},{10,10}}
--[[
	elseif k=="right" then
		local P1={}
		local P2={}
		for d=1,degree do
			P1[d]=r()
			P2[d]=r()
		end
		s:send("poly1",unpack(P1))
		s:send("poly2",unpack(P2))
--]]
	end
end
--window:keypressed'right'
