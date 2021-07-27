--By xXxMoNkEyMaNxXx
local max,min=math.max,math.min

local vec=require'vec'
local mat={}

function mat.make(d,a)
	local new={}
	for d1=1,d do
		new[d1]={}
		for d2=1,d do
			new[d1][d2]=a[d1+(d2-1)*d]
		end
	end
	return new
end

function mat.mulNum(a,b)
	local new={}
	for d1=1,#a do
		new[d1]={}
		for d2=1,#a[d1] do
			new[d1][d2]=a[d1][d2]*b
		end
	end
	return new
end

function mat.mulVec(a,b)
	local new=vec.mulNum(a[1],b[1])
	for d=2,#a do
		new=vec.add(new,vec.mulNum(a[d],b[d] or 0))
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

function mat.tsp(a)
	local new={}
	local size=1
	for d=1,#a do
		size=max(size,#a[d])
	end
	for d1=1,size do
		new[d1]={}
		for d2=1,#a do
			new[d1][d2]=a[d2][d1] or 0
		end
	end
	return new
end

function mat.det(a)
	--
end

function mat.tostring(a)
	local new=vec.tostring(a[1])
	for d=2,#a do
		new=new.."\n"..vec.tostring(a[d])
	end
	return new
end

_G.mat=mat
