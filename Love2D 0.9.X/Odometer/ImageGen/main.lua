--Generate an image from each digit
local draw=love.graphics.draw
local newImage=love.graphics.newImage
local newCanvas=love.graphics.newCanvas

local _0=newImage'0.png'
local _1=newImage'1.png'
local _2=newImage'2.png'
local _3=newImage'3.png'
local _4=newImage'4.png'
local _5=newImage'5.png'
local _6=newImage'6.png'
local _7=newImage'7.png'
local _8=newImage'8.png'
local _9=newImage'9.png'

function love.draw()
	local _0123456789=newCanvas(300,2*500)
	setCanvas(_0123456789)
	draw(_0,0,0)
	draw(_1,0,500)
	draw(_2,0,2*500)
	draw(_3,0,3*500)
	draw(_4,0,4*500)
	draw(_5,0,5*500)
	draw(_6,0,6*500)
	draw(_7,0,7*500)
	draw(_8,0,8*500)
	draw(_9,0,9*500)

	local out=love.filesystem.newFile'0123456789.png'
	out:open'w'
	_0123456789:getImageData():encode(out)
	out:close()

	love.event.quit()
end