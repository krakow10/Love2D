--By xXxMoNkEyMaNxXx
local max,min=math.max,math.min

local vec=require'vec'

local mat={}

function mat.mulVec(m,v)
	local new=vec.mulNum(m[1],v[1])
	for a=2,min(#m,#v) do
		new=vec.add(new,vec.mulNum(m[a],v[a]))
	end
	return new
end

function mat.mulMat(a,b)
	local new={mat.mulVec(a,b[1])}
	for d=2,#b do
		new[d]=mat.mulVec(a,b[d])
	end
	return new
end

function mat.toObject(m,v)
	local new={}
	for d=1,#m do
		new[d]=vec.dot(m[d],v)
	end
	return new
end

function mat.tostring(m)
	local ms=vec.tostring(m[1])
	for d=2,#m do
		ms=ms.."\n"..vec.tostring(m[d])
	end
	return ms
end

return mat
