local rawset,sqrt,concat,newClass,TYPE=rawset,sqrt,concat,newClass,TYPE
local name="Vector2"
module(...)
newClass(_M,name,{
	Methods={
		lerp=function(v1,v2)
			local delta=v2-v1
			return function(t)
				return v1+delta*t
			end
		end,
		Dot=function(v1,v2)--I'll give it dot :U
			return v1.x*v2.x+v1.y*v2.y
		end,
		unpack=function(v)
			return v.x,v.y
		end
	},
	ReadOnly={
		unit=function(v)
			local u=v/v.magnitude
			rawset(v.ReadOnly,"unit",u)
			return u
		end,
		magnitude=function(v)
			local m=sqrt(v.x^2+v.y^2)
			rawset(v.ReadOnly,"magnitude",m)
			return m
		end
	},
	Properties={},
	metatable={
		__add=function(v1,v2)
			return new(v1.x+v2.x,v1.y+v2.y)
		end,
		__sub=function(v1,v2)
			return new(v1.x-v2.x,v1.y-v2.y)
		end,
		__mul=function(v1,v2)
			local t1,t2=TYPE(v1),TYPE(v2)
			if t1==name and t2==name then
				return new(v1.x*v2.x,v1.y*v2.y)
			elseif t1==name and t2=="number" then
				return new(v1.x*v2,v1.y*v2)
			elseif t1=="number" and t2==name then
				return new(v1*v2.x,v1*v2.y)
			end
		end,
		__div=function(v1,v2)
			local t1,t2=TYPE(v1),TYPE(v2)
			if t1==name and t2==name then
				return new(v1.x/v2.x,v1.y/v2.y)
			elseif t1==name and t2=="number" then
				return new(v1.x/v2,v1.y/v2)
			elseif t1=="number" and t2==name then
				return new(v1/v2.x,v1/v2.y)
			end
		end,
		__eq=function(v1,v2)
			return TYPE(v1)==name and TYPE(v2)==name and v1.x==v2.x and v1.y==v2.y
		end,
		__unm=function(v)
			return new(-v.x,-v.y)
		end,
		__tostring=function(v)
			return concat({v:unpack()},", ")
		end
	},
},function(v,x,y)
	v.x=x or 0
	v.y=y or 0
end)
