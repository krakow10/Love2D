--By xXxMoNkEyMaNxXx

local vec=require'vec'
local ui=loader.open'ui.lua'

local w=ui.connect(ctrl.newWindow())
ctrl.worldDrag(w)
local wrapper=ui.wrapper(w)
w.Window={{0,0},{2,2}}

local cos,sin=math.cos,math.sin
local atan2=math.atan2
local sqrt=math.sqrt

local max,min=math.max,math.min

local getPos=love.mouse.getPosition
local isBtn=love.mouse.isDown

local line=love.graphics.line
local quad=love.graphics.quad
local rect=love.graphics.rectangle
local colour=love.graphics.setColor

local box={{3,-4},{1,1}}

local scale=1
local theta=1
local offset={0,0}
local matrix={{scale*cos(theta),scale*sin(theta)},{-scale*sin(theta),scale*cos(theta)}}


function w:draw()
	colour(0,0,0,255)
	local u=w:toScreenArea(box)
	rect("line",u[1][1],u[1][2],u[2][1],u[2][2])
	local det=matrix[1][1]*matrix[2][2]-matrix[1][2]*matrix[2][1]

	local v00=vec.add(offset,vec.add(matrix[1],matrix[2]))
	local v01=vec.add(offset,vec.sub(matrix[1],matrix[2]))
	local v10=vec.sub(offset,vec.sub(matrix[1],matrix[2]))
	local v11=vec.sub(offset,vec.add(matrix[1],matrix[2]))
	local s00,s01,s10,s11=w:toScreen(v00),w:toScreen(v01),w:toScreen(v10),w:toScreen(v11)
	quad("line",s00[1],s00[2],s01[1],s01[2],s11[1],s11[2],s10[1],s10[2])

	colour(255,0,0,255)
	local x,y=box[1][1],box[1][2]
	local Area=0

	local c0x_min,c0x_max=(-det-vec.dot(vec.sub({x+1,y},offset),matrix[1]))/matrix[1][2],(det-vec.dot(vec.sub({x+1,y},offset),matrix[1]))/matrix[1][2]
	local c0y_min,c0y_max=(-det-vec.dot(vec.sub({x+1,y},offset),matrix[2]))/matrix[2][2],(det-vec.dot(vec.sub({x+1,y},offset),matrix[2]))/matrix[2][2]
	if(matrix[1][2]<0)then
		c0x_min,c0x_max=c0x_max,c0x_min
	end
	if(matrix[2][2]<0)then
		c0y_min,c0y_max=c0y_max,c0y_min
	end
	local c0_min=max(0,c0x_min,c0y_min)
	local c0_max=min(1,c0x_max,c0y_max)
	if(c0_max>c0_min)then
		local s0,s1=w:toScreen{x+1,y+c0_min},w:toScreen{x+1,y+c0_max}
		line(s0[1],s0[2],s1[1],s1[2])
		Area=Area+c0_max-c0_min
	end

	local dx1,dy1=v10[1]-v00[1],v10[2]-v00[2]
	local c1x_min,c1x_max=(x-v00[1])/dx1,(x+1-v00[1])/dx1
	local c1y_min,c1y_max=(y-v00[2])/dy1,(y+1-v00[2])/dy1
	if dx1<0 then
		c1x_min,c1x_max=c1x_max,c1x_min
	end
	if dy1<0 then
		c1y_min,c1y_max=c1y_max,c1y_min
	end
	local c1_min=max(0,c1x_min,c1y_min);
	local c1_max=min(1,c1x_max,c1y_max);
	if(c1_max>c1_min)then
		local v0=vec.add(v00,vec.mulNum(vec.sub(v10,v00),c1_min));
		local v1=vec.add(v00,vec.mulNum(vec.sub(v10,v00),c1_max));
		local s0,s1=w:toScreen(v0),w:toScreen(v1)
		line(s0[1],s0[2],s1[1],s1[2])
		Area=Area+(v1[2]-v0[2])*((v1[1]+v0[1])/2-x);
	end

	local dx2,dy2=v11[1]-v10[1],v11[2]-v10[2]
	local c2x_min,c2x_max=(x-v10[1])/dx2,(x+1-v10[1])/dx2
	local c2y_min,c2y_max=(y-v10[2])/dy2,(y+1-v10[2])/dy2
	if dx2<0 then
		c2x_min,c2x_max=c2x_max,c2x_min
	end
	if dy2<0 then
		c2y_min,c2y_max=c2y_max,c2y_min
	end
	local c2_min=max(0,c2x_min,c2y_min);
	local c2_max=min(1,c2x_max,c2y_max);
	if(c2_max>c2_min)then
		local v0=vec.add(v10,vec.mulNum(vec.sub(v11,v10),c2_min));
		local v1=vec.add(v10,vec.mulNum(vec.sub(v11,v10),c2_max));
		local s0,s1=w:toScreen(v0),w:toScreen(v1)
		line(s0[1],s0[2],s1[1],s1[2])
		Area=Area+(v1[2]-v0[2])*((v1[1]+v0[1])/2-x);
	end

	local dx3,dy3=v01[1]-v11[1],v01[2]-v11[2]
	local c3x_min,c3x_max=(x-v11[1])/dx3,(x+1-v11[1])/dx3
	local c3y_min,c3y_max=(y-v11[2])/dy3,(y+1-v11[2])/dy3
	if dx3<0 then
		c3x_min,c3x_max=c3x_max,c3x_min
	end
	if dy3<0 then
		c3y_min,c3y_max=c3y_max,c3y_min
	end
	local c3_min=max(0,c3x_min,c3y_min);
	local c3_max=min(1,c3x_max,c3y_max);
	if(c3_max>c3_min)then
		local v0=vec.add(v11,vec.mulNum(vec.sub(v01,v11),c3_min));
		local v1=vec.add(v11,vec.mulNum(vec.sub(v01,v11),c3_max));
		local s0,s1=w:toScreen(v0),w:toScreen(v1)
		line(s0[1],s0[2],s1[1],s1[2])
		Area=Area+(v1[2]-v0[2])*((v1[1]+v0[1])/2-x);
	end

	local dx4,dy4=v00[1]-v01[1],v00[2]-v01[2]
	local c4x_min,c4x_max=(x-v01[1])/dx4,(x+1-v01[1])/dx4
	local c4y_min,c4y_max=(y-v01[2])/dy4,(y+1-v01[2])/dy4
	if dx4<0 then
		c4x_min,c4x_max=c4x_max,c4x_min
	end
	if dy4<0 then
		c4y_min,c4y_max=c4y_max,c4y_min
	end
	local c4_min=max(0,c4x_min,c4y_min);
	local c4_max=min(1,c4x_max,c4y_max);
	if(c4_max>c4_min)then
		local v0=vec.add(v01,vec.mulNum(vec.sub(v00,v01),c4_min));
		local v1=vec.add(v01,vec.mulNum(vec.sub(v00,v01),c4_max));
		local s0,s1=w:toScreen(v0),w:toScreen(v1)
		line(s0[1],s0[2],s1[1],s1[2])
		Area=Area+(v1[2]-v0[2])*((v1[1]+v0[1])/2-x);
	end
	wrapper.TitleBar.Text=Area
end

local mPos=w:toWorld{getPos()}
function w:update()
	local newPos=w:toWorld{getPos()}
	local deltaPos=vec.sub(newPos,mPos)

	if deltaPos[1]~=0 or deltaPos[2]~=0 then
		if w.Btn.l then
			offset={offset[1]+deltaPos[1],offset[2]+deltaPos[2]}
		elseif w.Btn.m then
			local d1,d2=vec.sub(mPos,offset),vec.sub(newPos,offset)
			theta=theta+atan2(d2[2],d2[1])-atan2(d1[2],d1[1])
			scale=scale*sqrt((d2[1]*d2[1]+d2[2]*d2[2])/(d1[1]*d1[1]+d1[2]*d1[2]))
			matrix={{scale*cos(theta),scale*sin(theta)},{-scale*sin(theta),scale*cos(theta)}}
		end
	end
	mPos=newPos
end
