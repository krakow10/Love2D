--Made by xXxMoNkEyMaNxXx
local version=0.1
local effect=love.graphics.newPixelEffect(love.filesystem.read'Mandelbrot.glsl')

local max=math.max
local floor=math.floor
local format=string.format

local acc=7
local ratio=10^acc

local function fix(n10)
	local n={}
	for i,pp in next,n10 do
		local mpp=pp%ratio
		local fpp=floor(mpp)
		if i>1 then
			n[i]=(n[i] or 0)+fpp
			n[i-1]=(n[i-1] or 0)+(pp-mpp)/ratio
		else
			n[i]=(n[i] or 0)+floor(pp)
		end
		n[i+1]=(n[i+1] or 0)+(mpp-fpp)*ratio
	end
	local ret={}
	for i=1,acc do
		ret[i]=n[i] or 0
	end
	return ret
end

local mt={}
function mt:__index(i)
	return self[i] or 0
end
function mt:__newindex(i,v)
	if i>1 then
		local mpp=v%ratio
		local fpp=floor(mpp)
		rawset(self,i,fpp)
	else
		--
	end
end

local x10={
	new=function(n,pow)
		local t={0,0,0,0,0,0,0,0,0,0}
		t[pow or 1]=n
		return t
	end,
	add=function(n1,n2)
		local n={0,0,0,0,0,0,0,0,0,0}
		for i=1,acc do
			n[i]=n1[i]+n2[i]
		end
		return fix(n)
	end,
	sub=function(n1,n2)
		local n={0,0,0,0,0,0,0,0,0,0}
		for i=1,acc do
			n[i]=n1[i]-n2[i]
		end
		return fix(n)
	end,
	mul=function(n1,n2)
		local n={0,0,0,0,0,0,0,0,0,0}
		for i1=1,acc do
			for i2=1,acc do
				local ni=i1+i2
				local pp=n1[i1]*n2[i2]
				local mpp=pp%ratio
				local fpp=floor(mpp)
				n[ni-1]=n[ni-1]+(pp-mpp)/ratio
				if ni<=acc then
					n[ni]=n[ni]+fpp
					if ni<acc then
						n[ni+1]=n[ni+1]+(mpp-fpp)*ratio
					end
				end
			end
		end
		return fix(n)
	end,
	mulnum=function(n1,n2)
		local n={0,0,0,0,0,0,0,0,0,0}
		for i1=1,#n1 do
			local pp=n1[i1]*n2
			local fpp=pp%ratio
			n[i1]=n[i1]+fpp
			if i1>1 then
				n[i1-1]=n[i1-1]+(pp-fpp)/ratio
			end
			if i1<#n1 then
				n[i1+1]=n[i1+1]+(fpp-floor(fpp))*ratio
			end
		end
		return n
	end,
	tostring=function(n)
		local s=tostring(floor(n[1])).."."
		for i=2,acc do
			s=s..format("%010i",floor(n[i]))
		end
		return s
	end
}

local vs={love.graphics.getWidth(),love.graphics.getHeight()}
local pos={x10.new(-2),x10.new(-1)}
local view={x10.new(3),x10.new(2)}
local maxi=100

effect:send("vs",vs)
effect:send("maxi",maxi)
function send_x10(name,val)
	for i=1,#val do
		effect:send(name..i,val[i])
	end
end
send_x10("posx",pos[1])
send_x10("posy",pos[2])
send_x10("viewx",view[1])
send_x10("viewy",view[2])
local setEffect=love.graphics.setPixelEffect

local rect=love.graphics.rectangle
local print2=love.graphics.print
function love.draw()
	--setEffect(effect)
	--rect("fill",0,0,vs[1],vs[2])
	--setEffect()
	print2("Pos.x="..x10.tostring(pos[1]),0,0)
	print2("Pos.y="..x10.tostring(pos[2]),0,20)
	print2("View.x="..x10.tostring(view[1]),0,60)
	print2("View.y="..x10.tostring(view[2]),0,80)
end

local isBtn=love.mouse.isDown
local isKey=love.keyboard.isDown
local getp=love.mouse.getPosition
local setc=love.graphics.setCaption
local fps=love.timer.getFPS

local grab
local zoomsec=0.8
function love.update(t)
	local mx,my=getp()
	if isKey'i' then
		local newview={x10.mulnum(view[1],zoomsec^t),x10.mulnum(view[2],zoomsec^t)}
		pos={x10.add(pos[1],x10.mulnum(x10.sub(view[1],newview[1]),0.5)),x10.add(pos[2],x10.mulnum(x10.sub(view[2],newview[2]),0.5))}
		view=newview
		send_x10("posx",pos[1])
		send_x10("posy",pos[2])
		send_x10("viewx",view[1])
		send_x10("viewy",view[2])
	elseif isKey'o' then
		local newview={x10.mulnum(view[1],zoomsec^-t),x10.mulnum(view[2],zoomsec^-t)}
		pos={x10.add(pos[1],x10.mulnum(x10.sub(view[1],newview[1]),0.5)),x10.add(pos[2],x10.mulnum(x10.sub(view[2],newview[2]),0.5))}
		view=newview
		send_x10("posx",pos[1])
		send_x10("posy",pos[2])
		send_x10("viewx",view[1])
		send_x10("viewy",view[2])
	end
	if isBtn'l' then
		if not grab then
			grab={mx,my}
		end
		send_x10("posx",x10.sub(pos[1],x10.mulnum(view[1],(mx-grab[1])/vs[1])))
		send_x10("posy",x10.add(pos[2],x10.mulnum(view[2],(my-grab[2])/vs[2])))
	else
		if grab then
			local temp={x10.sub(pos[1],x10.mulnum(view[1],(mx-grab[1])/vs[1])),x10.add(pos[2],x10.mulnum(view[2],(my-grab[2])/vs[2]))}
			send_x10("posx",temp[1])
			send_x10("posy",temp[2])
			pos=temp
			grab=nil
		end
	end
	setc("Mandelbrot Explorer v"..version.." - "..fps().." FPS")
end

local zoomstep=0.94
function love.mousepressed(_,_,button)
	if button=="wu" then
		local newview={x10.mulnum(view[1],zoomstep),x10.mulnum(view[2],zoomstep)}
		pos={x10.add(pos[1],x10.mulnum(x10.sub(view[1],newview[1]),0.5)),x10.add(pos[2],x10.mulnum(x10.sub(view[2],newview[2]),0.5))}
		view=newview
		send_x10("posx",pos[1])
		send_x10("posy",pos[2])
		send_x10("viewx",view[1])
		send_x10("viewy",view[2])
	elseif button=="wd" then
		local newview={x10.mulnum(view[1],1/zoomstep),x10.mulnum(view[2],1/zoomstep)}
		pos={x10.add(pos[1],x10.mulnum(x10.sub(view[1],newview[1]),0.5)),x10.add(pos[2],x10.mulnum(x10.sub(view[2],newview[2]),0.5))}
		view=newview
		send_x10("posx",pos[1])
		send_x10("posy",pos[2])
		send_x10("viewx",view[1])
		send_x10("viewy",view[2])
	end
end
