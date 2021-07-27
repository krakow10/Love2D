--By Quaternions
local next=next

local Vector3=require'vec3'
local vec3=Vector3.new
local dot=Vector3.dot
local cross=Vector3.cross
local mat=require'mat'

local isBtn=love.mouse.isDown
local getPos=love.mouse.getPosition

local isKey=love.keyboard.isDown

local setTitle=love.window.setTitle

local fps=love.timer.getFPS

local setCanvas=love.graphics.setCanvas

local View={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}
local pos=vec3(0,0,0)
local rot={{1,0,0},{0,1,0},{0,0,1}}

local speed=1

--[[ cube
local nlist={
	vec3(-1,0,0),
	vec3(0,-1,0),
	vec3(0,0,-1),
	vec3(1,0,0),
	vec3(0,1,0),
	vec3(0,0,1),
}
local llist={1,1,1,1,1,1}
--]]
---[[ bullet
local nlist={vec3(-0.44444444444444,-0.44444444444444,-0.77777777777778),vec3(-0.66666666666667,-0.33333333333333,-0.66666666666667),vec3(-0.8,0,-0.6),vec3(-0.66666666666667,0.33333333333333,-0.66666666666667),vec3(-0.44444444444444,0.44444444444444,-0.77777777777778),vec3(-0.33333333333333,-0.66666666666667,-0.66666666666667),vec3(-0.66666666666667,-0.66666666666667,-0.33333333333333),vec3(-1,0,0),vec3(-0.66666666666667,0.66666666666667,-0.33333333333333),vec3(-0.33333333333333,0.66666666666667,-0.66666666666667),vec3(0,-0.8,-0.6),vec3(0,-1,0),vec3(0,0,1),vec3(0,1,0),vec3(0,0.8,-0.6),vec3(0.33333333333333,-0.66666666666667,-0.66666666666667),vec3(0.66666666666667,-0.66666666666667,-0.33333333333333),vec3(1,0,0),vec3(0.66666666666667,0.66666666666667,-0.33333333333333),vec3(0.33333333333333,0.66666666666667,-0.66666666666667),vec3(0.44444444444444,-0.44444444444444,-0.77777777777778),vec3(0.66666666666667,-0.33333333333333,-0.66666666666667),vec3(0.8,0,-0.6),vec3(0.66666666666667,0.33333333333333,-0.66666666666667),vec3(0.44444444444444,0.44444444444444,-0.77777777777778)}
local llist={1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
--]]
--[[ random
local nlist={vec3(0.58841258486248,0.61901877140753,0.52017919087615),vec3(0.18020748345621,0.71754164435853,0.6727995626616),vec3(-0.83805749760029,0.43063485070684,0.33498247129162),vec3(-0.32133317719315,0.70201915852687,0.6355423591675),vec3(-0.14662638427807,0.83355227700785,0.53262679704327),vec3(-0.77107619719489,0.63578380068665,0.034935038341124),vec3(0.94832582700567,0.24157602153397,0.20571619200691),vec3(-0.64808400628823,0.42749448901766,0.63026627916534),vec3(-0.44612151608867,0.83944802363729,0.31032661583272),vec3(-0.055272473410801,0.77700843841779,0.62705888105552),vec3(0.15028358974804,0.69096775171873,0.70709151369339),vec3(-0.096513850811932,0.97888883708324,0.18017136630242),vec3(-0.44444444444444,-0.44444444444444,-0.77777777777778),vec3(-0.66666666666667,-0.33333333333333,-0.66666666666667),vec3(-0.8,0,-0.6),vec3(-0.66666666666667,0.33333333333333,-0.66666666666667),vec3(-0.44444444444444,0.44444444444444,-0.77777777777778),vec3(-0.33333333333333,-0.66666666666667,-0.66666666666667),vec3(-0.66666666666667,-0.66666666666667,-0.33333333333333),vec3(-1,0,0),vec3(-0.66666666666667,0.66666666666667,-0.33333333333333),vec3(-0.33333333333333,0.66666666666667,-0.66666666666667),vec3(0,-0.8,-0.6),vec3(0,-1,0),vec3(0,0,1),vec3(0,1,0),vec3(0,0.8,-0.6),vec3(0.33333333333333,-0.66666666666667,-0.66666666666667),vec3(0.66666666666667,-0.66666666666667,-0.33333333333333),vec3(1,0,0),vec3(0.66666666666667,0.66666666666667,-0.33333333333333),vec3(0.33333333333333,0.66666666666667,-0.66666666666667),vec3(0.44444444444444,-0.44444444444444,-0.77777777777778),vec3(0.66666666666667,-0.33333333333333,-0.66666666666667),vec3(0.8,0,-0.6),vec3(0.66666666666667,0.33333333333333,-0.66666666666667),vec3(0.44444444444444,0.44444444444444,-0.77777777777778)}
local llist={}
for i=1,#nlist do
	llist[i]=1
end
--]]

------------------------
--mesh vertex/edge/plane id translators
local function pe(a, b)
	if b < a then a, b = b, a end
	local i = a*2^16 + b
	return i
end

local function pv(a, b, c)
	if b < a then a, b = b, a end
	if c < b then b, c = c, b end
	if b < a then a, b = b, a end
	local r = a*2^32 + b*2^16 + c
	return r
end

local function ep(i)
	local b = i%2^16
	local a = (i - b)/2^16
	return a, b
end

local function vp(r)
	local c = r%2^16
	r = (r - c)/2^16
	local b = r%2^16
	local a = (r - b)/2^16
	return a, b, c
end

local function ev(i, j)
	local a, b = ep(i)
	local c, d = ep(j)
	if a == d or b == d then
		return pv(a, b, c)
	elseif a == c or b == c then
		return pv(a, b, d)
	end
end

local function ve(r)
	local a, b, c = vp(r)
	local i = pe(a, b)
	local j = pe(b, c)
	local k = pe(a, c)
	return i, j, k
end

--edge and vertex finder
local function map(meshn, meshl)
	--get the first edge
	local firste do
		local an = meshn[1]
		local bestb
		local bestd = -1
		for b = 2, #meshn do
			local bn = meshn[b]
			local d = dot(an, bn)--/(dot(an, an)*dot(bn, bn))^0.5
			if bestd < d then
				bestb = b
				bestd = d
			end
		end
		firste = pe(1, bestb)
	end
	--make the map
	local vert = {}
	local map = {}
	--traverse
	local nextedge = {firste}
	local stopedge = {}
	local nedges = 1
	local n = 0
	while n < nedges do
		n = n + 1
		local i = nextedge[n]
		if not stopedge[i] then
			stopedge[i] = true
			local a, b = ep(i)
			local an = meshn[a]
			local al = meshl[a]
			local bn = meshn[b]
			local bl = meshl[b]
			local anbn = dot(an, bn)
			local det = 1 - anbn*anbn
			local s = (al - anbn*bl)/det
			local t = (bl - anbn*al)/det
			local edgeo = s*an + t*bn
			local edged = cross(an, bn)
			local t0 = -1/0
			local t1 = 1/0
			local c, d
			for i = 1, #meshn do
				if i ~= a and i ~= b then
					local n = meshn[i]
					local l = meshl[i]
					local nd = dot(n, edged)
					local no = dot(n, edgeo)
					local t = (l - no)/nd
					if nd < -1e-8 then
						if t0 < t then
							t0 = t
							c = i
						end
					elseif 1e-8 < nd then
						if t < t1 then
							t1 = t
							d = i
						end
					end
				end
			end
			map[pe(a, b)] = pe(c, d)
			vert[pv(a, b, c)] = edgeo + t0*edged
			vert[pv(a, b, d)] = edgeo + t1*edged
			nextedge[nedges + 1] = pe(a, d)
			nextedge[nedges + 2] = pe(b, d)
			nedges = nedges + 2
		end
	end
	return vert, map
end

--function for stepping throught he algorithm

local function mapslow(meshn, meshl)
	--get the first edge
	local firste do
		local an = meshn[1]
		local bestb
		local bestd = -1
		for b = 2, #meshn do
			local bn = meshn[b]
			local d = dot(an, bn)--/(dot(an, an)*dot(bn, bn))^0.5
			if bestd < d then
				bestb = b
				bestd = d
			end
		end
		firste = pe(1, bestb)
	end
	--make the map
	local vert = {}
	local map = {}
	--traverse
	local nextedge = {firste}
	local stopedge = {}
	local nedges = 1
	local n = 0
	--while n < nedges do
	local function step()
		n = n + 1
		local i = nextedge[n]
		if not stopedge[i] then
			stopedge[i] = true
			local a, b = ep(i)
			local an = meshn[a]
			local al = meshl[a]
			local bn = meshn[b]
			local bl = meshl[b]
			local anbn = dot(an, bn)
			local det = 1 - anbn*anbn
			local s = (al - anbn*bl)/det
			local t = (bl - anbn*al)/det
			local edgeo = s*an + t*bn
			local edged = cross(an, bn)
			local t0 = -1/0
			local t1 = 1/0
			local c, d
			for i = 1, #meshn do
				if i ~= a and i ~= b then
					local n = meshn[i]
					local l = meshl[i]
					local nd = dot(n, edged)
					local no = dot(n, edgeo)
					local t = (l - no)/nd
					if nd < -1e-8 then
						if t0 < t then
							t0 = t
							c = i
						end
					elseif 1e-8 < nd then
						if t < t1 then
							t1 = t
							d = i
						end
					end
				end
			end
			map[pe(a, b)] = pe(c, d)
			vert[pv(a, b, c)] = edgeo + t0*edged
			vert[pv(a, b, d)] = edgeo + t1*edged
			nextedge[nedges + 1] = pe(a, d)
			nextedge[nedges + 2] = pe(b, d)
			nedges = nedges + 2
			return true
		else
			return false
		end
	end
	local function currentedge()
		return nextedge[n]
	end
	local function done()
		return n >= nedges
	end
	return vert, map, step, currentedge, done
end
------------------------

local cpmshader=love.graphics.newShader'drawcpm.frag'
local edgeshader=love.graphics.newShader'drawedges.frag'

cpmshader:send("View",View)
cpmshader:send("pos",pos)
cpmshader:send("rot",rot)
cpmshader:send("color",{0,0,0})

edgeshader:send("View",View)
edgeshader:send("pos",pos)
edgeshader:send("rot",rot)
edgeshader:send("color",{0.9,0.1,0.1})
--There is a bug in version 0.10.2 which causes Shader:send to ignore the last argument when sending arrays.
--A simple workaround is to add an extra dummy argument when sending multiple values to a uniform array.
cpmshader:send("nmesh",#nlist)
cpmshader:send("nlist",unpack(nlist,1,#nlist+1))
cpmshader:send("llist",unpack(llist,1,#nlist+1))
--[[
edgeshader:send("nedge",#olist)
edgeshader:send("olist",unpack(olist,1,#olist+1))
edgeshader:send("dlist",unpack(dlist,1,#olist+1))
--]]

local vertices,edges,step,current,done=mapslow(nlist,llist)

local TimeNow=0
local StepDuration=1
local LastStep=TimeNow

local clear=love.graphics.clear
local rect=love.graphics.rectangle
local setShader=love.graphics.setShader
function love.draw()
	clear(255,255,255,255)
	local currentEdge=current()
	local nback,noutline,nfront=0,0,0
	local oback,ooutline,ofront={},{},{}
	local dback,doutline,dfront={},{},{}
	for ab,cd in next,edges do
		local a,b=ep(ab)
		local c,d=ep(cd)
		local an,bn=nlist[a],nlist[b]
		local al,bl=llist[a],llist[b]
		local af,bf=dot(an,pos)>al,dot(bn,pos)>bl
		local o=vertices[pv(a,b,c)]
		local d=vertices[pv(a,b,d)]-o
		if ab==currentEdge then
			d=(TimeNow-LastStep)/StepDuration*d
		end
		if af and bf then
			nfront=nfront+1
			ofront[nfront]=o
			dfront[nfront]=d
		elseif not af and not bf then
			nback=nback+1
			oback[nback]=o
			dback[nback]=d
			---[[
		else
			noutline=noutline+1
			ooutline[noutline]=o
			doutline[noutline]=d
			--]]
		end
	end
	--send edges behind
	if nback>0 then
		setShader(edgeshader)
		edgeshader:send("nedge",nback)
		edgeshader:send("olist",unpack(oback,1,nback+1))
		edgeshader:send("dlist",unpack(dback,1,nback+1))
		edgeshader:send("color",{0.9,0.1,0.1})
		rect("fill",View[1][1],View[1][2],View[2][1],View[2][2])
	end
	--draw cpm
	setShader(cpmshader)
	rect("fill",View[1][1],View[1][2],View[2][1],View[2][2])
	--send outline edges
	setShader(edgeshader)
	if noutline>0 then
		edgeshader:send("nedge",noutline)
		edgeshader:send("olist",unpack(ooutline,1,noutline+1))
		edgeshader:send("dlist",unpack(doutline,1,noutline+1))
		edgeshader:send("color",{0.1,0.9,0.1})
		rect("fill",View[1][1],View[1][2],View[2][1],View[2][2])
	end
	--no need to switch shader for front edges
	if nfront>0 then
		edgeshader:send("nedge",nfront)
		edgeshader:send("olist",unpack(ofront,1,nfront+1))
		edgeshader:send("dlist",unpack(dfront,1,nfront+1))
		edgeshader:send("color",{0.9,0.1,0.1})
		rect("fill",View[1][1],View[1][2],View[2][1],View[2][2])
	end
	setTitle("Coloured Fog - "..fps().." FPS")
end

local mPos={getPos()}
local mDir=Vector3.normalize{mPos[1]-View[1][1]-View[2][1]/2,View[2][2]-mPos[2]-View[1][2]-View[2][2]/2,View[2][2]}
function love.update(dt)
	TimeNow=TimeNow+dt
	if TimeNow-LastStep>StepDuration then
		repeat
			if done() then
				vertices,edges,step,current,done=mapslow(nlist,llist)
			end
		until step()
		LastStep=LastStep+StepDuration
	end
	local move=vec3(0,0,0)
	if isKey'd' then
		move[1]=move[1]+1
	end
	if isKey'a' then
		move[1]=move[1]-1
	end
	if isKey'space' then
		move[2]=move[2]+1
	end
	if isKey'lshift' then
		move[2]=move[2]-1
	end
	if isKey'w' then
		move[3]=move[3]+1
	end
	if isKey's' then
		move[3]=move[3]-1
	end
	local ppp=mat.mulVec(rot,speed*dt*move)
	pos[1]=pos[1]+ppp[1]
	pos[2]=pos[2]+ppp[2]
	pos[3]=pos[3]+ppp[3]

	local newPos={getPos()}
	local newDir=Vector3.normalize{newPos[1]-View[1][1]-View[2][1]/2,View[2][2]-newPos[2]-View[1][2]-View[2][2]/2,View[2][2]}
	if isBtn(2) then
		local msq=mDir[1]*mDir[1]+mDir[2]*mDir[2]+mDir[3]*mDir[3]
		local w,x,y,z=(newDir[1]*mDir[1]+newDir[2]*mDir[2]+newDir[3]*mDir[3])/msq,(newDir[3]*mDir[2]-newDir[2]*mDir[3])/msq,(newDir[1]*mDir[3]-newDir[3]*mDir[1])/msq,(newDir[2]*mDir[1]-newDir[1]*mDir[2])/msq
		rot=mat.mulMat(rot,{{w*w+x*x-y*y-z*z,2*(x*y+w*z),2*(x*z-w*y)},{2*(x*y-w*z),w*w-x*x+y*y-z*z,2*(y*z+w*x)},{2*(x*z+w*y),2*(y*z-w*x),w*w-x*x-y*y+z*z}})
	end
	mPos=newPos
	mDir=newDir
	cpmshader:send("rot",rot)
	edgeshader:send("rot",rot)
	cpmshader:send("pos",pos)
	edgeshader:send("pos",pos)
end

local GraphicsMode=1
local fullscreen=false
function love.keypressed(k)
	if k=="escape" then
		love.event.quit()
	elseif k=="f11" then
		fullscreen=not fullscreen
		love.window.setFullscreen(fullscreen,"desktop")
	elseif k=="g" then
		GraphicsMode=GraphicsMode%2+1
		cpmshader:send("GraphicsMode",GraphicsMode)
		edgeshader:send("GraphicsMode",GraphicsMode)
	end
end

function love.resize(w,h)
	View[2][1],View[2][2]=w,h
	cpmshader:send("View",View)
	edgeshader:send("View",View)
end