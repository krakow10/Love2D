--By Trey Reynolds
local bitmap	={}
local char		=string.char
local byte		=string.byte
local sub		=string.sub
local rep		=string.rep
local concat	=table.concat
local open		=io.open
--local setmt		=setmetatable

local function writeint(n)
	local r0=n%256
	n=(n-r0)/256
	local r1=n%256
	n=(n-r1)/256
	local r2=n%256
	n=(n-r2)/256
	local r3=n%256
	return char(r0,r1,r2,r3)
end

local function save(self,path,gamma)
	local h=self.h
	local w=self.w
	local gamma=gamma==nil and self.gamma or gamma
	local rlist=self.r
	local glist=self.g
	local blist=self.b
	local n=1
	local excess=-3*w%4
	local bytes=h*(3*w+excess)
	if 2^32-1<bytes then
		--error("file is too big to save")
		return nil,"file is too big to save"
	end
	local lineend=rep('\0',excess)
	local bmp={
		"BM"									--Header
		..writeint(54+bytes)					--Total file size.
		.."\0\0\0\0\54\0\0\0\40\0\0\0"			--40 defines color definition size
		..writeint(w)..writeint(h)				--Width by height
		.."\1\0\24\0\0\0\0\0"					--Defines 24 bit color
		..writeint(bytes)						--Total pixel byte length
		.."\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"	--Space that we don't use
	}
	for i=1,h do
		for j=1,w do
			local r,g,b
			if gamma then
				--So wrong.
				r=255*rlist[(i-1)*w+j]^(1/2.2)
				g=255*glist[(i-1)*w+j]^(1/2.2)
				b=255*blist[(i-1)*w+j]^(1/2.2)
			else
				r=255*rlist[(i-1)*w+j]
				g=255*glist[(i-1)*w+j]
				b=255*blist[(i-1)*w+j]
			end
			n=n+1
			--char automatically rounds to nearest integer
			bmp[n]=char((b~=b or b<0) and 0 or b<255 and b or 255,
				(g~=g or g<0) and 0 or g<255 and g or 255,
				(r~=r or r<0) and 0 or r<255 and r or 255)
		end
		n=n+1
		bmp[n]=lineend
	end
	local data=concat(bmp)
	if path then
		local file=open(path,"wb")
		file:write(data)
		file:close()
	end
	return data
end

local function newblank(w,h)
	local rlist={}
	local glist={}
	local blist={}
	local newbitmap={
		w=w;
		h=h;
		save=save;
		r=rlist;
		g=glist;
		b=blist;
		--These are hard coded in here to speed up the Lua version
		--Costs an extra 168 kb lol
		setpixel=function(self,x,y,r,g,b)
			x=x+0.5-(x+0.5)%1
			y=y+0.5-(y+0.5)%1
			if 1<=x and x<=w and 1<=y and y<=h then
				local p=(y-1)*w+x
				rlist[p]=r
				glist[p]=g
				blist[p]=b
			end
		end;
		getpixel=function(self,x,y)
			x=x+0.5-(x+0.5)%1
			y=y+0.5-(y+0.5)%1
			if 1<=x and x<=w and 1<=y and y<=h then
				local p=(y-1)*w+x
				return rlist[p],glist[p],blist[p]
			else
				return 0,0,0
			end
		end;
	}
	return newbitmap,rlist,glist,blist
end

local function readint(file,i)
	local r0,r1,r2,r3=byte(file,i,i+3)
	return r0+256*r1+65536*r2+16777216*r3
end

function bitmap.open(path,bmp)
	if not bmp then
		local file=open(path,"rb")
		bmp=file:read("*all")
		file:close()
	end
	if sub(bmp,1,2)~="BM" or readint(bmp,7)~=0 or readint(bmp,11)~=54 or readint(bmp,15)~=40 then
		--error("file is not supported")
		return nil,"file is not supported"
	end
	local w=readint(bmp,19)
	local h=readint(bmp,23)
	local newbitmap,rlist,glist,blist=newblank(w,h)
	newbitmap.gamma=gamma or false
	local rowbytes=3*w+-3*w%4
	for i=1,h do
		for j=1,w do
			local m=rowbytes*i+3*j+52-rowbytes
			local b,g,r=byte(bmp,m,m+2)
			local p=(i-1)*w+j
			if gamma then
				--This is so wrong.
				rlist[p]=(r/255)^2.2
				glist[p]=(g/255)^2.2
				blist[p]=(b/255)^2.2
			else
				rlist[p]=r/255
				glist[p]=g/255
				blist[p]=b/255
			end
		end
	end
	return newbitmap
end

function bitmap.new(w,h,r,g,b)
	w=w-w%1
	h=h-h%1
	r=r or 0
	g=g or 0
	b=b or 0
	local newbitmap,rlist,glist,blist=newblank(w,h)
	for i=1,h do
		for j=1,w do
			local p=(i-1)*w+j
			rlist[p]=r
			glist[p]=g
			blist[p]=b
		end
	end
	return newbitmap
end

return bitmap