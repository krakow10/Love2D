local type=type
local getmetatable=getmetatable
local setmetatable=setmetatable
local sqrt=math.sqrt

local vec3={}

local vec3_met={__type="vec3"}

local function TYPE(o)
	local t=type(o)
	if t=="table" then
		local m=getmetatable(o)
		if m then
			return m.__type or t
		end
	end
	return t
end


local function new(x,y,z)
	return setmetatable({x,y,z},vec3_met)
end
vec3.new=new

local function slow(f1,f2,f3)
	return function(a,b)
		local ta,tb=TYPE(a),TYPE(b)
		if ta=="vec3" and tb=="vec3" then
			return f1(a,b)
		elseif ta=="vec3" and tb=="number" then
			return f2(a,b)
		elseif ta=="number" and tb=="vec3" then
			return f3(b,a)
		else
			error("Could not do stuff Type1: "..ta.." Type2: "..tb)
		end
	end
end

local function unm(a)
	return new(-a[1],-a[2],-a[3])
end
vec3_met.__unm=unm

local function add(a,b)
	return new(a[1]+b[1],a[2]+b[2],a[3]+b[3])
end
local function addNum(a,b)
	return new(a[1]+b,a[2]+b,a[3]+b)
end
vec3_met.__add=slow(add,addNum,addNum) --xdxdxd

local function sub(a,b)
	return new(a[1]-b[1],a[2]-b[2],a[3]-b[3])
end
local function subNum(a,b)
	return new(a[1]-b,a[2]-b,a[3]-b)
end
local function muNbus(b,a)
	return new(a-b[1],a-b[2],a-b[3])
end
vec3_met.__sub=slow(sub,subNum,muNbus)


local function mul(a,b)
	return new(a[1]*b[1],a[2]*b[2],a[3]*b[3])
end
local function mulNum(a,b)
	return new(a[1]*b,a[2]*b,a[3]*b)
end
vec3_met.__mul=slow(mul,mulNum,mulNum)

local function div(a,b)
	return new(a[1]/b[1],a[2]/b[2],a[3]/b[3])
end
local function divNum(a,b)
	return new(a[1]/b,a[2]/b,a[3]/b)
end
local function muNvid(b,a)
	return new(a/b[1],a/b[2],a/b[3])
end
vec3_met.__div=slow(div,divNum,muNvid)

function vec3.dot(a,b)
	return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end
function vec3.cross(a,b)
	return new(a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1])
end
function vec3.magnitude(a)
	local x,y,z=a[1],a[2],a[3]
	return sqrt(x*x+y*y+z*z)
end
function vec3.normalize(a)
	local x,y,z=a[1],a[2],a[3]
	local m=sqrt(x*x+y*y+z*z)
	return new(x/m,y/m,z/m)
end

return vec3
