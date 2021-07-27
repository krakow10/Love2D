local next=next
local env=getfenv()
local function using(namespace)
	for i,v in next,env[namespace] do
		env[i]=v
	end
end

using'math'
using'table'

c=require'lib/Class'
using'c'

local Vector3=require'class/Vector3'
local dot=Vector3.Dot

function moment(mass,size,axis)
	return mass*(abs(axis.x)^2*(size.y^2+size.z^2)+abs(axis.y)^2*(size.z^2+size.x^2)+abs(axis.z)^2*(size.x^2+size.y^2))/12
end
function calcmoment(mass,size,a,acc)
	local ux,uy,uz=(size/(2*acc)):unpack()--Unit size
	local um=mass/(2*acc)^3--ux*uy*uz--Mass of one unit
	--local aux,auy,auz=ax*ux,ay*uy,az*uz--pre-multiply um*(a dot (u*i))
	local I=0
	for ix=0.5,acc-0.5 do--multiplier_x
		for iy=0.5,acc-0.5 do
			for iz=0.5,acc-0.5 do
				local i=Vector3.new(ux*ix,uy*iy,uz*iz)
				I=I+um*(a*dot(a,i)-i).square
			end
		end
	end
	return I*8--*(waxis*dot(waxis,p0-obj.Pos)-p0).square--I only simulated one eighth of the cuboid; twice the accuracy with the same iterations
end

math.randomseed(os.time())
math.random()
local mass=12
local size=Vector3.new(1,2,7)
local axis=Vector3.new(0.013401080651917,0.16262584610748,0.9865967997187)--Vector3.new(math.random()-0.5,math.random()-0.5,math.random()-0.5).unit

print("Mass:",mass)
print("Size:",size)
print("Axis:",axis)
print(moment(mass,size,axis))
print(calcmoment(mass,size,axis,17))
