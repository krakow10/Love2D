local type,next,setmetatable,getmetatable=type,next,setmetatable,getmetatable
local print=print
module(...)
TYPE=function(o)
	if type(o)=="table" then
		return o.type or "table"
	else
		return type(o)
	end
end
--[[
local get=function(t,i,s)
	local v=t[i]
	if type(v)=="function" then
		return v(s)
	else
		return v
	end
end
--]]
copy=function(T)
	if type(T)=="table" then
		local Tc={}
		for i,v in next,T do
			if type(v)=="table" then
				Tc[i]=copy(v)
			else
				Tc[i]=v
			end
		end
		local Tmet=getmetatable(T)
		if Tmet then
			return setmetatable(Tc,Tmet)
		else
			return Tc
		end
	else
		return T
	end
end
local contents={
	Methods={},
	ReadOnly={},
	Properties={},
	metatable={}
}
local metatable={
	__index=function(s,i)--So that properties are fast
		local m,r,p=s.Methods[i],s.ReadOnly[i],s.Properties[i]
		if m then
			return m
		elseif r then
			if type(r)=="function" then
				return r(s)
			else
				return r
			end
		elseif p then
			return p
		end
	end,
	__newindex=function(s,i,v)
		if not s.ReadOnly[i] then
			if not s.Properties[i] and type(v)=="function" then--Ehh, for organization.
				s.Methods[i]=v
			else
				s.Properties[i]=v
			end
		end
	end
}
function newClass(container,name,aspects,setup)
	container.new=function(...)
		local class=copy(contents)
		for i,v in next,aspects do
			class[i]=copy(v) or class[i]
		end
		for i,v in next,metatable do
			class.metatable[i]=v
		end
		class.ReadOnly.type=name
		setmetatable(class,class.metatable)
		if setup then
			setup(class,...)
		end
		return class
	end
	return setmetatable(container,{__index=aspects.Methods})
end
