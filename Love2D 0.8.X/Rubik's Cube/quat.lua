--By xXxMoNkEyMaNxXx
local function add(q1,q2)
	return {q1[1]+q2[1],q1[2]+q2[2],q1[3]+q2[3],q1[4]+q2[4]}
end
local function sub(q1,q2)
	return {q1[1]-q2[1],q1[2]-q2[2],q1[3]-q2[3],q1[4]-q2[4]}
end
local function mulNum(q,n)
	return {q[1]*n,q[2]*n,q[3]*n,q[4]*n}
end
local function mulVec(q,v)
	local a,b,c,d=q[1],q[2],q[3],q[4]
	local x,y,z=v[1],v[2],v[3]
	local e1,e2,e3=2*(c*z-d*y+a*x),2*(d*x-b*z+a*y),2*(b*y-c*x+a*z)
	return {x+c*e3-d*e2,y+d*e1-b*e3,z+b*e2-c*e1}
end
local function mul(q1,q2)
	local a1,a2,a3,a4=q1[1],q1[2],q1[3],q1[4]
	local b1,b2,b3,b4=q2[1],q2[2],q2[3],q2[4]
	return {
		a1*b1-a2*b2-a3*b3-a4*b4,
		a1*b2+a2*b1+a3*b4-a4*b3,
		a1*b3-a2*b4+a3*b1+a4*b2,
		a1*b4+a2*b3-a3*b2+a4*b1,
	}
end
local function divNum(q,n)
	return {q[1]/n,q[2]/n,q[3]/n,q[4]/n}
end
local function conj(q)
	return {q[1],-q[2],-q[3],-q[4]}
end
local function sqrlen(q)
	local a,b,c,d=q[1],q[2],q[3],q[4]
	return a*a+b*b+c*c+d*d
end
local function inv(q)
	local a,b,c,d=q[1],q[2],q[3],q[4]
	local l=a*a+b*b+c*c+d*d
	return {a/l,-b/l,-c/l,-d/l}
end

local sqrt=math.sqrt
local function length(q)
	local a,b,c,d=q[1],q[2],q[3],q[4]
	return sqrt(a*a+b*b+c*c+d*d)
end
local function normalize(q)
	local a,b,c,d=q[1],q[2],q[3],q[4]
	local l=sqrt(a*a+b*b+c*c+d*d)
	if l>0 then
		return {a/l,b/l,c/l,d/l}
	else
		return {1,0,0,0}
	end
end

local cos,sin=math.cos,math.sin
local function axisAngleP(u)
	local x,y,z=u[1],u[2],u[3]
	local t=sqrt(x*x+y*y+z*z)
	if t>0 then
		local s=sin(t)/t
		return {cos(t),x*s,y*s,z*s}
	else
		return {1,0,0,0}
	end
end
--[[
local acos,asin=math.acos,math.asin
local function polar(q)
	--
end
local function pow(q,n)
	--
end
--]]
return {
	add=add,
	sub=sub,
	mul=mul,
	inv=inv,
	conj=conj,
	mulNum=mulNum,
	mulVec=mulVec,
	divNum=divNum,
	length=length,
	sqrlen=sqrlen,
	normalize=normalize,
	axisAngleP=axisAngleP,
}
