local bitmap=require'tbitmap'

local function convert_4320_2160(inpath,outpath)
	local inimg=love.graphics.newImage(inpath):getData()
	local outbmp=bitmap.new(3840,2160)
	local getpixel=inimg.getPixel
	local setpixel=outbmp.setpixel
	for x=0,3840-1 do
		for y=0,2160-1 do
			local r1,g1,b1,a1=getpixel(inimg,2*x+1,2*y+1)
			local r2,g2,b2,a2=getpixel(inimg,2*x,2*y+1)
			local r3,g3,b3,a3=getpixel(inimg,2*x+1,2*y)
			local r4,g4,b4,a4=getpixel(inimg,2*x,2*y)
			setpixel(outbmp,x+1,2160-y,(r1+r2+r3+r4)/1020,(g1+g2+g3+g4)/1020,(b1+b2+b3+b4)/1020)
		end
	end
	outbmp:save(outpath)
end

local function convert_4320_1440(inpath,outpath)
	local inimg=love.graphics.newImage(inpath):getData()
	local outbmp=bitmap.new(2560,1440)
	local getpixel=inimg.getPixel
	local setpixel=outbmp.setpixel
	for x=0,2560-1 do
		for y=0,1440-1 do
			local r1,g1,b1,a1=getpixel(inimg,3*x+2,3*y+2)
			local r2,g2,b2,a2=getpixel(inimg,3*x+1,3*y+2)
			local r3,g3,b3,a3=getpixel(inimg,3*x,3*y+2)
			local r4,g4,b4,a4=getpixel(inimg,3*x+2,3*y+1)
			local r5,g5,b5,a5=getpixel(inimg,3*x+1,3*y+1)
			local r6,g6,b6,a6=getpixel(inimg,3*x,3*y+1)
			local r7,g7,b7,a7=getpixel(inimg,3*x+2,3*y)
			local r8,g8,b8,a8=getpixel(inimg,3*x+1,3*y)
			local r9,g9,b9,a9=getpixel(inimg,3*x,3*y)
			setpixel(outbmp,x+1,1440-y,(r1+r2+r3+r4+r5+r6+r7+r8+r9)/2295,(g1+g2+g3+g4+g5+g6+g7+g8+g9)/2295,(b1+b2+b3+b4+b5+b6+b7+b8+b9)/2295)
		end
	end
	outbmp:save(outpath)
end

convert_4320_1440("1440on4k/game.jpg","E:/Documents/Love2D/Love2D 0.10.X/1440 on 4k/1440on4k/game_1440.bmp")
convert_4320_2160("1440on4k/game.jpg","E:/Documents/Love2D/Love2D 0.10.X/1440 on 4k/1440on4k/game_2160.bmp")
