--By xXxMoNkEyMaNxXx
--doz elsez
local vec={}

local select=select

local sqrt=math.sqrt
local min,max=math.min,math.max

function vec.add(a,b)
	local new={}
	for d=1,max(#a,#b) do
		new[d]=(a[d] or 0)+(b[d] or 0)
	end
	return new
end
function vec.addNum(a,b)
	local new={}
	for d=1,#a do
		new[d]=a[d]+b
	end
	return new
end

function vec.sub(a,b)
	local new={}
	for d=1,max(#a,#b) do
		new[d]=(a[d] or 0)-(b[d] or 0)
	end
	return new
end
function vec.subNum(a,b)
	local new={}
	for d=1,#a do
		new[d]=a[d]-b
	end
	return new
end

function vec.mul(a,b,default)
	if default or #a==#b then
		local new={}
		for d=1,max(#a,#b) do
			new[d]=(a[d] or default)*(b[d] or default)
		end
		return new
	else
		error'#a is not equal to #b and no default was given.'
	end
end
function vec.mulNum(a,b)
	local new={}
	for d=1,#a do
		new[d]=a[d]*b
	end
	return new
end

function vec.div(a,b,default)
	if default or #a==#b then
		local new={}
		for d=1,max(#a,#b) do
			new[d]=(a[d] or default)/(b[d] or default)
		end
		return new
	else
		error'#a is not equal to #b and no default was given.'
	end
end
function vec.divNum(a,b)
	local new={}
	for d=1,#a do
		new[d]=a[d]/b
	end
	return new
end

function vec.max(...)
	local new=select(1,...)
	for i=2,select("#",...) do
		local v=select(i,...)
		for d=1,max(#new,#v) do
			if new[d] and v[d] then
				new[d]=max(new[d],v[d])
			elseif v[d] then
				new[d]=v[d]
			else
				break
			end
		end
	end
	return new
end
function vec.min(...)
	local new=select(1,...)
	for i=2,select("#",...) do
		local v=select(i,...)
		for d=1,max(#new,#v) do
			if new[d] and v[d] then
				new[d]=min(new[d],v[d])
			elseif v[d] then
				new[d]=v[d]
			else
				break
			end
		end
	end
	return new
end

function vec.dot(a,b)
	local new=0
	for d=1,min(#a,#b) do--Rest will be 0
		new=new+a[d]*b[d]
	end
	return new
end

function vec.sqrlen(a)
	local new=0
	for d=1,#a do
		local v=a[d]
		new=new+v*v
	end
	return new
end

function vec.length(a)
	local new=0
	for d=1,#a do
		local v=a[d]
		new=new+v*v
	end
	return sqrt(new)
end

function vec.normalize(a)
	local lsq=0
	for d=1,#a do
		local v=a[d]
		lsq=lsq+v*v
	end
	if lsq>0 then
		local l=sqrt(lsq)
		local new={}
		for d=1,#a do
			new[d]=a[d]/l
		end
		return new
	else
		return a
	end
end

function vec.cross(a,b)
	if #a==3 and #b==3 then
		return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}
	else
		error'Arbitrary dimension cross product not yet implemented.'
	end
end

function vec.tostring(a)
	local new=tostring(a[1])
	for d=2,#a do
		new=new..", "..tostring(a[d])
	end
	return new
end

return vec
