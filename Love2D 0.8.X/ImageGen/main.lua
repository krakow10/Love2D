local img=love.image.newImageData

function smap(OX,OY,SX,SY)
	return OX/16,OY/8,1+SX/32,1+SY/16
end
function gmap(x,y)
	return x/4,y/3
end

map=[[
HeadU
0,0=2,0,2,2
1,0=4,2,-2,-2

HeadD
0,1=4,0,2,2
1,1=6,2,-2,-2

HeadF
0,2=2,2,2,2
1,2=4,4,-2,-2

HeadR
2,0=0,2,2,2
3,0=2,4,-2,-2

HeadL
2,1=4,2,2,2
3,1=6,4,-2,-2

HeadB
2,2=6,2,2,2
3,2=8,4,-2,-2
]]
---[[
local texturemap=img(4,3)
texturemap:mapPixel(function(x,y)
	local d1,d2,d3,d4=map:match(x..","..y.."=(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)")
	if d1 and d2 and d3 and d4 then
		local ox,oy,sx,sy=smap(tonumber(d1),tonumber(d2),tonumber(d3),tonumber(d4))
		return 255*ox,255*oy,255*sx,255*sy
	end
end)
texturemap:encode'map.png'
--]]

function svert(x,y,z,t)
	return 0.5+x/2,0.5+y/2,0.5+z/2,t
end
function gvert(x,y)
	return x/4,y/4
end

vert=[[
0,0=1,1,1,0
1,0=-1,1,1,0
0,1=1,1,-1,0
1,1=-1,1,-1,0

0,2=1,1,1,1
1,2=-1,1,1,1
0,3=1,1,-1,1
1,3=-1,1,-1,1

2,0=1,-1,1,0
3,0=-1,-1,1,0
2,1=1,-1,-1,0
3,1=-1,-1,-1,0

2,2=1,-1,1,1
3,2=-1,-1,1,1
2,3=1,-1,-1,1
3,3=-1,-1,-1,1
]]

---[[
local vertices=img(4,4)
vertices:mapPixel(function(x,y)
	local d1,d2,d3,d4=vert:match(x..","..y.."=(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)")
	if d1 and d2 and d3 and d4 then
		local ox,oy,sx,sy=svert(tonumber(d1),tonumber(d2),tonumber(d3),tonumber(d4))
		return 255*ox,255*oy,255*sx,255*sy
	end
end)
vertices:encode'vertices.png'
--]]

function gpairs(x,y)
	return x/20,y
end

pair=[[
--Vertex pairs--

Top of head
0,0=0,0,0,2
1,0=1,0,1,2
2,0=0,1,0,3
3,0=1,1,1,3

Bottom of head
4,0=2,0,2,2
5,0=3,0,3,2
6,0=2,1,2,3
7,0=3,1,3,3

----------------

--Texture pairs--
HeadU
8,0=0,0,0,0
9,0=1,0,1,0

HeadD
10,0=0,1,0,1
11,0=1,1,1,1

HeadF
12,0=0,2,0,2
13,0=1,2,1,2

HeadB
14,0=2,2,2,2
15,0=3,2,3,2

HeadR
16,0=2,0,2,0
17,0=3,0,3,0

HeadL
18,0=2,1,2,1
19,0=3,1,3,1
-----------------

]]
---[[
local pairs=img(20,1)
pairs:mapPixel(function(x,y)
	local d1,d2,d3,d4=pair:match(x..","..y.."=(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)")
	if d1 and d2 and d3 and d4 then
		local f=x<8 and gvert or gmap
		local ox,oy=f(tonumber(d1),tonumber(d2))
		local sx,sy=f(tonumber(d3),tonumber(d4))
		return 255*ox,255*oy,255*sx,255*sy
	end
end)
pairs:encode'pairs.png'
--]]

prism=[[
HeadU
0,0=2,3,0,8
1,0=1,0,3,9

HeadD
2,0=6,7,4,10
3,0=5,4,7,11

HeadF
4,0=0,1,4,12
5,0=5,4,1,13

HeadB
6,0=3,2,7,14
7,0=6,7,2,15

HeadR
8,0=2,0,6,16
9,0=4,6,0,17

HeadL
10,0=1,3,5,18
11,0=7,5,3,19


]]

---[[
local prisms=img(12,1)
prisms:mapPixel(function(x,y)
	local d1,d2,d3,d4=prism:match(x..","..y.."=(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)")
	if d1 and d2 and d3 and d4 then
		local ox,oy,sx=gpairs(tonumber(d1)),gpairs(tonumber(d2)),gpairs(tonumber(d3))
		local sy=gpairs(tonumber(d4))
		return 255*ox,255*oy,255*sx,255*sy
	end
end)
prisms:encode'prisms.png'
--]]

love.event.quit()
