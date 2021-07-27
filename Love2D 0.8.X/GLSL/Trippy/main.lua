local test=love.graphics.newPixelEffect[[
extern number t;
vec4 effect(vec4 colour, Image img, vec2 txy, vec2 sxy)
{
	return vec4(pow(cosh(sxy.x/20+t),2),pow(sinh(sxy.y/20+t),2),abs(1/(1+tanh(length(sxy/20)+t))),1);
}
]]
love.graphics.setPixelEffect(test)
local rectangle=love.graphics.rectangle
function love.draw()
	rectangle("fill",10,10,500,500)
end
function love.update()
	love.graphics.setCaption(love.timer.getFPS())
	test:send("t",(love.timer.getTime()*2)%(2*math.pi))
end
