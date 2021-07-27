--By xXxMoNkEyMaNxXx
--Annoyance fixers doz elsez
local next,type=next,type
local pi=math.pi
local sqrt=math.sqrt
local cos,sin=math.cos,math.sin
local ceil,floor=math.ceil,math.floor
local max,min=math.max,math.min
local function sign(x)
	if x>0 then
		return 1
	end
	if x<0 then
		return -1
	end
	return 0
end
local function copySign(x,y)
    return sign(x)*sign(y)*x
end

local quad=require'Perspective'
local vec=require'vec'
local mat=require'mat'

local add,sub=vec.add,vec.sub
local div=vec.div
local mulNum,divNum=vec.mulNum,vec.divNum
local dot=vec.dot
local normalize=vec.normalize

local toObject=mat.toObject
local mulVec,mulMat=mat.mulVec,mat.mulMat

local function getQuaternion(rot)
	local rx,ry,rz=rot[1],rot[2],rot[3]
	local xx,xy,xz,yx,yy,yz,zx,zy,zz=rx[1],rx[2],rx[3],ry[1],ry[2],ry[3],rz[1],rz[2],rz[3]
--[[
	local t=xx+yy+zz
	if t>0 then
		local r=sqrt(1+t)
		local s=0.5/r
		return {0.5*r,s*(zy-yz),s*(xz-zx),s*(yx-xy)}
	else
		local best=max(xx,yy,zz)
		local r=sqrt(1+2*best-t)
		local s=0.5/r
		if best==xx then
			return {s*(zy-yz),0.5*r,s*(yx+xy),s*(xz+zx)}
		elseif best==yy then
			return {s*(xz-zx),s*(yx+xy),0.5*r,s*(zy+yz)}
		elseif best==zz then
			return {s*(yx-xy),s*(xz+zx),s*(zy+yz),0.5*r}
		end
	end
--]]
---[[
	return {
		-0.5*sqrt(1+xx+yy+zz),
		0.5*sqrt(1+xx-yy-zz)*sign(zy-yz),
		0.5*sqrt(1-xx+yy-zz)*sign(xz-zx),
		0.5*sqrt(1-xx-yy+zz)*sign(yx-xy)
	}
--]]
end
local function getMatrix(q)
	local w,x,y,z=q[1],q[2],q[3],q[4]
	local l=w*w+x*x+y*y+z*z
	local s=l>0 and 2/l or 0
	local X,Y,Z=x*s,y*s,z*s
	local wX,wY,wZ=w*X,w*Y,w*Z
	local xX,xY,xZ=x*X,x*Y,x*Z
	local yY,yZ=y*Y,y*Z
	local zZ=z*Z
---[[
	return {
		{1-(yY+zZ),xY+wZ,xZ-wY},
		{xY-wZ,1-(xX+zZ),yZ+wX},
		{xZ+wY,yZ-wX,1-(xX+yY)}
	}
--]]
--[[
	return {
		{1-(yY+zZ),xY-wZ,xZ+wY},
		{xY+wZ,1-(xX+zZ),yZ-wX},
		{xZ-wY,yZ+wX,1-(xX+yY)}
	}
--]]
end
local function qMul(q1,q2)
	local a1,b1,c1,d1=q1[1],q1[2],q1[3],q1[4]
	local a2,b2,c2,d2=q2[1],q2[2],q2[3],q2[4]
    return {
		a1*a2-b1*b2-c1*c2-d1*d2,
		a1*b2+b1*a2+c1*d2-d1*c2,
		a1*c2-b1*d2+c1*a2+d1*b2,
		a1*d2+b1*c2-c1*b2+d1*a2
	}
end

--[[
do
	math.randomseed(os.time()) math.random()
	local q1=normalize{math.random()-0.5,math.random()-0.5,math.random()-0.5,math.random()-0.5}
	local q2=normalize{math.random()-0.5,math.random()-0.5,math.random()-0.5,math.random()-0.5}
	local m1,m2=getMatrix(q1),getMatrix(q2)
	local q3,q4=getQuaternion(m1),getQuaternion(m2)
	local m3,m4=getMatrix(q3),getMatrix(q4)
	print(vec.tostring(q1))
	print(vec.tostring(q2))
	print(vec.tostring(q3))
	print(vec.tostring(q4))
	print''
	print(mat.tostring(m1))
	print(mat.tostring(m2))
	print(mat.tostring(m3))
	print(mat.tostring(m4))
	print''
	print(vec.tostring(qMul(q1,q2)))
	print(vec.tostring(getQuaternion(mulMat(m1,m2))))
	print''
	print(mat.tostring(mulMat(m1,m2)))
	print(mat.tostring(getMatrix(qMul(q3,q4))))
end
--]]

local scene={
	FOV=math.tan(60*pi/180),
	table=love.graphics.newImage'DefaultTable.png',
	camPos={0,0,0},
	camRot={{1,0,0},{0,1,0},{0,0,1}},
	glide=0.9995,
	getMatrix=getMatrix,
	getQuaternion=getQuaternion,
	view={{0,0},{love.graphics.getWidth(),love.graphics.getHeight()}},
}

local sections={}
for i,y in next,{1,2,0,3} do
	for x=0,12 do
		sections[13*i+x-12]={{x/13,y/4},{1/13,1/4}}
	end
end


local cardSize={0.5,0.003,0.7}
local cardStack={5,1,6}
local faceImage,backImage

local function toScreen(disp)
	local rel3=scene.FOV*dot(disp,scene.camRot[3])
	return {scene.view[1][1]+dot(disp,scene.camRot[1])*scene.view[2][2]/rel3+0.5*scene.view[2][1],scene.view[1][2]+scene.view[2][2]*(0.5-dot(disp,scene.camRot[2])/rel3)}
end
local function toWorld(mpos)
	return mulVec(scene.camRot,normalize{(mpos[1]-scene.view[1][1]-0.5*scene.view[2][1])/scene.view[2][2],(0.5-(mpos[2]-scene.view[1][2])/scene.view[2][2]),1/scene.FOV})
end
scene.toScreen=toScreen
scene.toWorld=toWorld

local flip={0,0,0,1}
local function drawCard(card,rot,pos)
	if card.fixed then
		local q=getQuaternion(rot)
		if card.up then
			card.tQuat=qMul(q,flip)
		else
			card.tQuat=q
		end
		card.tPos=pos
	end
	local cRot,cPos=card.rot,card.pos
	local disp=sub(cPos,scene.camPos)
	if dot(disp,scene.camRot[3])>0 then--All cards should be in view anyway...
		if dot(disp,cRot[2])>0 then
			local sec=sections[card.cardId]
			quad.setRepeat(sec[1],sec[2])
			quad.quad(faceImage,toScreen(add(disp,mulVec(cRot,{cardSize[1],cardSize[2],cardSize[3]}))),toScreen(add(disp,mulVec(cRot,{-cardSize[1],cardSize[2],cardSize[3]}))),toScreen(add(disp,mulVec(cRot,{-cardSize[1],cardSize[2],-cardSize[3]}))),toScreen(add(disp,mulVec(cRot,{cardSize[1],cardSize[2],-cardSize[3]}))))
		else
			quad.setRepeat({0,0},{1,1})
			quad.quad(backImage,toScreen(add(disp,mulVec(cRot,{-cardSize[1],-cardSize[2],cardSize[3]}))),toScreen(add(disp,mulVec(cRot,{cardSize[1],-cardSize[2],cardSize[3]}))),toScreen(add(disp,mulVec(cRot,{cardSize[1],-cardSize[2],-cardSize[3]}))),toScreen(add(disp,mulVec(cRot,{-cardSize[1],-cardSize[2],-cardSize[3]}))))
		end
		if scene.debug then
			print(vec.tostring(toScreen(disp)))
		end
	end
end
scene.drawCard=drawCard

local function drawStack(game,stack,rot,pos)
	if stack.fixed then
		stack.tQuat,stack.tPos=getQuaternion(rot),pos
	end
	local sRot,sPos=stack.rot,stack.pos
	local disp=sub(scene.camPos,sPos)
	local infront=dot(sRot[2],disp)>0
	if #stack>0 then
		local layout=stack.layout
		if layout=="Pile" then
		--[[
			if infront then
				local card=stack:getCard(#stack)
				local pack=game.packs[game.decks[card.deckId].packId]
				faceImage,backImage=pack.faces,pack.backs
				drawCard(card,sRot,add(sPos,mulNum(sRot[2],cardSize[2]*#stack)))
			else
				local card=stack:getCard(1)
				local pack=game.packs[game.decks[card.deckId].packId]
				faceImage,backImage=pack.faces,pack.backs
				drawCard(card,sRot,sPos)
			end
		--]]
		---[[
			for i=infront and 1 or #stack,infront and #stack or 1,infront and 1 or -1 do
				local card=stack:getCard(i)
				local pack=game.packs[game.decks[card.deckId].packId]
				faceImage,backImage=pack.faces,pack.backs
				drawCard(card,sRot,add(sPos,mulNum(sRot[2],cardSize[2]*i)))
			end
		--]]
		elseif layout=="Fan" then
			--;w;
		elseif layout=="Horizontal" then
			local cardRot=mulMat(sRot,{normalize{cardSize[1]/cardStack[1],-cardSize[2]/cardStack[2],0},normalize{cardSize[2]/cardStack[2],cardSize[1]/cardStack[1],0},{0,0,1}})
			local infront=dot(cardRot[2],disp)>0
			for i=infront and 1 or #stack,infront and #stack or 1,infront and 1 or -1 do
				local card=stack:getCard(i)
				local pack=game.packs[game.decks[card.deckId].packId]
				faceImage,backImage=pack.faces,pack.backs
				local m=2*(i-1-(stack.alignment or 0)*(#stack-1))
				drawCard(card,cardRot,add(sPos,mulVec(cardRot,{m*cardSize[1]/cardStack[1],m*cardSize[2]/cardStack[2],0})))
			end
		elseif layout=="Vertical" then
			local cardRot=mulMat(sRot,{{1,0,0},normalize{0,cardSize[3]/cardStack[3],-cardSize[2]/cardStack[2]},normalize{0,cardSize[2]/cardStack[2],cardSize[3]/cardStack[3]}})
			local infront=dot(cardRot[2],disp)>0
			for i=infront and 1 or #stack,infront and #stack or 1,infront and 1 or -1 do
				local card=stack:getCard(i)
				local pack=game.packs[game.decks[card.deckId].packId]
				faceImage,backImage=pack.faces,pack.backs
				local m=2*(i-1-(stack.alignment or 0)*(#stack-1))
				drawCard(card,cardRot,add(sPos,mulVec(cardRot,{0,m*cardSize[2]/cardStack[2],m*-cardSize[3]/cardStack[3]})))
			end
		end
	end
end
scene.drawStack=drawStack

local height=4
local radius=10
local width=sqrt(radius*radius-height*height)
local function getCameraCFrame(v,n)
	local theta=2*pi*((v-1)/n-0.25)
	local ct,st=cos(theta),sin(theta)
    return {{-st,0,ct},{-height/radius*ct,width/radius,-height/radius*st},{-width/radius*ct,-height/radius,-width/radius*st}},{width*ct,height,width*st},{{-st,0,ct},{0,1,0},{-ct,0,-st}}
end

local function renderPlayerStacks(game,pstacks,rot,pos,umat)
	for x=1,#pstacks do
		drawStack(game,pstacks[x],umat,add({pos[1],0,pos[3]},mulNum(umat[1],cardSize[1]*(1+1/cardStack[1])*(2*x-#pstacks-1))))
	end
	if pstacks[0] then
		drawStack(game,pstacks[0],{rot[1],mulNum(rot[3],-1),rot[2]},add(pos,mulVec(rot,{0,-1,3})))
	end
end

local lookDown={{1,0,0},{0,cos(0.5),sin(0.5)},{0,-sin(0.5),cos(0.5)}}
function scene.drawScene(game,viewer)
	local stacks={[0]={}}
	local players=game.players
	local np=#players
	for o,p in next,players do
		stacks[o]={[0]=p.hand}
	end
	for i,s in next,game.stacks do
		local o=s.owner
		local so=stacks[o]
		if so and s~=so[0] then
			so[#so+1]=s
		end
	end
	quad.setRepeat({0,0},{1,1})
	if viewer==0 then
		scene.camRot,scene.camPos={{1,0,0},{0,0,1},{0,-1,0}},{0,radius,0}
		quad.quad(scene.table,toScreen{-radius,0,radius},toScreen{radius,0,radius},toScreen{radius,0,-radius},toScreen{-radius,0,-radius})
		--render table stacks
		local s0=stacks[0]
		for x=1,#s0 do
			drawStack(game,s0[x],{{1,0,0},{0,1,0},{0,0,1}},{cardSize[1]*(1+1/cardStack[1])*(x-(#s0+1)/2),0,0})
		end
		for v=1,np do
			renderPlayerStacks(game,stacks[v],getCameraCFrame(v,np))
		end
	elseif type(viewer)=="number" then
		local camRot,camPos,umat=getCameraCFrame(viewer,np)
		scene.camRot=mulMat(camRot,lookDown)
		scene.camPos=add(camPos,mulNum(camRot[3],-2))
		quad.quad(scene.table,toScreen{-radius,0,radius},toScreen{radius,0,radius},toScreen{radius,0,-radius},toScreen{-radius,0,-radius})
		if np>1 then
			--render furthest player first
			local fv=floor(viewer+np*0.5-0.5)%np+1
			renderPlayerStacks(game,stacks[fv],getCameraCFrame(fv,np))
			--render players so that no depth errors will occur
			for v=fv+1,fv+floor((viewer-fv)%np-0.5) do
				local pv=(v-1)%np+1
				renderPlayerStacks(game,stacks[pv],getCameraCFrame(pv,np))
			end
			for v=fv-1,fv-floor((fv-viewer)%np-0.5),-1 do
				local pv=(v-1)%np+1
				renderPlayerStacks(game,stacks[pv],getCameraCFrame(pv,np))
			end
		end
		--render table stacks
		local s0=stacks[0]
		for x=1,#s0 do
			drawStack(game,s0[x],umat,mulNum(umat[1],cardSize[1]*(1+1/cardStack[1])*(2*x-#s0-1)))
		end
		local pv=floor(viewer-0.5)%np+1
		renderPlayerStacks(game,stacks[pv],getCameraCFrame(pv,np))
	end
end

function scene.cast(game,pos,dir,ignore)
	local best_t,best_c=math.huge
	local decks=game.decks
	for d=1,#decks do
		local deck=decks[d]
		for c=1,#deck do
			local card=deck[c]
			local pass=true
			if ignore then
				for i=1,#ignore do
					if ignore[i][1]==card.deckId and ignore[i][2]==card.cardId then
						pass=false
						break
					end
				end
			end
			if pass then
				local cRot,cPos=card.rot,card.pos
				local rel=sub(pos,cPos)
				local rx,ry,rz=dot(rel,cRot[1]),dot(rel,cRot[2]),dot(rel,cRot[3])
				local dx,dy,dz=dot(dir,cRot[1]),dot(dir,cRot[2]),dot(dir,cRot[3])
				local tx,ty,tz=-(sign(dx)*cardSize[1]+rx)/dx,-(sign(dy)*cardSize[2]+ry)/dy,-(sign(dz)*cardSize[3]+rz)/dz
				if tx>0 and tx<best_t then
					local rt=div(toObject(cRot,add(rel,mulNum(dir,tx))),cardSize)
					if rt[2]>=-1 and rt[2]<=1 and rt[3]>=-1 and rt[3]<=1 then
						best_t,best_c=tx,card
					end
				end
				if ty>0 and ty<best_t then
					local rt=div(toObject(cRot,add(rel,mulNum(dir,ty))),cardSize)
					if rt[3]>=-1 and rt[3]<=1 and rt[1]>=-1 and rt[1]<=1 then
						best_t,best_c=ty,card
					end
				end
				if tz>0 and tz<best_t then
					local rt=div(toObject(cRot,add(rel,mulNum(dir,tz))),cardSize)
					if rt[1]>=-1 and rt[1]<=1 and rt[2]>=-1 and rt[2]<=1 then
						best_t,best_c=tz,card
					end
				end
			end
		end
	end
	return best_c,best_t
end

function scene.setRadius(r,h)
	radius,height,width=r,h,h<r and sqrt(r*r-h*h) or 0
end

function scene.setLookDown(pitch,yaw)
	local cp,sp=cos(pitch),sin(pitch)
	local cy,sy=1,0
	if yaw then
		cy,sy=cos(yaw),sin(yaw)
	end
	lookDown={{cy,0,-sy},{0,cp,sp},{sy,-sp,cp*cy}}
end

function scene.update(game,dt)
	local t=1-(1-scene.glide)^dt
	local decks=game.decks
	for d=1,#decks do
		local deck=decks[d]
		for c=1,#deck do
			local card=deck[c]
			local cQuat,cPos=card.quat,card.pos
			local dQ=sub(card.tQuat,cQuat)
			local dP=sub(card.tPos,cPos)
			local newQuat=add(cQuat,mulNum(dQ,t))
			card.quat,card.rot,card.pos=newQuat,getMatrix(newQuat),add(cPos,mulNum(dP,t))
		end
	end
	local stacks=game.stacks
	for s=1,#stacks do
		local stack=stacks[s]
		local sQuat,sPos=stack.quat,stack.pos
		local dQ=sub(stack.tQuat,sQuat)
		local dP=sub(stack.tPos,sPos)
		local newQuat=add(sQuat,mulNum(dQ,t))
		stack.quat,stack.rot,stack.pos=newQuat,getMatrix(newQuat),add(sPos,mulNum(dP,t))
	end
end

return scene
