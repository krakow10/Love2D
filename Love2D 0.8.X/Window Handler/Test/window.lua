--Test
local draw=love.graphics.draw
local text=love.graphics.print
local rect=love.graphics.rectangle
local setColour=love.graphics.setColor

--[[Window 1--
local window=ctrl.newWindow()
window.Title="A window without default Events and Controls."

function window:draw()
	rect("fill",self.View[1][1],self.View[1][2],self.View[2][1],self.View[2][2])
	setColour(0,0,0,255)
	text(self.Title,self.View[1][1],self.View[1][2])
end
--]]----------

--Window 2--
local img=love.graphics.newImage'Test/Tux.png'
local imgsize={img:getWidth(),img:getHeight()}

local window2=ctrl.newWindow()
ctrl.worldDrag(window2)
ctrl.viewDrag(window2)
window2.Control._BringToFront={"MDl","MDr"}
window2.View={{430,50},{100,300}}

window2.draw=function(self)
	local area=self:toScreenArea{{0,0},{2,2}}
	draw(img,self.View[1][1]+area[1][1],self.View[1][2]+area[1][2],0,area[2][1]/imgsize[1],area[2][2]/imgsize[2],imgsize[1]/2,imgsize[2]/2)
	text("Test Window",self.View[1][1],self.View[1][2])
end
------------
