--By xXxMoNkEyMaNxXx




--Textured Polygon Demo--
local texture=require'Perspective'

local image=love.graphics.newImage'textures/ff nub.png'
local vertices={{100,100},{400,100},{400,400},{100,400}}

--Try uncommenting one of these! 600 is the image size.--
--texture.setRepeat({0.25,0.25},{0.75,0.75})
--texture.setRepeat({253/600,50/600},{80/600,80/600})

function love.draw()--Yep, that's it!
	texture.quad(image,vertices[1],vertices[2],vertices[3],vertices[4])
end
-------------------------





































--Dragging Vertices & Colour (for demonstration purposes)--
love.graphics.setBackgroundColor(255,255,255,255)
--localize
local down=love.mouse.isDown
local pos=love.mouse.getPosition
local setColour=love.graphics.setColor
local time=love.timer.getTime
local cap=love.graphics.setCaption
local fps=love.timer.getFPS

--vars
local dragging
local offset

function love.update()
	local x,y=pos()
	local b1d=down'l'
	if dragging then
		vertices[dragging]={x+offset[1],y+offset[2]}
		if not b1d then
			dragging=nil
		end
	elseif b1d then
		local vc
		local best=math.huge
		for i,v in next,vertices do
			local dis=math.sqrt((v[1]-x)^2+(v[2]-y)^2)
			if dis<best then
				vc,best=i,dis
			end
		end
		dragging,offset=vc,{vertices[vc][1]-x,vertices[vc][2]-y}
	end
	local t=time()%math.pi
	setColour(255*math.sin(t)^2,255*math.sin(t+math.pi/3)^2,255*math.sin(t+2*math.pi/3)^2,255*math.cos(time()*2^0.5)^2)
	cap("Textured Polygons Demo - "..fps().." FPS")
end
-----------------------------------------------------------
