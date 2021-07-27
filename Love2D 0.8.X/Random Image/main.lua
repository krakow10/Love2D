local img=love.image.newImageData(1024,1024)

math.randomseed(os.time())
local random=math.random
random()
random()

img:mapPixel(function(x,y)
	return 256*random(),256*random(),256*random(),256*random()
end)

img:encode(tostring(math.random()):sub(3)..".png")

love.event.quit()
