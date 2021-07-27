local vec={}

local min=math.min
local max=math.max

function vec.add(a,b)
	local new={}
	for d=1,max(#a,#b) do
		new[d]=(a[d] or 0)+(b[d] or 0)
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

function vec.mulNum(a,b)
	local new={}
	for d=1,#a do
		new[d]=a[d]*b
	end
	return new
end

function vec.divNum(a,b)
	local new={}
	for d=1,#a do
		new[d]=a[d]/b
	end
	return new
end

function vec.dot(a,b)
	local new=0
	for d=1,min(#a,#b) do--Rest wil lbe 0
		new=new+a[d]*b[d]
	end
	return new
end

function vec.cross(a,b)
	if #a==3 and #b==3 then
		return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}
	else
		error'Cross product is only computable with vec3s.'
	end
end

function vec.tostring(a)
	local new=tostring(a[1])
	for d=2,#a do
		new=new..", "..tostring(a[d])
	end
	return new
end

_G.vec=vec
