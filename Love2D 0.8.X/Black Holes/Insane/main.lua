--By xXxMoNkEyMaNxXx
require'lib/cmath'

local abs=math.abs
local sqrt=math.sqrt
local cabs=cmath.abs
local csqrt=cmath.sqrt
local cpow=cmath.pow

local sort=table.sort

local acc=1e-6
local e0=(1+cmath.i*sqrt(3))/2
local e1=(1-cmath.i*sqrt(3))/2
local function Zeroes(a0,a1,a2,a3,a4)
	a0,a1,a2,a3,a4=a0 or 0,a1 or 0,a2 or 0,a3 or 0,a4 or 0
	local ans={}
	if not a4 or abs(a4)<=acc then
		if not a3 or abs(a3)<=acc then
			if not a2 or abs(a2)<=acc then
				ans[1]=-a0/a1
			else
				local p1=-a1/(2*a2)
				local rcnd=a1^2-4*a0*a2
				if rcnd>=0 then
					local p2=sqrt(rcnd)/(2*a2)
					if p2==0 then
						ans[1]=p1
					else
						ans[1]=p1+p2
						ans[2]=p1-p2
					end
				end
			end
		else
			local p1=-2*a2^3+9*a1*a2*a3-27*a0*a3^2
			local p2=3*a1*a3-a2^2
			local p3=csqrt(4*p2^3+p1^2)
			local p4=cpow(0.5*(p1+p3),1/3)
			ans[1]=(-a2+p4-p2/p4)/(3*a3)
			ans[2]=(-a2-e0*p4+e1*p2/p4)/(3*a3)
			ans[3]=(-a2-e1*p4+e0*p2/p4)/(3*a3)
		end
	else
		local v1=3*a4
		local p1=2*a2^3-9*a3*a2*a1+9*v1*a1^2+27*a3^2*a0-24*v1*a2*a0
		local v2=a2^2-3*a3*a1+12*a4*a0
		local p2=(0.5*(p1+csqrt(p1*p1-4*v2*v2*v2)))^(1/3)
		local p3=v2/(v1*p2)+p2/v1
		local p4=0.5*csqrt(a3*a3/(4*a4*a4)-2*a2/v1+p3)
		local p5=a3*a3/(2*a4*a4)-4*a2/v1-p3
		local p6=(4*a3*a2/(a4*a4)-a3*a3*a3/(a4*a4*a4)-8*a1/a4)/(8*p4)
		local p7=-a3/(4*a4)
		local p8=0.5*csqrt(p5-p6)
		local p9=0.5*csqrt(p5+p6)
		ans[1]=p7-p4-p8
		ans[2]=p7-p4+p8
		ans[3]=p7+p4-p9
		ans[4]=p7+p4+p9
	end
	local roots={}
	for _,c in next,ans do
		local x=cabs(c)
		if abs(a0+x*(a1+x*(a2+x*(a3+x*a4))))<=acc then
			roots[#roots+1]=x
		elseif abs(a0-x*(a1-x*(a2-x*(a3-x*a4))))<=acc then
			roots[#roots+1]=-x
		elseif cabs(a0+c*(a1+c*(a2+c*(a3+c*a4))))<=acc then
			roots[#roots+1]=c
		end
	end
	sort(roots,function(a,b)
		local ta,tb=type(a),type(b)
		if ta=="number" and tb=="number" then
			return a<b
		elseif ta=="number" then
			return true
		elseif tb=="number" then
			return false
		elseif a and b then
			return cabs(a)<cabs(b)
		end
	end)
	return roots
end

local sin=math.sin
local cos=math.cos
local atan2=math.atan2

local G=6.67398e-11
local c=299792458
local M=1.98e30

local rs=2*G*M/c^2

local vs={love.graphics.getWidth(),love.graphics.getHeight()}

local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect

local getPos=love.mouse.getPosition

local bh={vs[1]/2,vs[2]/2}

local simlen=10
local simsize={128,64}
local shader=love.graphics.newPixelEffect(love.filesystem.read'GPU.frag')
shader:send("vs",vs)
shader:send("rs",rs)
shader:send("pos",bh)
shader:send("sim",simlen)
love.graphics.setColor(255,255,255,255)

local function sqr(v)
	return v[1]*v[1]+v[2]*v[2]
end
local function dot(v1,v2)
	return v1[1]*v2[1]+v1[2]*v2[2]
end

local line=love.graphics.line
local rect=love.graphics.rectangle
local GPU=love.graphics.newCanvas(simsize[1],simsize[2])
local getPixel=GPU:getImageData().getPixel

function love.draw()
	--b is inf because there is no time to light
	--local u1,u2,u3=Zeroes(b^-2-a^-2,rs/a^2,-1,rs)
	local mpos={getPos()}
	local diff={mpos[1]-bh[1],vs[2]-bh[2]}
	local a=sqr(diff)*sqrt(1-(diff[2]*diff[2]/sqr(diff)))
	local u1,u2,u3=unpack(Zeroes(-a^-2,rs/a^2,-1,rs))
	u1,u2,u3=u1 or 0,u2 or 0,u3 or 0
	local U1=cabs(u1)
	local U21=cabs(u2-u1)
	local U31=cabs(u3-u1)
	shader:send("u1",U1)
	shader:send("u21",U21)
	shader:send("u31",U31)
	setCanvas(GPU)
	setEffect(shader)
	rect("fill",0,0,simsize[1],simsize[2])
	setEffect()
	setCanvas()
	--mappixel except on regular canvas
	local data=GPU:getImageData()
	local d=atan2(vs[2]-bh[2],mpos[1]-bh[1])
	local prev
	local ogm
	for y=0,simsize[2]-1 do
		for x=0,simsize[1]-1 do
			local t=d+simlen*(y*simsize[1]+x)/(simsize[1]*simsize[2])
			--print(getPixel(data,x,y))
			local r=255/getPixel(data,x,y)
			local point={bh[1]+r*cos(t),bh[2]+r*sin(t)}
			if prev then
				line(prev[1],prev[2],point[1],point[2])
			end
			prev=point
			ogm=r
		end
	end
	print(ogm)
end
