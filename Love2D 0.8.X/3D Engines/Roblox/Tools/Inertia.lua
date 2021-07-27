local v=Vector3.new
local dot=Vector3.Dot
local abs=math.abs
module(...)
function moment(mass,size,axis)
	return mass*(abs(axis.x)*(size.y^2+size.z^2)+abs(axis.y)*(size.z^2+size.x^2)+abs(axis.z)*(size.x^2+size.y^2))/12
end
function moment1(obj,waxis,p0,acc)
	acc=acc or 6
	--local ac2=acc/2
	if obj.Class=="Brick" then
		local a=waxis*obj.Quaternion--axis in local coordinates
		local ux,uy,uz=(obj.Size/(2*acc)):unpack()--Unit size
		local um=ux*uy*uz--Mass of one unit
		--local aux,auy,auz=ax*ux,ay*uy,az*uz--pre-multiply um*(a dot (u*i))
		local I=0
		for ix=0.5,acc-0.5 do--multiplier_x
			for iy=0.5,acc-0.5 do
				for iz=0.5,acc-0.5 do
					local i=v(ux*ix,uy*iy,uz*iz)
					I=I+um*(a*dot(a,i)-i).square
				end
			end
		end
		return I*8*(waxis*dot(waxis,p0-obj.Pos)-p0).square--I only simulated one eighth of the cuboid; twice the accuracy with the same iterations
	end
end
