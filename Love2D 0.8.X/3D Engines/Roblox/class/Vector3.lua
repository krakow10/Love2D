local rawset,sqrt,concat,newClass,TYPE,getmetatable=rawset,sqrt,concat,newClass,TYPE,getmetatable
local name="Vector3"
module(...)
newClass(_M,name,{
	Methods={
		lerp=function(v1,v2)
			local delta=v2-v1
			return function(t)
				return v1+delta*t
			end
		end,
		Dot=function(v1,v2)
			return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
		end,
		Cross=function(v1,v2)
			return new(v1.y*v2.z-v1.z*v2.y,v1.z*v2.x-v1.x*v2.z,v1.x*v2.y-v1.y*v2.x)
		end,
		unpack=function(v)
			return v.x,v.y,v.z
		end
	},
	ReadOnly={
		sum=function(v)
			local m=v.x+v.y+v.z
			rawset(v.ReadOnly,"sum",m)
			return m
		end,
		unit=function(v)
			local u=v/sqrt(v.x^2+v.y^2+v.z^2)
			rawset(v.ReadOnly,"unit",u)
			return u
		end,
		square=function(v)
			local m=v.x^2+v.y^2+v.z^2
			rawset(v.ReadOnly,"square",m)
			return m
		end,
		product=function(v)
			local m=v.x*v.y*v.z
			rawset(v.ReadOnly,"product",m)
			return m
		end,
		magnitude=function(v)
			local m=sqrt(v.x^2+v.y^2+v.z^2)
			rawset(v.ReadOnly,"magnitude",m)
			return m
		end
	},
	Properties={},
	metatable={
		__add=function(v1,v2)
			return new(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z)
		end,
		__sub=function(v1,v2)
			return new(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
		end,
		__mul=function(v1,v2)
			local t1,t2=TYPE(v1),TYPE(v2)
			if t1==name and t2==name then
				return new(v1.x*v2.x,v1.y*v2.y,v1.z*v2.z)
			elseif t1==name and t2=="number" then
				return new(v1.x*v2,v1.y*v2,v1.z*v2)
			elseif t1=="number" and t2==name then
				return new(v1*v2.x,v1*v2.y,v1*v2.z)
			else
				local v2m=getmetatable(v2)
				if v2m and TYPE(v2m)=="table" and v2m.__mul then
					return v2m.__mul(v1,v2)
				end
			end
		end,
		__div=function(v1,v2)
			local t1,t2=TYPE(v1),TYPE(v2)
			if t1==name and t2==name then
				return new(v1.x/v2.x,v1.y/v2.y,v1.z/v2.z)
			elseif t1==name and t2=="number" then
				return new(v1.x/v2,v1.y/v2,v1.z/v2)
			elseif t1=="number" and t2==name then
				return new(v1/v2.x,v1/v2.y,v1/v2.z)
			else
				local v2m=getmetatable(v2)
				if v2m and TYPE(v2m)=="table" and v2m.__div then
					return v2m.__div(v1,v2)
				end
			end
		end,
		__unm=function(v)
			return new(-v.x,-v.y,-v.z)
		end,
		__tostring=function(v)
			return concat({v:unpack()},", ")
		end
	}
},function(v,x,y,z)
	v.x=x or 0
	v.y=y or 0
	v.z=z or 0
end)
