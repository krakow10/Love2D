--By xXxMoNkEyMaNxXx
local quat=require'quat'
local vec=require'vec'

local setColour=love.graphics["\115\101\116\067\111\108\111\114"]--So it autosuggests the Canadian way ;)
local poly=love.graphics["\113\117\097\100"]--So it still suggests t instead of d in quat

local colours={}
for i,v in next,{{0,0,1,1},{1,1,1,1},{1,0.5,0,1},{0,1,0,1},{1,1,0,1},{1,0,0,1}} do
	colours[i]=vec.mulNum(v,255)
end

local axes={{1,0,0},{0,1,0},{0,0,1},{-1,0,0},{0,-1,0},{0,0,-1}}

local scene={}
local cam={
	FOV=0.5,
	pos={0,0,10},
	quat={1,0,0,0},
}
local view={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}}

local function lua(n,l)
	return (n-1)%l+1
end

local function toScreen_pre(cam_point)--cam_objPos to screenPos
	local scale=2*cam.FOV*cam_point[3]
	return {view[1][1]+view[2][1]/2+view[2][2]*cam_point[1]/scale,view[1][2]+view[2][2]*(0.5+cam_point[2]/scale)}
end
local function toWorld(mPos)
	return quat.mulVec(cam.quat,vec.normalize{cam.FOV*(mPos[1]-view[1][1]-view[2][1]/2)/view[2][2],cam.FOV*((mPos[2]-view[1][2])/view[2][2]-0.5),0.5})
end

local function addCube(cube)
	scene[#scene+1]=cube
end

local function draw()
	local camPos=cam.pos
	local camQuat=cam.quat
	local icamQ=quat.inv(camQuat)
	for i=1,#scene do
		local cube=scene[i]
		local size=cube.size
		local cubePos=cube.pos
		local cubeQuat=cube.quat
		local axis=cube.turnAxis
		local index=cube.turnIndex

		local cam_cubePos=quat.mulVec(icamQ,vec.sub(cubePos,camPos))
		local cam_cubeQuat=quat.mul(cubeQuat,icamQ)
		local cube_camPos=quat.mulVec(quat.inv(cubeQuat),vec.sub(camPos,cubePos))

		local lAxes={}
		for face=1,#axes do
			lAxes[face]=quat.mulVec(cam_cubeQuat,axes[face])
		end

		local hs=size/2
	--[=[ This will draw larger cubes a bit faster. (At the expense of the black spaces)
		for face=1,#axes do
			if face<4 and cube_camPos[lua(face,3)]>hs or face>3 and cube_camPos[lua(face,3)]<-hs then--Face is facing camera, and wtf Lua? Equality precedes comparison...
				local axisPos=vec.add(cam_cubePos,vec.mulNum(lAxes[face],hs))
				local axis1,axis2=lAxes[lua(face+1,6)],lAxes[lua(face+2,6)]
				local last1=vec.add(axisPos,vec.mulNum(axis1,-hs))
				local data1=cube[face]
				for i1=1,#data1 do
					local ax1=i1-hs
					local this1=vec.add(axisPos,vec.mulNum(axis1,ax1))
					local last2=vec.mulNum(axis2,-hs)
					local data2=data1[i1]
					for i2=1,#data2 do
						local ax2=i2-hs
						local this2=vec.mulNum(axis2,ax2)
						setColour(colours[data2[i2]])
						local v1=toScreen_pre(vec.add(last1,last2))
						local v2=toScreen_pre(vec.add(this1,last2))
						local v3=toScreen_pre(vec.add(this1,this2))
						local v4=toScreen_pre(vec.add(last1,this2))
						poly("fill",v1[1],v1[2],v2[1],v2[2],v3[1],v3[2],v4[1],v4[2])
						last2=this2
					end
					last1=this1
				end
			end
		end
	--]=]
	---[=[
		local offset=hs+0.5
		for face=1,#axes do
			if face<4 and cube_camPos[lua(face,3)]>hs or face>3 and cube_camPos[lua(face,3)]<-hs then--Face is facing camera, and wtf Lua? Equality precedes comparison...
				local axisPos=vec.add(cam_cubePos,vec.mulNum(lAxes[face],hs))
				local a1,a2=lua(face+1,3),lua(face+2,3)
				local axis1,axis2=lAxes[a1],lAxes[a2]
				local data1=cube[face]
				local pos={[lua(face,3)]=face<4 and hs-0.5 or 0.5-hs}
				for i1=1,#data1 do
					local ax1=i1-offset
					pos[a1]=ax1
					local this1=vec.add(axisPos,vec.mulNum(axis1,ax1+0.45))
					local last1=vec.add(axisPos,vec.mulNum(axis1,ax1-0.45))
					local data2=data1[i1]
					for i2=1,#data2 do
						local ax2=i2-offset
						pos[a2]=ax2
						if not axis or pos[axis]~=index then
							local this2=vec.mulNum(axis2,ax2+0.45)
							local last2=vec.mulNum(axis2,ax2-0.45)
							setColour(colours[data2[i2]])
							local v1=toScreen_pre(vec.add(last1,last2))
							local v2=toScreen_pre(vec.add(this1,last2))
							local v3=toScreen_pre(vec.add(this1,this2))
							local v4=toScreen_pre(vec.add(last1,this2))
							poly("fill",v1[1],v1[2],v2[1],v2[2],v3[1],v3[2],v4[1],v4[2])
						end
					end
				end
			end
		end
	--]=]
	end
end

local function cast(pos,dir)
	local best_t
end

return {
	cam=cam,
	view=view,
	scene=scene,
	toWorld=toWorld,
	draw=draw,
	addCube=addCube,
}
