--By xXxMoNkEyMaNxXx

local image=love.graphics.newImage'nature.jpg'

local effect=love.graphics.newPixelEffect[[
extern vec2 viewsize;
extern vec2 centre;
extern number radius;

extern Image image;

vec4 mask(vec4 base,vec4 over)
{
	number t0=over.a;
	number t1=1-over.a;
	return vec4(over.rgb*t0+base.rgb*t1,t0+base.a*t1);
}

vec4 effect(vec4 colour,Image _1,vec2 _2,vec2 pixelinverted)
{
	vec2 pixel=vec2(pixelinverted.x,viewsize.y-pixelinverted.y);
	vec2 diff=pixel-centre;
	if(length(diff)<=radius){
		return mask(colour,Texel(image,(centre+normalize(diff)*radius*(1-sqrt(1-pow(length(diff/radius),2))))/viewsize));
	}
	return mask(colour,Texel(image,pixel/viewsize));
}
]]
local w,h=love.graphics.getWidth(),love.graphics.getHeight()
effect:send("image",image)
effect:send("viewsize",{w,h})

love.graphics.setPixelEffect(effect)

function love.draw()
	effect:send("radius",{150})
	effect:send("centre",{love.mouse.getPosition()})
	love.graphics.rectangle("fill",0,0,w,h)
end

