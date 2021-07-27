--By xXxMoNkEyMaNxXx
local exp=math.exp
local log=math.log
local log10=math.log10
local ceil,floor=math.ceil,math.floor
local max,min=math.max,math.min

local getPos=love.mouse.getPosition

local tick=love.timer.getTime

local rect=love.graphics.rectangle
local print=love.graphics.print
local printf=love.graphics.printf
local setColor=love.graphics.setColor

local w,h=love.graphics.getDimensions()


local t0=tick()

local data={}
local rates={}

local idt=0.001
local imaxRate=10

local spacing=60
local base_x,base_y=4,5

local function shadow(f,text,x,y,...)
	setColor(0,0,0,255)
	f(text,x+1,y+1,...)
	setColor(255,255,255,255)
	f(text,x,y,...)
end

local lastDraw=tick()
function love.draw()
	local t=tick()
	local elapsed=t-t0
	local mx,my=getPos()
	local power_y=floor(log(imaxRate*spacing/h)/log(base_y)+0.5)--spacing=h*base^power/imaxRate
	setColor(128,128,128,255)
	for i=1,floor(imaxRate/base_y^power_y) do
		local height=floor(h*(1-i*base_y^power_y/imaxRate)+0.5)
		rect("fill",0.5,height+0.5,w,1)
		print(i*base_y^power_y.."/s",0,height+1)
	end

	setColor(0,255,255,192)
	for x=1,mx do
		local height=h*rates[x]/imaxRate
		rect("fill",x-0.5,h-height+0.5,1,height)
	end
	setColor(255,255,255,192)
	for x=mx+1,w do
		local height=h*rates[x]/imaxRate
		rect("fill",x-0.5,h-height+0.5,1,height)
	end
	local power_x=ceil(log(t-lastDraw)/log(base_x))
	while t-t0>base_x^power_x do
		local x=floor(w*(power_x*log(base_x)-log(idt))/log(elapsed/idt)+0.5)--log(idt)+(x/w) log(elapsed/idt)=power log(10)
		setColor(255,0,0,255)
		rect("fill",x-0.5,0,1,h)
		print(base_x^power_x.."s: "..string.format("%.2f/s",rates[x] or 0),x+1,20)
		power_x=power_x+1
	end
	shadow(print,"<- Avg over "..string.format("%.14f",t-lastDraw).."s",0,0)
	shadow(printf,"Avg over "..string.format("%.1f",elapsed).."s ->",0,0,w,"right")
	local avgavg=#data*log(t-t0)--Mean value theorem
	for i=1,#data do
		avgavg=avgavg-log(t-data[i])
	end
	shadow(printf,"Average of averages: "..string.format("%.8f",avgavg/elapsed).."/s",0,0,w,"center")
	shadow(print,rates[1],0,h-20)
	shadow(printf,rates[w],0,h-20,w,"right")
	shadow(printf,"Avg over "..string.format("%.3f",idt*(elapsed/idt)^(mx/w)).."s: "..string.format("%.4f/s",rates[mx] or 0),max(0,min(mx-90,w-180)),max(0,min(my-20,h-20)),180,"center")
	lastDraw=t
end

function love.update(dt)
	local t=tick()
	local ldt=log(t-t0)-log(idt)
	local count=0
	local currentMaxRate=0
	local currentData=data[#data]
	for x=1,w do
		local history=idt*exp(ldt*x/w)
		local lowerLimit=t-history
		while currentData and currentData>=lowerLimit do
			count=count+1
			currentData=data[#data-count]
		end
		local rate=count/history
		if history>=0.4 and rate>currentMaxRate then
			currentMaxRate=rate
		end
		rates[x]=rate
	end
	imaxRate=currentMaxRate+(imaxRate-currentMaxRate)*0.2^dt
	idt=dt+(idt-dt)*0.1^dt
end

function love.mousepressed(x,y,b)
	if b=="l" then
		data[#data+1]=tick()
	end
end

function love.keypressed(k)
	if k=="escape" then
		love.event.quit()
	end
end

function love.resize(x,y)
	w,h=x,y
end
