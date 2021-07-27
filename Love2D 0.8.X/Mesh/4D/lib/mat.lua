--requires vec

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

function mat.tostring(a)
	local new=vec.tostring(a[1])
	for d=2,#a do
		new=new.."\n"..vec.tostring(a[d])
	end
	return new
end

_G.mat=mat
