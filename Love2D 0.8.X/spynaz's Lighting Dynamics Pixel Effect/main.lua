--Pixel effect of spynaz's Lighting Dynamics by xXxMoNkEyMaNxXx
local lumens=3--torchpower
local speed=100
local nTrees=50
local tileSize=15
local viewSize={love.graphics.getWidth(),love.graphics.getHeight()}
local pos={(viewSize[1]-tileSize)/2,(viewSize[2]-tileSize)/2}
local effect=love.graphics.newPixelEffect[[
extern number ts;//Tile size
extern number pwr;
extern vec2 pos;//Player position

vec4 effect(vec4 colour,Image img,vec2 percent,vec2 pixel)
{
	return Texel(img,percent)*(ts/length(pos-pixel)*pwr);
}
]]
effect:send("ts",tileSize)
effect:send("pwr",lumens)
effect:send("pos",pos)
local draw=love.graphics.draw
local rect=love.graphics.rectangle
local setColor=love.graphics.setColor
local setEffect=love.graphics.setPixelEffect

local bg=love.graphics.newCanvas()
bg:renderTo(function()
	setColor(128,128,128,128)
	rect("fill",0,0,viewSize[1],viewSize[2])
	setColor(100,255,100,255)
	for n=1,nTrees do
		rect("fill",math.random()*(viewSize[1]-tileSize),math.random()*(viewSize[2]-tileSize),tileSize,tileSize)
	end
end)
function love.draw()
	setEffect(effect)
	setColor(255,255,255,255)
	draw(bg)
	setEffect()
	setColor(100,100,255,255)
	rect("fill",pos[1]-tileSize/4,viewSize[2]-tileSize/4-pos[2],tileSize/2,tileSize/2)
end

local min,max=math.min,math.max
local isKey=love.keyboard.isDown
function love.update(t)
	if isKey'w' then
		pos[2]=min(viewSize[2]-tileSize/4,pos[2]+t*speed)
	end
	if isKey'a' then
		pos[1]=max(tileSize/4,pos[1]-t*speed)
	end
	if isKey's' then
		pos[2]=max(tileSize/4,pos[2]-t*speed)
	end
	if isKey'd' then
		pos[1]=min(viewSize[1]-tileSize/4,pos[1]+t*speed)
	end
	effect:send("pos",pos)
end
