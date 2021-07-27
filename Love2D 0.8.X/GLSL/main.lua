local test=love.graphics.newPixelEffect[[
//extern number t;
extern Image img;
extern vec2 vs;
extern vec2 m;
vec4 effect(vec4 colour, Image _, vec2 txy, vec2 s)
{
	return Texel(img,vec2(s.x/vs.x,1-s.y/vs.y));
}
]]
love.graphics.setPixelEffect(test)
local rectangle=love.graphics.rectangle
function love.draw()
	rectangle("fill",10,10,500,500)
end
function love.update()
	test:send("m",{love.mouse.getPosition())
end
function love.update()
	love.graphics.setCaption(love.timer.getFPS())
	--test:send("t",(love.timer.getTime()*2)%(2*math.pi))
	test:send("img",love.graphics.newImage'Spectrum.png')
	test:send("vs",{love.graphics.getWidth(),love.graphics.getHeight()})
end
