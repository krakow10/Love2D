local rawset,concat,newClass,TYPE=rawset,concat,newClass,TYPE
local name="Colour4"
module(...)
newClass(_M,name,{
	Methods={
		lerp=function(c1,c2)
			local delta=c2-c1
			return function(t)
				return c1+delta*t
			end
		end,
		unpack=function(c)
			return c.r,c.g,c.b,c.a
		end
	},
	ReadOnly={},
	Properties={},
	metatable={
		__add=function(c1,c2)
			return new(c1.r+c2.r,c1.g+c2.g,c1.b+c2.b,c1.a+c2.a)
		end,
		__sub=function(c1,c2)
			return new(c1.r-c2.r,c1.g-c2.g,c1.b-c2.b,c1.a-c2.a)
		end,
		__mul=function(c1,c2)
			local t1,t2=TYPE(c1),TYPE(c2)
			if t1=="number" and t2==name then
				return new(c1*c2.r,c1*c2.g,c1*c2.b,c1*c2.a)
			elseif t1==name and t2=="number" then
				return new(c1.r*c2,c1.g*c2,c1.b*c2,c1.a*c2)
			elseif t1==name and t2==name then
				return new(c1.r*c2.r/255,c1.g*c2.g/255,c1.b*c2.b/255,c1.a*c2.a/255)
			end
		end,
		__div=function(c1,c2)
			local t1,t2=TYPE(c1),TYPE(c2)
			if t1==name and t2=="number" then
				return new(c1.r/c2,c1.g/c2,c1.b/c2,c1.a/c2)
			elseif t1=="number" and t2==name then
				return new(c1/c2.r,c1/c2.g,c1/c2.b,c1/c2.a)
			elseif t1==name and t2==name then
				return new(c1.r/c2.r*255,c1.g/c2.g*255,c1.b/c2.b*255,c1.a/c2.a*255)
			end
		end,
		__unm=function(c)
			return new(-c.r,-c.g,-c.b,-c.a)
		end,
		__tostring=function(c)
			return concat({c:unpack()},", ")
		end
	}
},function(c,r,g,b,a)
	c.r=r or 255
	c.g=g or 255
	c.b=b or 255
	c.a=a or 255
end)
