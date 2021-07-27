local sin,cos,acos,sqrt,select,rawget,rawset,concat,newClass,TYPE=sin,cos,acos,sqrt,select,rawget,rawset,concat,newClass,TYPE
local Vector3=Vector3
local dot,cross=Vector3.Dot,Vector3.Cross
local name="Quaternion"
module(...)
newClass(_M,name,{
	Methods={
		ToMatrix=function(q)
			local w,x,y,z=q:unpack()
			return
			1-2*y^2-2*z^2,2*x*y-2*w*z,2*x*z+2*w*y,
			2*x*y+2*w*z,1-2*x^2-2*z^2,2*y*z-2*w*x,
			2*x*z-2*w*y,2*y*z+2*w*x,1-2*x^2-2*y^2
		end,
		ToAxisAngle=function(q,angle_separate)
			local w,x,y,z=q:unpack()
			if angle_separate then
				return Vector3.new(x,y,z).unit,2*acos(w)
			else
				return Vector3.new(x,y,z).unit*(2*(acos(w)+pi))
			end
		end,
		localize=function(q,v)
			local ux,uy,uz=q.ux,q.uy,q.uz
			return Vector3.new(dot(ux,v),dot(uy,v),dot(uz,v))
		end,
		lerp=function(q1,q2)
			local delta=q2-q1
			return function(t)
				return q1+delta*t
			end
		end,
		unpack=function(q)
			return q.w,q.x,q.y,q.z
		end
	},
	ReadOnly={
		v=function(q)
			local v=Vector3.new(select(2,q:unpack()))
			rawset(q.ReadOnly,"v",v)
			return v
		end,
		ux=function(q)-- Axes unit vectors; x
			local w,x,y,z=q:unpack()
			local a=Vector3.new(1-2*y^2-2*z^2,2*x*y+2*w*z,2*x*z-2*w*y)
			rawset(q,"ux",a)
			return a
		end,
		uy=function(q)-- Axes unit vectors; y
			local w,x,y,z=q:unpack()
			local a=Vector3.new(2*x*y-2*w*z,1-2*x^2-2*z^2,2*y*z+2*w*x)
			rawset(q,"uy",a)
			return a
		end,
		uz=function(q)-- Axes unit vectors; z
			local w,x,y,z=q:unpack()
			local a=Vector3.new(2*x*z+2*w*y,2*y*z-2*w*x,1-2*x^2-2*y^2)
			rawset(q,"uz",a)
			return a
		end,
		unit=function(q)
			local w,x,y,z=q:unpack()
			local u=q/sqrt(w^2+x^2+y^2+z^2)
			rawset(q.ReadOnly,"unit",u)
			return u
		end,
		magnitude=function(q)
			local w,x,y,z=q:unpack()
			local m=sqrt(w^2+x^2+y^2+z^2)
			rawset(q.ReadOnly,"magnitude",m)
			return m
		end
	},
	Properties={},
	metatable={
		__add=function(q1,q2)
			local w1,x1,y1,z1=q1:unpack()
			local w2,x2,y2,z2=q2:unpack()
			return new(w1+w2,x1+x2,y1+y2,z1+z2)
		end,
		__sub=function(q1,q2)
			local w1,x1,y1,z1=q1:unpack()
			local w2,x2,y2,z2=q2:unpack()
			return new(w1-w2,x1-x2,y1-y2,z1-z2)
		end,
		__mul=function(q1,q2)
			local t1,t2=TYPE(q1),TYPE(q2)
			if t1==name and t2==name then
				local w1,x1,y1,z1=q1:unpack()
				local w2,x2,y2,z2=q2:unpack()
				return new(
				w1*w2-x1*x2-y1*y2-z1*z2,
				w1*x2+x1*w2+y1*z2-z1*y2,
				w1*y2+y1*w2+z1*x2-x1*z2,
				w1*z2+z1*w2+x1*y2-y1*x2)
			elseif t1==name and t2=="number" then
				local w,x,y,z=q1:unpack()
				return new(w*q2,x*q2,y*q2,z*q2)
			elseif t1=="number" and t2==name then
				local w,x,y,z=q2:unpack()
				return new(q1*w,q1*x,q1*y,q1*z)
			elseif t1==name and t2=="Vector3" then
				local w,v=q1.w,q1.v
				return q2+cross(2*v,cross(v,q2)+w*q2)
			elseif t1=="Vector3" and t2==name then
				local w,v=q2.w,q2.v
				return q1+cross(2*v,cross(v,q1)+w*q1)
			else
				error("OMG: "..t1..", "..t2)
			end
		end,
		__div=function(q1,q2)
			local t1,t2=TYPE(q1),TYPE(q2)
			if t1==name and t2==name then
				--:U?
			elseif t1==name and t2=="number" then
				local w,x,y,z=q1:unpack()
				return new(w/q2,x/q2,y/q2,z/q2)
			elseif t1=="number" and t2==name then
				local w,x,y,z=q2:unpack()
				return new(q1/w,q1/x,q1/y,q1/z)
			end
		end,
		__tostring=function(q)
			return concat({q:unpack()},", ")
		end
	}
},function(q,w,x,y,z)
	q.w=w or 1
	q.x=x or 0
	q.y=y or 0
	q.z=z or 0
end)
identity=new()
FromAxisAngle=function(v,t)
	if t and v then
		return new(cos(t/2),(v*sin(t/2)):unpack())
	elseif v and v.magnitude>0 then
		local t=v.magnitude/2
		return new(cos(t),(v.unit*sin(t)):unpack())
	else
		return identity
	end
end
