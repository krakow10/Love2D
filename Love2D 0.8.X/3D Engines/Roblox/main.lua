--By xXxMoNkEyMaNxXx

local next=next
local env=getfenv()
local function using(namespace)
	for i,v in next,env[namespace] do
		env[i]=v
	end
end

using'math'
using'table'
using'string'
local tau=2*pi

using'love'
--local texture=require'lib/Perspective'

Class=require'lib/Class'
using'Class'
Vector2=require'class/Vector2'
Vector3=require'class/Vector3'
Colour4=require'class/Colour4'
Quaternion=require'class/Quaternion'

local Vector2=Vector2
local Vector3=Vector3
local Colour4=Colour4
local Quaternion=Quaternion

local sign=function(x)
	if x==0 then
		return 0
	elseif x>0 then
		return 1
	else
		return -1
	end
end
local rand=function(a,b)
	local r=random()
	if b then
		return a+r*(b-a)
	elseif a then
		return a*r
	else
		return r
	end
end

local m

local function worldToScreen(cam,pos)--Camera,Vector3
	local relpos=(pos-cam.Pos)*cam.Quaternion--not the same as cam.Quaternion*(pos-cam.Pos), it does the opposite :D
	local vs=m.ViewSize --Vector2.new(graphics.getWidth(),graphics.getHeight())/2
	local vs2=vs/2
	local at=Vector2.new(vs.x/vs.y,1)*tan(cam.FOV*pi/360)
	local upos=Vector2.new(relpos.x,-relpos.y)/abs(relpos.z)
	local spos=vs2+vs2*upos/at
	if relpos.z<0 then--or (spos.x<0 or spos.x>vs.x) and (spos.y<0 or spos.y>vs.y) then--object is in front or offscreen (so that things still visible beside you will render)
		return spos--Vector2
	end
end

local function screenToWorld(cam,spos)--Camera,Vector2
	local vs=m.ViewSize/2
	local at=Vector2.new(vs.x/vs.y,1)*tan(cam.FOV*pi/360)
	local relpos=at*(spos-vs)/vs
	return cam.Quaternion*Vector3.new(relpos.x,-relpos.y,-1).unit
end

local polygon=graphics.polygon
local objects={}
local soundlist={}
local sourcelist={}
local renderlist={}
local physiclist={}

local default={
	None=graphics.newImage'textures/Blank.png',
	Studs=graphics.newImage'textures/surfaces/studs.png',
	Inlet=graphics.newImage'textures/surfaces/inlet.png',
	Weld=graphics.newImage'textures/surfaces/weld.png',
	Glue=graphics.newImage'textures/surfaces/glue.png',
	Universal=graphics.newImage'textures/surfaces/Universal.png'
}
local objectClasses={
	Brick={
		Size=Vector3.new(1,1,1),
		Pos=Vector3.new(1,1,1),
		Vel=Vector3.new(0,0,0),
		Quaternion=Quaternion.new(),
		Right=default.None,
		Top=default.Studs,
		Front=default.None,
		Left=default.None,
		Bottom=default.Inlet,
		Back=default.None,
		Repeated={{2,2},{2,2},{2,2},{2,2},{2,2},{2,2}},--False will give the shader the surface's size
		Reflectance=0.5,
		Colour=Colour4.new(),
		Rot=Vector3.new(),--Rotational velocity pseudovector
		Physical=true,
		Visible=true,
		Anchored=false
	},
	Camera={
		FOV=70,
		Quaternion=Quaternion.new(),
		Pos=Vector3.new(),
		Speed=10,
		Spin=1
	},
	Mouse={
		Pos=Vector2.new(mouse.getPosition()),
		ViewSize=Vector2.new(graphics.getWidth(),graphics.getHeight()),
		Direction=Vector3.new()
	},
	Light={
		Pos=Vector3.new(),
		Colour=Colour4.new(),
		Brightness=1,
		LightEmitting=true
	},
	Sound=setmetatable(
		{
			Object=false,
			src=false--use .Source so it will change...
		},{
			__index=function(s,i)
				if s.src and s.src[i] and type(s.src[i])=="function" then
					return function(_,...) s.src[i](s.src,...) end
				end
			end,
			__newindex=function(s,i,v)
				if i=="Source" then
					s.src=audio.newSource(sound.newDecoder(v))
					--s:Stop()
				else
					rawset(s,i,v)
				end
			end
		}
	)

}

local new=function(class)
	local obj=copy(objectClasses[class])
	if obj then
		obj.Class=class
		insert(objects,obj)
		if obj.Visible then
			renderlist[#renderlist+1]=obj
		end
		if obj.Physical then
			physiclist[#physiclist+1]=obj
		end
		if obj.LightEmitting then
			sourcelist[#sourcelist+1]=obj
		end
		if class=="Sound" then
			soundlist[#soundlist+1]=obj
		end
		return obj
	else
		print("Could not create object of type '"..class.."'.")
	end
end

local dot=Vector3.Dot
local function plane(n,p,d)
	return dot(p,n)/dot(d,n)
end

function raycast(pos,dir,ignorelist)
	local low=huge
	local hit,best,sfc,spos
	for _,o in next,renderlist do
		local docast=true
		if ignorelist then
			for _,item in next,ignorelist do
				if o==item then
					docast=false
					break
				end
			end
		end
		if docast then
			if o.Class=="Brick" then
				local p=o.Pos
				local rel=p-pos--pos-p
				local sx,sy,sz=o.Size.x/2,o.Size.y/2,o.Size.z/2
				local reldir,smag=dot(rel,dir),sqrt(sx^2+sy^2+sz^2)
				if reldir-smag<low and (rel-dir*reldir).magnitude<smag then
					local q=o.Quaternion
					local ax,ay,az=q.ux,q.uy,q.uz
					local ux,uy,uz=ax*sx,ay*sy,az*sz
					local s1=plane(ax,rel+ux,dir)--Right
					local s2=plane(ay,rel+uy,dir)--Top
					local s3=plane(az,rel+uz,dir)--Back
					local s4=plane(ax,rel-ux,dir)--Left
					local s5=plane(ay,rel-uy,dir)--Bottom
					local s6=plane(az,rel-uz,dir)--Front
					if s1>0 and s1<low then
						local vec=pos+dir*s1
						local nub=vec-p
						local locy,locz=dot(ay,nub),dot(az,nub)
						if locy>=-sy and locy<=sy and locz>=-sz and locz<=sz then
							low,hit,best,sfc,spos=s1,o,vec,1,Vector2.new(locz,locy)
						end
					end
					if s2>0 and s2<low then
						local vec=pos+dir*s2
						local nub=vec-p
						local locx,locz=dot(ax,nub),dot(az,nub)
						if locx>=-sx and locx<=sx and locz>=-sz and locz<=sz then
							low,hit,best,sfc,spos=s2,o,vec,2,Vector2.new(locx,locz)
						end
					end
					if s3>0 and s3<low then
						local vec=pos+dir*s3
						local nub=vec-p
						local locx,locy=dot(ax,nub),dot(ay,nub)
						if locx>=-sx and locx<=sx and locy>=-sy and locy<=sy then
							low,hit,best,sfc,spos=s3,o,vec,3,Vector2.new(locx,locy)
						end
					end
					if s4>0 and s4<low then
						local vec=pos+dir*s4
						local nub=vec-p
						local locy,locz=dot(ay,nub),dot(az,nub)
						if locy>=-sy and locy<=sy and locz>=-sz and locz<=sz then
							low,hit,best,sfc,spos=s4,o,vec,4,Vector2.new(locz,locy)
						end
					end
					if s5>0 and s5<low then
						local vec=pos+dir*s5
						local nub=vec-p
						local locx,locz=dot(ax,nub),dot(az,nub)
						if locx>=-sx and locx<=sx and locz>=-sz and locz<=sz then
							low,hit,best,sfc,spos=s5,o,vec,5,Vector2.new(locx,locz)
						end
					end
					if s6>0 and s6<low then
						local vec=pos+dir*s6
						local nub=vec-p
						local locx,locy=dot(ax,nub),dot(ay,nub)
						if locx>=-sx and locx<=sx and locy>=-sy and locy<=sy then
							low,hit,best,sfc,spos=s6,o,vec,6,Vector2.new(locx,locy)
						end
					end
				end
			end
		end
	end
	return hit,best,sfc,spos,low--Object hit, position of intersection,position on surface (double %),distance
end
local raycast=raycast

--[[Skybox:
	U
	R F L B
	D
--]]
---[=[
local SKYBOX={
	U=graphics.newImage'sky/U.png',
	R=graphics.newImage'sky/R.png',
	F=graphics.newImage'sky/F.png',
	L=graphics.newImage'sky/L.png',
	B=graphics.newImage'sky/B.png',
	D=graphics.newImage'sky/D.png'
}
--]=]
local sky=graphics.newPixelEffect(filesystem.read'glsl/sky.glsl')
local shader=graphics.newPixelEffect(filesystem.read'glsl/shader.glsl':gsub("%%WTF%%",graphics.getWidth()*graphics.getHeight()))

local function poly(v1,v2,v3,v4)
	polygon("fill",v1.x,v1.y,v2.x,v2.y,v3.x,v3.y,v4.x,v4.y)
end
local setColor=graphics.setColor
local setEffect=graphics.setPixelEffect
local renderBrick=function(self,c)
	setColor(self.Colour:unpack())
	local p=self.Pos
	local q=self.Quaternion
	local ax,ay,az=q.ux,q.uy,q.uz
	local sx,sy,sz=self.Size.x/2,self.Size.y/2,self.Size.z/2
	local ux,uy,uz=ax*sx,ay*sy,az*sz
	local xt,yt,zt={ux:unpack()},{uy:unpack()},{uz:unpack()}
	local Xt,Yt,Zt={(-ux):unpack()},{(-uy):unpack()},{(-uz):unpack()}
	local v1=worldToScreen(c,p+ux+uy+uz)
	local v2=worldToScreen(c,p+ux+uy-uz)
	local v3=worldToScreen(c,p+ux-uy+uz)
	local v4=worldToScreen(c,p+ux-uy-uz)
	local v5=worldToScreen(c,p-ux+uy+uz)
	local v6=worldToScreen(c,p-ux+uy-uz)
	local v7=worldToScreen(c,p-ux-uy+uz)
	local v8=worldToScreen(c,p-ux-uy-uz)
	local campos=(c.Pos-p)*q
	if v1 and v2 and v3 and v4 and campos.x>sx then--Works when the Quaternion isn't messed up
		shader:send("img",self.Right)
		shader:send("n",{ax:unpack()})
		shader:send("p0",{(p+ux):unpack()})
		shader:send("pp1",Zt)
		shader:send("pp2",yt)
		shader:send("rep",self.Repeated[1] or {sz,sy})
		poly(v3,v4,v2,v1)
	end
	if v5 and v6 and v7 and v8 and campos.x<-sx then
		shader:send("img",self.Left)
		shader:send("n",{(-ax):unpack()})
		shader:send("p0",{(p-ux):unpack()})
		shader:send("pp1",zt)
		shader:send("pp2",yt)
		shader:send("rep",self.Repeated[4] or {sz,sy})
		poly(v5,v6,v8,v7)
	end
	if v1 and v2 and v5 and v6 and campos.y>sy then
		shader:send("img",self.Top)
		shader:send("n",{ay:unpack()})
		shader:send("p0",{(p+uy):unpack()})
		shader:send("pp1",xt)
		shader:send("pp2",Zt)
		shader:send("rep",self.Repeated[2] or {sx,sz})
		poly(v1,v2,v6,v5)
	end
	if v3 and v4 and v7 and v8 and campos.y<-sy then
		shader:send("img",self.Bottom)
		shader:send("n",{(-ay):unpack()})
		shader:send("p0",{(p-uy):unpack()})
		shader:send("pp1",xt)
		shader:send("pp2",zt)
		shader:send("rep",self.Repeated[5] or {sx,sz})
		poly(v7,v8,v4,v3)
	end
	if v1 and v3 and v5 and v7 and campos.z>sz then
		shader:send("img",self.Front)
		shader:send("n",{az:unpack()})
		shader:send("p0",{(p+uz):unpack()})
		shader:send("pp1",Xt)
		shader:send("pp2",yt)
		shader:send("rep",self.Repeated[3] or {sx,sy})
		poly(v5,v7,v3,v1)
	end
	if v2 and v4 and v6 and v8 and campos.z<-sz then
		shader:send("img",self.Back)
		shader:send("n",{(-az):unpack()})
		shader:send("p0",{(p-uz):unpack()})
		shader:send("pp1",xt)
		shader:send("pp2",yt)
		shader:send("rep",self.Repeated[6] or {sx,sy})
		poly(v2,v4,v8,v6)
	end
end
local updateBrick=function(self,delta)
	self.Pos=self.Pos+self.Vel*delta
	self.Quaternion=self.Quaternion*Quaternion.FromAxisAngle(self.Rot*delta)
end
local updateSound=function(self)
	--
end

m=new'Mouse'

local cam=new'Camera'
sky:send("fov",{tan(cam.FOV*pi/360)})
sky:send("q",{cam.Quaternion.x,cam.Quaternion.y,cam.Quaternion.z,cam.Quaternion.w})

shader:send("fov",{tan(cam.FOV*pi/360)})
shader:send("p",{cam.Pos:unpack()})
shader:send("q",{cam.Quaternion.x,cam.Quaternion.y,cam.Quaternion.z,cam.Quaternion.w})

local sort=sort
local function dis(a,b)
	if a and b then
		return (b.Pos-cam.Pos).magnitude<(a.Pos-cam.Pos).magnitude
	end
end

--local fID=1
local empty=Colour4.new()
local rect=graphics.rectangle
function love.draw()
	setEffect(sky)
	setColor(empty:unpack())
	rect("fill",0,0,graphics.getWidth(),graphics.getHeight())
	setEffect(shader)
	--shader:send("frameID",fID)
	sort(renderlist,dis)
	for _,o in next,renderlist do
		if o.Visible then
			renderBrick(o,cam)
		end
	end
	setEffect()
	setColor(empty:unpack())
	local p,q=cam.Pos,cam.Quaternion
	graphics.print("FOV: "..format("%.2f",cam.FOV),0,0)
	graphics.print("Pos: "..format("%.2f",p.x)..", "..format("%.2f",p.y)..", "..format("%.2f",p.z),0,20)
	graphics.print("Quaternion: "..format("%.2f",q.w)..", "..format("%.2f",q.x)..", "..format("%.2f",q.y)..", "..format("%.2f",q.z),0,40)
	graphics.print("Mouse Direction: "..format("%.2f",m.Direction.x)..", "..format("%.2f",m.Direction.y)..", "..format("%.2f",m.Direction.z),0,60)
	graphics.print("Target: "..tostring(m.Target).." on "..tostring(m.TargetSurface),0,80)
	graphics.setCaption("3D Rendering Engine - "..format("%.1f",1/timer.getDelta()).." FPS")
	--fID=fID+1
end

local sfcs={"Right","Top","Front","Left","Bottom","Back"}
function love.update(t)
	local newPos=Vector2.new(mouse.getPosition())
	m.ViewSize=Vector2.new(graphics.getWidth(),graphics.getHeight())
	local deltaPos=3*sin(cam.FOV*pi/360)*(newPos-m.Pos)/m.ViewSize
	m.Pos=newPos
	for _,o in next,physiclist do
		if not o.Anchored then
			updateBrick(o,t)
		end
	end
	for _,o in next,soundlist do
		local obj=o.Object
		if obj and o.src then
			--o:setDirection(ref.Quaternion.uz:unpack())
			o:setPosition(obj.Pos:unpack())
			o:setVelocity(obj.Vel:unpack())
		end
	end
	local move_x,move_y,move_z=0,0,0
	local rot_x,rot_y,rot_z=0,0,0
	if keyboard.isDown'd' then
		move_x=move_x+1
	end
	if keyboard.isDown'a' then
		move_x=move_x-1
	end
	if keyboard.isDown' ' then
		move_y=move_y+1
	end
	if keyboard.isDown'lshift' then
		move_y=move_y-1
	end
	if keyboard.isDown'w' then
		move_z=move_z-1
	end
	if keyboard.isDown's' then
		move_z=move_z+1
	end
	if keyboard.isDown'up' then
		rot_x=rot_x+1
	end
	if keyboard.isDown'down' then
		rot_x=rot_x-1
	end
	if keyboard.isDown'left' then
		rot_y=rot_y+1
	end
	if keyboard.isDown'right' then
		rot_y=rot_y-1
	end
	if keyboard.isDown'q' then
		rot_z=rot_z+1
	end
	if keyboard.isDown'e' then
		rot_z=rot_z-1
	end
	if keyboard.isDown'i' then
		cam.FOV=cam.FOV-t*10
		shader:send("fov",{tan(cam.FOV*pi/360)})
		sky:send("fov",{tan(cam.FOV*pi/360)})
	end
	if keyboard.isDown'o' then
		cam.FOV=cam.FOV+t*10
		shader:send("fov",{tan(cam.FOV*pi/360)})
		sky:send("fov",{tan(cam.FOV*pi/360)})
	end
	if keyboard.isDown'r' then
		cam.Pos=Vector3.new()
		cam.Quaternion=Quaternion.new()
		cam.FOV=70
		shader:send("fov",{tan(cam.FOV*pi/360)})
		sky:send("fov",{tan(cam.FOV*pi/360)})
	else
		local camDelta=cam.Quaternion*(cam.Speed*t*Vector3.new(move_x,move_y,move_z))
		cam.Pos=cam.Pos+camDelta
		local rot=cam.Spin*t*Vector3.new(rot_x,rot_y,rot_z)
		if mouse.isDown'r' then
			rot=rot+Vector3.new(deltaPos.y,deltaPos.x,0)
		end
		cam.Quaternion=cam.Quaternion*Quaternion.FromAxisAngle(rot)
		audio.setVelocity(camDelta:unpack())
		--local rx,ry,rz=cam.Quaternion.ux:unpack()
		local ux,uy,uz=cam.Quaternion.uy:unpack()
		local fx,fy,fz=cam.Quaternion.uz:unpack()
		audio.setOrientation(fx,fy,fz,ux,uy,uz)
		shader:send("p",{cam.Pos:unpack()})
		shader:send("q",{cam.Quaternion.x,cam.Quaternion.y,cam.Quaternion.z,cam.Quaternion.w})
		sky:send("q",{cam.Quaternion.x,cam.Quaternion.y,cam.Quaternion.z,cam.Quaternion.w})
	end
	local dir=screenToWorld(cam,newPos)
	m.Direction=dir
	--sky:send("m",{dir:unpack()})
	local hit,best,sfc=raycast(cam.Pos,dir)
	local s=sfcs[sfc]
	--[[
	if m.Target and m.TargetSurface then
		m.Target[m.TargetSurface]="fill"
	end
	if hit then
		hit[s]="line"
	end
	--]]
	m.Target,m.TargetSurface=hit,s
	if keyboard.isDown'escape' then
		event.quit()
	end
end

function love.load()
	--texture.preload(true)
	graphics.setIcon(graphics.newImage'textures/Little iron pot.png')
	sky:send("vs",{graphics.getWidth(),graphics.getHeight()})
	shader:send("vs",{graphics.getWidth(),graphics.getHeight()})
	shader:send("ambient",{0.2,0.2,0.2})
	for i,v in next,SKYBOX do
		sky:send(i,v)
	end
	shader:send("sun",{sqrt(3)/3,sqrt(3)/3,sqrt(3)/3})
	sky:send("sun",{sqrt(3)/3,sqrt(3)/3,sqrt(3)/3})
--[[
	local ooshiny=graphics.newImage'textures/Spectrum.png'
	local n=10
	local rn=sqrt(n)
	for i=1,n do
		local b=new'Brick'
		b.Pos=5*Vector3.new(rand(-rn,rn),rand(-rn,rn),rand(-rn,rn))
		b.Quaternion=(Quaternion.FromAxisAngle(Vector3.new(rand(-1,1),rand(-1,1),rand(-1,1)),2*random()*pi)).unit
		b.Size=Vector3.new(n*(random())^2,n*random()^2,n*random()^2)
		b.Colour=Colour4.new(random()*255,random()*255,random()*255,sqrt(random())*255)
		b.Vel=Vector3.new(rand(-1,1),rand(-1,1),rand(-1,1))
		b.Rot=Vector3.new(rand(-1,1),rand(-1,1),rand(-1,1))
		b.Front=ooshiny
		b.Repeated[3]={3,2}
	end
--]]
--[[
	local focus=new'Brick'
	focus.Vel=Vector3.new()
	focus.Colour=Colour4.new(random()*255,random()*255,random()*255,(0.5+sqrt(random())/2)*255)
	focus.Size=Vector3.new(10,10,1)
	focus.Front=graphics.newImage'textures/Breaking Benjamin.png'
--]]
--[[
	local s=new'Sound'
	s.Object=focus
	s.Source="sounds/Cthulhu Sleeps.mp3"
	s:play()
--]]
---[[
	local yolo={}
yolo[1]=new'Brick' yolo[1].Pos=Vector3.new(-121.5, -3.10000014, 113) yolo[1].Size=Vector3.new(69, 33, 16) yolo[1].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[1].Quaternion=Quaternion.new(1,0,0,0).unit yolo[1].Anchored=true yolo[1].Right=default.Universal yolo[1].Top=default.Universal yolo[1].Front=default.Universal yolo[1].Left=default.Universal yolo[1].Bottom=default.Universal yolo[1].Back=default.Universal
yolo[2]=new'Brick' yolo[2].Pos=Vector3.new(-37.8979797, 15.6341476, 133) yolo[2].Size=Vector3.new(35, 13, 12) yolo[2].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[2].Quaternion=Quaternion.new(1.5257823030199e-005,-0.087139056895739,0.99619615813761,1.5259145920086e-005).unit yolo[2].Anchored=true yolo[2].Right=default.Universal yolo[2].Top=default.Universal yolo[2].Front=default.Universal yolo[2].Left=default.Universal yolo[2].Bottom=default.Universal yolo[2].Back=default.Universal
yolo[3]=new'Brick' yolo[3].Pos=Vector3.new(-133.056732, -2.6998558, 110.351563) yolo[3].Size=Vector3.new(23, 21, 32) yolo[3].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[3].Quaternion=Quaternion.new(0.67439433465722,0.67437428653041,-0.21263501242965,0.21259817057203).unit yolo[3].Anchored=true yolo[3].Right=default.Universal yolo[3].Top=default.Universal yolo[3].Front=default.Universal yolo[3].Left=default.Universal yolo[3].Bottom=default.Universal yolo[3].Back=default.Universal
yolo[4]=new'Brick' yolo[4].Pos=Vector3.new(-69.4202271, -1.89983749, 121.180908) yolo[4].Size=Vector3.new(47, 31, 12) yolo[4].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[4].Quaternion=Quaternion.new(0.96592053085325,-1.5258644637774e-005,-0.25883632287312,-1.5258644637774e-005).unit yolo[4].Anchored=true yolo[4].Right=default.Universal yolo[4].Top=default.Universal yolo[4].Front=default.Universal yolo[4].Left=default.Universal yolo[4].Bottom=default.Universal yolo[4].Back=default.Universal
yolo[5]=new'Brick' yolo[5].Pos=Vector3.new(-133, -15.1998825, 94) yolo[5].Size=Vector3.new(2, 5, 4) yolo[5].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[5].Quaternion=Quaternion.new(1.5258291546429e-005,1.5258196142661e-005,0.1305363007305,0.99144353533434).unit yolo[5].Anchored=true yolo[5].Right=default.Universal yolo[5].Top=default.Universal yolo[5].Front=default.Universal yolo[5].Left=default.Universal yolo[5].Bottom=default.Universal yolo[5].Back=default.Universal
yolo[6]=new'Brick' yolo[6].Pos=Vector3.new(-52.6797791, -20.3999424, 122.185791) yolo[6].Size=Vector3.new(7, 12, 25) yolo[6].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[6].Quaternion=Quaternion.new(-0.49999668593199,1.5258848341954e-005,0.86602731369039,1.5258691600841e-005).unit yolo[6].Anchored=true yolo[6].Right=default.Universal yolo[6].Top=default.Universal yolo[6].Front=default.Universal yolo[6].Left=default.Universal yolo[6].Bottom=default.Universal yolo[6].Back=default.Universal
yolo[7]=new'Brick' yolo[7].Pos=Vector3.new(-51.4788361, -21.8999557, 117.105469) yolo[7].Size=Vector3.new(22, 9, 7) yolo[7].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[7].Quaternion=Quaternion.new(0.25882349886064,1.5257773822389e-005,0.96592463440042,1.5258944676326e-005).unit yolo[7].Anchored=true yolo[7].Right=default.Universal yolo[7].Top=default.Universal yolo[7].Front=default.Universal yolo[7].Left=default.Universal yolo[7].Bottom=default.Universal yolo[7].Back=default.Universal
yolo[8]=new'Brick' yolo[8].Pos=Vector3.new(-57.067337, -16.3999252, 90.7849121) yolo[8].Size=Vector3.new(55, 12, 14) yolo[8].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[8].Quaternion=Quaternion.new(1.5258403951897e-005,0.50000814030445,1.5258584061149e-005,0.86602070643027).unit yolo[8].Anchored=true yolo[8].Right=default.Universal yolo[8].Top=default.Universal yolo[8].Front=default.Universal yolo[8].Left=default.Universal yolo[8].Bottom=default.Universal yolo[8].Back=default.Universal
yolo[9]=new'Brick' yolo[9].Pos=Vector3.new(-50.3938904, -19.8999367, 110.226318) yolo[9].Size=Vector3.new(8, 11, 17) yolo[9].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[9].Quaternion=Quaternion.new(-0.49999668593199,1.5258848341954e-005,0.86602731369039,1.5258691600841e-005).unit yolo[9].Anchored=true yolo[9].Right=default.Universal yolo[9].Top=default.None yolo[9].Front=default.Universal yolo[9].Left=default.Universal yolo[9].Bottom=default.Universal yolo[9].Back=default.Universal
yolo[10]=new'Brick' yolo[10].Pos=Vector3.new(-120.5, -16.199913, 95) yolo[10].Size=Vector3.new(3, 2, 1) yolo[10].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[10].Quaternion=Quaternion.new(0.67435451614584,-0.67440148886497,-0.21263396393187,-0.2126391626708).unit yolo[10].Anchored=true yolo[10].Right=default.Universal yolo[10].Top=default.Universal yolo[10].Front=default.Universal yolo[10].Left=default.Universal yolo[10].Bottom=default.Universal yolo[10].Back=default.Universal
yolo[11]=new'Brick' yolo[11].Pos=Vector3.new(-92.9703064, -17.6001396, 102.831299) yolo[11].Size=Vector3.new(8, 1, 12) yolo[11].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[11].Quaternion=Quaternion.new(0.57354382664775,-1.5258557281753e-005,-0.81917489412669,-1.5259395546615e-005).unit yolo[11].Anchored=true yolo[11].Right=default.None yolo[11].Top=default.None yolo[11].Front=default.None yolo[11].Left=default.None yolo[11].Bottom=default.None yolo[11].Back=default.None
yolo[12]=new'Brick' yolo[12].Pos=Vector3.new(-85.6234131, -17.6001396, 106.066406) yolo[12].Size=Vector3.new(5, 1, 8) yolo[12].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[12].Quaternion=Quaternion.new(-0.30067152847578,1.5258511583047e-005,0.95372775045618,1.5259000790561e-005).unit yolo[12].Anchored=true yolo[12].Right=default.None yolo[12].Top=default.None yolo[12].Front=default.None yolo[12].Left=default.None yolo[12].Bottom=default.None yolo[12].Back=default.None
yolo[13]=new'Brick' yolo[13].Pos=Vector3.new(-103, -15.1999283, 92) yolo[13].Size=Vector3.new(3, 3, 3) yolo[13].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[13].Quaternion=Quaternion.new(0.35355106399308,0.35356011046032,-0.6123480683109,0.612394261099).unit yolo[13].Anchored=true yolo[13].Right=default.None yolo[13].Top=default.None yolo[13].Front=default.None yolo[13].Left=default.None yolo[13].Bottom=default.None yolo[13].Back=default.None
yolo[14]=new'Brick' yolo[14].Pos=Vector3.new(-69.9857635, -9.30943298, 86.2368164) yolo[14].Size=Vector3.new(22, 1, 9) yolo[14].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[14].Quaternion=Quaternion.new(0.050511155096084,-0.29424840383028,0.75390082935499,0.58523502039324).unit yolo[14].Anchored=true yolo[14].Right=default.None yolo[14].Top=default.None yolo[14].Front=default.None yolo[14].Left=default.None yolo[14].Bottom=default.None yolo[14].Back=default.None
yolo[15]=new'Brick' yolo[15].Pos=Vector3.new(-75.0142365, -7.89086533, 94.7631836) yolo[15].Size=Vector3.new(22, 1, 9) yolo[15].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[15].Quaternion=Quaternion.new(0.050511155096084,-0.29424840383028,0.75390082935499,0.58523502039324).unit yolo[15].Anchored=true yolo[15].Right=default.None yolo[15].Top=default.None yolo[15].Front=default.None yolo[15].Left=default.None yolo[15].Bottom=default.None yolo[15].Back=default.None
yolo[16]=new'Brick' yolo[16].Pos=Vector3.new(-73.5732422, -4.95171738, 89.2600098) yolo[16].Size=Vector3.new(22, 11, 1) yolo[16].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[16].Quaternion=Quaternion.new(0.050511155096084,-0.29424840383028,0.75390082935499,0.58523502039324).unit yolo[16].Anchored=true yolo[16].Right=default.None yolo[16].Top=default.None yolo[16].Front=default.None yolo[16].Left=default.None yolo[16].Bottom=default.None yolo[16].Back=default.None
yolo[17]=new'Brick' yolo[17].Pos=Vector3.new(-71.4267578, -12.2485275, 91.7399902) yolo[17].Size=Vector3.new(22, 11, 1) yolo[17].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[17].Quaternion=Quaternion.new(0.050511155096084,-0.29424840383028,0.75390082935499,0.58523502039324).unit yolo[17].Anchored=true yolo[17].Right=default.None yolo[17].Top=default.None yolo[17].Front=default.None yolo[17].Left=default.None yolo[17].Bottom=default.None yolo[17].Back=default.None
yolo[18]=new'Brick' yolo[18].Pos=Vector3.new(-58.2071228, -17.0803413, 112.043701) yolo[18].Size=Vector3.new(5, 2, 5) yolo[18].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[18].Quaternion=Quaternion.new(-0.44272993739505,0.11259603716978,0.84313150095148,0.28362230451626).unit yolo[18].Anchored=true yolo[18].Right=default.Universal yolo[18].Top=default.Universal yolo[18].Front=default.Universal yolo[18].Left=default.Universal yolo[18].Bottom=default.Universal yolo[18].Back=default.Universal
yolo[19]=new'Brick' yolo[19].Pos=Vector3.new(-79.5, -18.6001396, 91.5) yolo[19].Size=Vector3.new(62, 2, 37) yolo[19].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[19].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,0).unit yolo[19].Anchored=true yolo[19].Right=default.Universal yolo[19].Top=default.Universal yolo[19].Front=default.Universal yolo[19].Left=default.Universal yolo[19].Bottom=default.Universal yolo[19].Back=default.Universal
yolo[20]=new'Brick' yolo[20].Pos=Vector3.new(-102, -15.6999283, 96) yolo[20].Size=Vector3.new(3, 3, 3) yolo[20].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[20].Quaternion=Quaternion.new(0.2561123363625,0.3379960745686,-0.62528869901251,0.65511766858447).unit yolo[20].Anchored=true yolo[20].Right=default.None yolo[20].Top=default.None yolo[20].Front=default.None yolo[20].Left=default.None yolo[20].Bottom=default.None yolo[20].Back=default.None
yolo[21]=new'Brick' yolo[21].Pos=Vector3.new(-61.7192078, -19.8999367, 104.842285) yolo[21].Size=Vector3.new(28, 11, 10) yolo[21].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[21].Quaternion=Quaternion.new(-0.49999668593199,1.5258848341954e-005,0.86602731369039,1.5258691600841e-005).unit yolo[21].Anchored=true yolo[21].Right=default.Universal yolo[21].Top=default.Universal yolo[21].Front=default.Universal yolo[21].Left=default.Universal yolo[21].Bottom=default.Universal yolo[21].Back=default.Universal
yolo[22]=new'Brick' yolo[22].Pos=Vector3.new(-50, -16.6999397, 93) yolo[22].Size=Vector3.new(33, 5, 19) yolo[22].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[22].Quaternion=Quaternion.new(0.70709523273549,-1.5258789774987e-005,-0.70711830875245,-1.5258630912989e-005).unit yolo[22].Anchored=true yolo[22].Right=default.Universal yolo[22].Top=default.None yolo[22].Front=default.Universal yolo[22].Left=default.None yolo[22].Bottom=default.Universal yolo[22].Back=default.None
yolo[23]=new'Brick' yolo[23].Pos=Vector3.new(-35.1094055, -14.8999252, 116.730225) yolo[23].Size=Vector3.new(4, 1, 5) yolo[23].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[23].Quaternion=Quaternion.new(0.70642104609468,-0.70644228763244,0.030838285743423,0.030838285743423).unit yolo[23].Anchored=true yolo[23].Right=default.None yolo[23].Top=default.None yolo[23].Front=default.None yolo[23].Left=default.None yolo[23].Bottom=default.None yolo[23].Back=default.None
yolo[24]=new'Brick' yolo[24].Pos=Vector3.new(-28.7849731, -11.8395309, 120.820068) yolo[24].Size=Vector3.new(11, 1, 17) yolo[24].Colour=Colour4.new(27.000002190471,42.000001296401,53.000004440546,255) yolo[24].Quaternion=Quaternion.new(0.64432761848077,0.22170364385389,0.70315153880822,0.20314353431681).unit yolo[24].Anchored=true yolo[24].Right=default.None yolo[24].Top=default.None yolo[24].Front=default.None yolo[24].Left=default.None yolo[24].Bottom=default.None yolo[24].Back=default.None
yolo[25]=new'Brick' yolo[25].Pos=Vector3.new(-37.1268005, -13.1999092, 117.262207) yolo[25].Size=Vector3.new(1, 1, 9) yolo[25].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[25].Quaternion=Quaternion.new(0.47769088804956,-0.47769525061228,0.52133433165772,0.52137240786299).unit yolo[25].Anchored=true yolo[25].Right=default.None yolo[25].Top=default.None yolo[25].Front=default.None yolo[25].Left=default.None yolo[25].Bottom=default.None yolo[25].Back=default.None
yolo[26]=new'Brick' yolo[26].Pos=Vector3.new(-21.1876831, -13.1999092, 115.86792) yolo[26].Size=Vector3.new(1, 1, 9) yolo[26].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[26].Quaternion=Quaternion.new(0.47769088804956,-0.47769525061228,0.52133433165772,0.52137240786299).unit yolo[26].Anchored=true yolo[26].Right=default.None yolo[26].Top=default.None yolo[26].Front=default.None yolo[26].Left=default.None yolo[26].Bottom=default.None yolo[26].Back=default.None
yolo[27]=new'Brick' yolo[27].Pos=Vector3.new(-24, -2.6998558, 133) yolo[27].Size=Vector3.new(51, 31, 12) yolo[27].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[27].Quaternion=Quaternion.new(1,-1.52587890625e-005,-1.52587890625e-005,-1.52587890625e-005).unit yolo[27].Anchored=true yolo[27].Right=default.Universal yolo[27].Top=default.Universal yolo[27].Front=default.Universal yolo[27].Left=default.Universal yolo[27].Bottom=default.Universal yolo[27].Back=default.Universal
yolo[28]=new'Brick' yolo[28].Pos=Vector3.new(-11.3869019, 12.3317146, 133) yolo[28].Size=Vector3.new(30, 14, 12) yolo[28].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[28].Quaternion=Quaternion.new(0.9762938778501,-1.5258688667956e-005,-1.5258688667956e-005,-0.21644778272169).unit yolo[28].Anchored=true yolo[28].Right=default.Universal yolo[28].Top=default.Universal yolo[28].Front=default.Universal yolo[28].Left=default.Universal yolo[28].Bottom=default.Universal yolo[28].Back=default.Universal
yolo[29]=new'Brick' yolo[29].Pos=Vector3.new(-24.6360168, -15.4000778, 59.3972168) yolo[29].Size=Vector3.new(1, 1, 2) yolo[29].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[29].Quaternion=Quaternion.new(0.84338102396839,-1.5258795954047e-005,-0.5373161949661,-1.5258795954047e-005).unit yolo[29].Anchored=true yolo[29].Right=default.None yolo[29].Top=default.None yolo[29].Front=default.None yolo[29].Left=default.None yolo[29].Bottom=default.None yolo[29].Back=default.None
yolo[30]=new'Brick' yolo[30].Pos=Vector3.new(-24.5749512, -16.400135, 57.1618652) yolo[30].Size=Vector3.new(1, 3, 5) yolo[30].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[30].Quaternion=Quaternion.new(0.97630063933012,-1.5258583457976e-005,0.21641583423914,-1.5258583457976e-005).unit yolo[30].Anchored=true yolo[30].Right=default.None yolo[30].Top=default.None yolo[30].Front=default.None yolo[30].Left=default.None yolo[30].Bottom=default.None yolo[30].Back=default.None
yolo[31]=new'Brick' yolo[31].Pos=Vector3.new(-26.3264923, -15.4000778, 55.7719727) yolo[31].Size=Vector3.new(1, 1, 2) yolo[31].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[31].Quaternion=Quaternion.new(0.84338102396839,-1.5258795954047e-005,-0.5373161949661,-1.5258795954047e-005).unit yolo[31].Anchored=true yolo[31].Right=default.None yolo[31].Top=default.None yolo[31].Front=default.None yolo[31].Left=default.None yolo[31].Bottom=default.None yolo[31].Back=default.None
yolo[32]=new'Brick' yolo[32].Pos=Vector3.new(-122, -14.6999283, 79) yolo[32].Size=Vector3.new(1, 3, 5) yolo[32].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[32].Quaternion=Quaternion.new(0.66447276548247,0.24184702971643,0.24184024015465,0.66445413363912).unit yolo[32].Anchored=true yolo[32].Right=default.None yolo[32].Top=default.None yolo[32].Front=default.None yolo[32].Left=default.None yolo[32].Bottom=default.None yolo[32].Back=default.None
yolo[33]=new'Brick' yolo[33].Pos=Vector3.new(-29.5, -9.69992828, 40.5) yolo[33].Size=Vector3.new(5, 4, 1) yolo[33].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[33].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[33].Anchored=true yolo[33].Right=default.None yolo[33].Top=default.None yolo[33].Front=default.None yolo[33].Left=default.None yolo[33].Bottom=default.None yolo[33].Back=default.None
yolo[34]=new'Brick' yolo[34].Pos=Vector3.new(-35, -13.6999998, 36.5) yolo[34].Size=Vector3.new(5, 14, 9) yolo[34].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[34].Quaternion=Quaternion.new(-0.5,0.5,-0.5,-0.5).unit yolo[34].Anchored=true yolo[34].Right=default.None yolo[34].Top=default.None yolo[34].Front=default.None yolo[34].Left=default.None yolo[34].Bottom=default.None yolo[34].Back=default.None
yolo[35]=new'Brick' yolo[35].Pos=Vector3.new(20.859375, -6.69990158, 81.0126953) yolo[35].Size=Vector3.new(18, 39, 60) yolo[35].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[35].Quaternion=Quaternion.new(0.42262212417395,1.5258497759852e-005,0.90630598553012,1.525881236286e-005).unit yolo[35].Anchored=true yolo[35].Right=default.Universal yolo[35].Top=default.Universal yolo[35].Front=default.Universal yolo[35].Left=default.Universal yolo[35].Bottom=default.Universal yolo[35].Back=default.Universal
yolo[36]=new'Brick' yolo[36].Pos=Vector3.new(-49.5, -16.2000008, 43.5) yolo[36].Size=Vector3.new(19, 1, 4) yolo[36].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[36].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[36].Anchored=true yolo[36].Right=default.None yolo[36].Top=default.None yolo[36].Front=default.None yolo[36].Left=default.None yolo[36].Bottom=default.None yolo[36].Back=default.None
yolo[37]=new'Brick' yolo[37].Pos=Vector3.new(-49.5, -12.6999998, 38) yolo[37].Size=Vector3.new(8, 1, 7) yolo[37].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[37].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[37].Anchored=true yolo[37].Right=default.None yolo[37].Top=default.None yolo[37].Front=default.None yolo[37].Left=default.None yolo[37].Bottom=default.None yolo[37].Back=default.None
yolo[38]=new'Brick' yolo[38].Pos=Vector3.new(-29.5, -8.19999981, 34.5) yolo[38].Size=Vector3.new(1, 3, 4) yolo[38].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[38].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[38].Anchored=true yolo[38].Right=default.None yolo[38].Top=default.None yolo[38].Front=default.None yolo[38].Left=default.None yolo[38].Bottom=default.None yolo[38].Back=default.None
yolo[39]=new'Brick' yolo[39].Pos=Vector3.new(-7, -16.6999397, -7) yolo[39].Size=Vector3.new(5, 1, 5) yolo[39].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[39].Quaternion=Quaternion.new(1,-1.5258323401213e-005,-1.5258323401213e-005,-1.5258323401213e-005).unit yolo[39].Anchored=true yolo[39].Right=default.None yolo[39].Top=default.None yolo[39].Front=default.None yolo[39].Left=default.None yolo[39].Bottom=default.None yolo[39].Back=default.None
yolo[40]=new'Brick' yolo[40].Pos=Vector3.new(-42.5, -9.69992828, 38.5) yolo[40].Size=Vector3.new(9, 14, 1) yolo[40].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[40].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[40].Anchored=true yolo[40].Right=default.None yolo[40].Top=default.None yolo[40].Front=default.None yolo[40].Left=default.None yolo[40].Bottom=default.None yolo[40].Back=default.None
yolo[41]=new'Brick' yolo[41].Pos=Vector3.new(-121.480591, -15.6999435, 81.1750488) yolo[41].Size=Vector3.new(1, 1, 2) yolo[41].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[41].Quaternion=Quaternion.new(0.6408813425294,0.64084045396173,-0.2988513718523,0.298801730131).unit yolo[41].Anchored=true yolo[41].Right=default.None yolo[41].Top=default.None yolo[41].Front=default.None yolo[41].Left=default.None yolo[41].Bottom=default.None yolo[41].Back=default.None
yolo[42]=new'Brick' yolo[42].Pos=Vector3.new(-124.051697, -15.6999435, 78.1108398) yolo[42].Size=Vector3.new(1, 1, 2) yolo[42].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[42].Quaternion=Quaternion.new(0.6408813425294,0.64084045396173,-0.2988513718523,0.298801730131).unit yolo[42].Anchored=true yolo[42].Right=default.None yolo[42].Top=default.None yolo[42].Front=default.None yolo[42].Left=default.None yolo[42].Bottom=default.None yolo[42].Back=default.None
yolo[43]=new'Brick' yolo[43].Pos=Vector3.new(-119.948486, -15.6999435, 79.8894043) yolo[43].Size=Vector3.new(1, 1, 2) yolo[43].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[43].Quaternion=Quaternion.new(0.6408813425294,0.64084045396173,-0.2988513718523,0.298801730131).unit yolo[43].Anchored=true yolo[43].Right=default.None yolo[43].Top=default.None yolo[43].Front=default.None yolo[43].Left=default.None yolo[43].Bottom=default.None yolo[43].Back=default.None
yolo[44]=new'Brick' yolo[44].Pos=Vector3.new(-122.519653, -15.6999435, 76.8251953) yolo[44].Size=Vector3.new(1, 1, 2) yolo[44].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[44].Quaternion=Quaternion.new(0.6408813425294,0.64084045396173,-0.2988513718523,0.298801730131).unit yolo[44].Anchored=true yolo[44].Right=default.None yolo[44].Top=default.None yolo[44].Front=default.None yolo[44].Left=default.None yolo[44].Bottom=default.None yolo[44].Back=default.None
yolo[45]=new'Brick' yolo[45].Pos=Vector3.new(-132.5, -9.69999981, 61.5) yolo[45].Size=Vector3.new(33, 1, 15) yolo[45].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[45].Quaternion=Quaternion.new(-0.5,0.5,-0.5,-0.5).unit yolo[45].Anchored=true yolo[45].Right=default.Universal yolo[45].Top=default.Universal yolo[45].Front=default.Universal yolo[45].Left=default.Universal yolo[45].Bottom=default.Universal yolo[45].Back=default.Universal
yolo[46]=new'Brick' yolo[46].Pos=Vector3.new(-124.5, -16.1999435, 67.5) yolo[46].Size=Vector3.new(1, 2, 2) yolo[46].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[46].Quaternion=Quaternion.new(0.6532862645003,-0.27063211656721,-0.27061873734738,0.65325402309421).unit yolo[46].Anchored=true yolo[46].Right=default.Universal yolo[46].Top=default.Universal yolo[46].Front=default.Universal yolo[46].Left=default.Universal yolo[46].Bottom=default.Universal yolo[46].Back=default.Universal
yolo[47]=new'Brick' yolo[47].Pos=Vector3.new(-132.5, -16.5549507, 76.6166992) yolo[47].Size=Vector3.new(5, 1, 6) yolo[47].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[47].Quaternion=Quaternion.new(0.67439433891411,-0.21263499423254,0.21260969429493,0.67437065859193).unit yolo[47].Anchored=true yolo[47].Right=default.Universal yolo[47].Top=default.Universal yolo[47].Front=default.Universal yolo[47].Left=default.Universal yolo[47].Bottom=default.Universal yolo[47].Back=default.Universal
yolo[48]=new'Brick' yolo[48].Pos=Vector3.new(-144, -2.6998558, 53.5) yolo[48].Size=Vector3.new(108, 32, 23) yolo[48].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[48].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,0).unit yolo[48].Anchored=true yolo[48].Right=default.Universal yolo[48].Top=default.Universal yolo[48].Front=default.Universal yolo[48].Left=default.Universal yolo[48].Bottom=default.Universal yolo[48].Back=default.Universal
yolo[49]=new'Brick' yolo[49].Pos=Vector3.new(-127.5, -14.199913, 44) yolo[49].Size=Vector3.new(10, 1, 7) yolo[49].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[49].Quaternion=Quaternion.new(0.70710678118655,-0.70710678118655,-0,0).unit yolo[49].Anchored=true yolo[49].Right=default.Universal yolo[49].Top=default.Universal yolo[49].Front=default.Universal yolo[49].Left=default.Universal yolo[49].Bottom=default.Universal yolo[49].Back=default.Universal
yolo[50]=new'Brick' yolo[50].Pos=Vector3.new(-126, -19.1999969, 84) yolo[50].Size=Vector3.new(79, 3, 59) yolo[50].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[50].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,0).unit yolo[50].Anchored=true yolo[50].Right=default.Universal yolo[50].Top=default.Universal yolo[50].Front=default.Universal yolo[50].Left=default.Universal yolo[50].Bottom=default.Universal yolo[50].Back=default.Universal
yolo[51]=new'Brick' yolo[51].Pos=Vector3.new(-84.841507, -6.69991684, 58.4294434) yolo[51].Size=Vector3.new(9, 3, 5) yolo[51].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[51].Quaternion=Quaternion.new(0.68298537734613,-0.18302561897989,0.18300138123413,-0.68303960730586).unit yolo[51].Anchored=true yolo[51].Right=default.Universal yolo[51].Top=default.Universal yolo[51].Front=default.Universal yolo[51].Left=default.Universal yolo[51].Bottom=default.Universal yolo[51].Back=default.Universal
yolo[52]=new'Brick' yolo[52].Pos=Vector3.new(-89, -19.2001381, 40) yolo[52].Size=Vector3.new(2, 2, 2) yolo[52].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[52].Quaternion=Quaternion.new(1.5258966847484e-005,-0.34200350376421,1.5258942651039e-005,0.93969868486178).unit yolo[52].Anchored=true yolo[52].Right=default.Universal yolo[52].Top=default.Universal yolo[52].Front=default.Universal yolo[52].Left=default.Universal yolo[52].Bottom=default.Universal yolo[52].Back=default.Universal
yolo[53]=new'Brick' yolo[53].Pos=Vector3.new(-103.529694, -14.0287857, 65) yolo[53].Size=Vector3.new(1, 1, 2) yolo[53].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[53].Quaternion=Quaternion.new(-0.12276467097961,-0.69636170043702,-0.12276170910798,0.69637546648932).unit yolo[53].Anchored=true yolo[53].Right=default.None yolo[53].Top=default.None yolo[53].Front=default.None yolo[53].Left=default.None yolo[53].Bottom=default.None yolo[53].Back=default.None
yolo[54]=new'Brick' yolo[54].Pos=Vector3.new(-103.529694, -14.0287857, 69) yolo[54].Size=Vector3.new(1, 1, 2) yolo[54].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[54].Quaternion=Quaternion.new(0.12279153612913,0.69638211560253,0.12279040671494,-0.6963452298521).unit yolo[54].Anchored=true yolo[54].Right=default.None yolo[54].Top=default.None yolo[54].Front=default.None yolo[54].Left=default.None yolo[54].Bottom=default.None yolo[54].Back=default.None
yolo[55]=new'Brick' yolo[55].Pos=Vector3.new(-102.845673, -15.908165, 65) yolo[55].Size=Vector3.new(1, 1, 2) yolo[55].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[55].Quaternion=Quaternion.new(-0.12276467097961,-0.69636170043702,-0.12276170910798,0.69637546648932).unit yolo[55].Anchored=true yolo[55].Right=default.None yolo[55].Top=default.None yolo[55].Front=default.None yolo[55].Left=default.None yolo[55].Bottom=default.None yolo[55].Back=default.None
yolo[56]=new'Brick' yolo[56].Pos=Vector3.new(-102.248047, -14.6262131, 67) yolo[56].Size=Vector3.new(1, 3, 5) yolo[56].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[56].Quaternion=Quaternion.new(1.5257694439313e-005,0.98480437768801,0.17366729869995,1.5259059875888e-005).unit yolo[56].Anchored=true yolo[56].Right=default.None yolo[56].Top=default.None yolo[56].Front=default.None yolo[56].Left=default.None yolo[56].Bottom=default.None yolo[56].Back=default.None
yolo[57]=new'Brick' yolo[57].Pos=Vector3.new(-102.845673, -15.908165, 69) yolo[57].Size=Vector3.new(1, 1, 2) yolo[57].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[57].Quaternion=Quaternion.new(-0.12276467097961,-0.69636170043702,-0.12276170910798,0.69637546648932).unit yolo[57].Anchored=true yolo[57].Right=default.None yolo[57].Top=default.None yolo[57].Front=default.None yolo[57].Left=default.None yolo[57].Bottom=default.None yolo[57].Back=default.None
yolo[58]=new'Brick' yolo[58].Pos=Vector3.new(2.5, -7.19991684, 10.5) yolo[58].Size=Vector3.new(3, 3, 3) yolo[58].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[58].Quaternion=Quaternion.new(0.18302563097906,-0.1829895642292,0.68301911926319,-0.683009027785).unit yolo[58].Anchored=true yolo[58].Right=default.None yolo[58].Top=default.None yolo[58].Front=default.None yolo[58].Left=default.None yolo[58].Bottom=default.None yolo[58].Back=default.None
yolo[59]=new'Brick' yolo[59].Pos=Vector3.new(2.98210144, -10.4578781, 10.0584717) yolo[59].Size=Vector3.new(3, 3, 3) yolo[59].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[59].Quaternion=Quaternion.new(-0.18025198147341,-0.12553513870387,-0.67543477894466,0.7039446001053).unit yolo[59].Anchored=true yolo[59].Right=default.None yolo[59].Top=default.None yolo[59].Front=default.None yolo[59].Left=default.None yolo[59].Bottom=default.None yolo[59].Back=default.None
yolo[60]=new'Brick' yolo[60].Pos=Vector3.new(-81.5, -18.6999321, 32.5) yolo[60].Size=Vector3.new(3, 3, 3) yolo[60].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[60].Quaternion=Quaternion.new(-0.24183454391991,-0.2418375765616,0.66447731089336,-0.66445508260672).unit yolo[60].Anchored=true yolo[60].Right=default.None yolo[60].Top=default.None yolo[60].Front=default.None yolo[60].Left=default.None yolo[60].Bottom=default.None yolo[60].Back=default.None
yolo[61]=new'Brick' yolo[61].Pos=Vector3.new(12.2701416, -15.0711899, 5.14172363) yolo[61].Size=Vector3.new(6, 4, 6) yolo[61].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[61].Quaternion=Quaternion.new(0.96671752604063,-0.05622873470505,0.1082308425324,-0.22489979438506).unit yolo[61].Anchored=true yolo[61].Right=default.Universal yolo[61].Top=default.Universal yolo[61].Front=default.Universal yolo[61].Left=default.Universal yolo[61].Bottom=default.Universal yolo[61].Back=default.Universal
yolo[62]=new'Brick' yolo[62].Pos=Vector3.new(-52.5, -18.7000008, 22) yolo[62].Size=Vector3.new(23, 2, 12) yolo[62].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[62].Quaternion=Quaternion.new(1,0,0,0).unit yolo[62].Anchored=true yolo[62].Right=default.Universal yolo[62].Top=default.Universal yolo[62].Front=default.Universal yolo[62].Left=default.Universal yolo[62].Bottom=default.Universal yolo[62].Back=default.Universal
yolo[63]=new'Brick' yolo[63].Pos=Vector3.new(-101.5, -14.199913, 44) yolo[63].Size=Vector3.new(10, 1, 7) yolo[63].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[63].Quaternion=Quaternion.new(0.70710678118655,-0.70710678118655,-0,0).unit yolo[63].Anchored=true yolo[63].Right=default.Universal yolo[63].Top=default.Universal yolo[63].Front=default.Universal yolo[63].Left=default.Universal yolo[63].Bottom=default.Universal yolo[63].Back=default.Universal
yolo[64]=new'Brick' yolo[64].Pos=Vector3.new(-30.5, -6.15747452, 26.0714111) yolo[64].Size=Vector3.new(1, 17, 5) yolo[64].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[64].Quaternion=Quaternion.new(0.79333202140229,-0.60878908682642,-1.5258785986894e-005,-1.5258785986894e-005).unit yolo[64].Anchored=true yolo[64].Right=default.None yolo[64].Top=default.None yolo[64].Front=default.None yolo[64].Left=default.None yolo[64].Bottom=default.None yolo[64].Back=default.None
yolo[65]=new'Brick' yolo[65].Pos=Vector3.new(-18.5, -11.199913, 10.5) yolo[65].Size=Vector3.new(38, 17, 13) yolo[65].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[65].Quaternion=Quaternion.new(0.70709523273549,-0.70711830875245,-1.5258789771533e-005,-1.5258629630163e-005).unit yolo[65].Anchored=true yolo[65].Right=default.None yolo[65].Top=default.None yolo[65].Front=default.None yolo[65].Left=default.None yolo[65].Bottom=default.None yolo[65].Back=default.None
yolo[66]=new'Brick' yolo[66].Pos=Vector3.new(-15.5, -3.70000005, 18.5) yolo[66].Size=Vector3.new(1, 31, 4) yolo[66].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[66].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[66].Anchored=true yolo[66].Right=default.None yolo[66].Top=default.None yolo[66].Front=default.None yolo[66].Left=default.None yolo[66].Bottom=default.None yolo[66].Back=default.None
yolo[67]=new'Brick' yolo[67].Pos=Vector3.new(-34, -7.99459457, 27.1320801) yolo[67].Size=Vector3.new(6, 18, 2) yolo[67].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[67].Quaternion=Quaternion.new(0.79333202140229,-0.60878908682642,-1.5258785986894e-005,-1.5258785986894e-005).unit yolo[67].Anchored=true yolo[67].Right=default.None yolo[67].Top=default.None yolo[67].Front=default.None yolo[67].Left=default.None yolo[67].Bottom=default.None yolo[67].Back=default.None
yolo[68]=new'Brick' yolo[68].Pos=Vector3.new(0, -3.69984436, 10.5) yolo[68].Size=Vector3.new(1, 17, 4) yolo[68].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[68].Quaternion=Quaternion.new(0.70709523273549,-0.70711830875245,-1.5258789771533e-005,-1.5258629630163e-005).unit yolo[68].Anchored=true yolo[68].Right=default.None yolo[68].Top=default.None yolo[68].Front=default.None yolo[68].Left=default.None yolo[68].Bottom=default.None yolo[68].Back=default.None
yolo[69]=new'Brick' yolo[69].Pos=Vector3.new(-19, -3.70000005, 2.5) yolo[69].Size=Vector3.new(1, 38, 4) yolo[69].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[69].Quaternion=Quaternion.new(-0.5,0.5,-0.5,-0.5).unit yolo[69].Anchored=true yolo[69].Right=default.None yolo[69].Top=default.None yolo[69].Front=default.None yolo[69].Left=default.None yolo[69].Bottom=default.None yolo[69].Back=default.None
yolo[70]=new'Brick' yolo[70].Pos=Vector3.new(-43.5, -8.19999981, 34.5) yolo[70].Size=Vector3.new(1, 13, 4) yolo[70].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[70].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[70].Anchored=true yolo[70].Right=default.None yolo[70].Top=default.None yolo[70].Front=default.None yolo[70].Left=default.None yolo[70].Bottom=default.None yolo[70].Back=default.None
yolo[71]=new'Brick' yolo[71].Pos=Vector3.new(-37.5, -6.28688431, 26.5543213) yolo[71].Size=Vector3.new(1, 16, 5) yolo[71].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[71].Quaternion=Quaternion.new(0.79333202140229,-0.60878908682642,-1.5258785986894e-005,-1.5258785986894e-005).unit yolo[71].Anchored=true yolo[71].Right=default.None yolo[71].Top=default.None yolo[71].Front=default.None yolo[71].Left=default.None yolo[71].Bottom=default.None yolo[71].Back=default.None
yolo[72]=new'Brick' yolo[72].Pos=Vector3.new(-31, -13.1999092, 2) yolo[72].Size=Vector3.new(5, 1, 7) yolo[72].Colour=Colour4.new(105.0000089407,64.000003784895,40.00000141561,255) yolo[72].Quaternion=Quaternion.new(0.70709523273549,-0.70711830875245,-1.5258789771533e-005,-1.5258629630163e-005).unit yolo[72].Anchored=true yolo[72].Right=default.None yolo[72].Top=default.None yolo[72].Front=default.None yolo[72].Left=default.None yolo[72].Bottom=default.None yolo[72].Back=default.None
yolo[73]=new'Brick' yolo[73].Pos=Vector3.new(-37.5, -9.69999981, 11) yolo[73].Size=Vector3.new(1, 18, 16) yolo[73].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[73].Quaternion=Quaternion.new(0,0,0.70710678118655,0.70710678118655).unit yolo[73].Anchored=true yolo[73].Right=default.None yolo[73].Top=default.None yolo[73].Front=default.None yolo[73].Left=default.None yolo[73].Bottom=default.None yolo[73].Back=default.None
yolo[74]=new'Brick' yolo[74].Pos=Vector3.new(-8.89759827, -18.1095505, 7.9810791) yolo[74].Size=Vector3.new(20, 10, 42) yolo[74].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[74].Quaternion=Quaternion.new(0.60821347923016,-0.034623407237903,0.79257399796154,0.026533883894083).unit yolo[74].Anchored=true yolo[74].Right=default.Universal yolo[74].Top=default.Universal yolo[74].Front=default.Universal yolo[74].Left=default.Universal yolo[74].Bottom=default.Universal yolo[74].Back=default.Universal
yolo[75]=new'Brick' yolo[75].Pos=Vector3.new(-79.5, -6.70000029, 62) yolo[75].Size=Vector3.new(9, 6, 11) yolo[75].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[75].Quaternion=Quaternion.new(-0.5,0.5,-0.5,0.5).unit yolo[75].Anchored=true yolo[75].Right=default.Universal yolo[75].Top=default.Universal yolo[75].Front=default.Universal yolo[75].Left=default.Universal yolo[75].Bottom=default.Universal yolo[75].Back=default.Universal
yolo[76]=new'Brick' yolo[76].Pos=Vector3.new(-83.5606689, -6.69990158, 45.8535156) yolo[76].Size=Vector3.new(9, 6, 9) yolo[76].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[76].Quaternion=Quaternion.new(0.27062578240057,-0.65327106332403,0.65328448381336,-0.2705882853586).unit yolo[76].Anchored=true yolo[76].Right=default.Universal yolo[76].Top=default.Universal yolo[76].Front=default.Universal yolo[76].Left=default.Universal yolo[76].Bottom=default.Universal yolo[76].Back=default.Universal
yolo[77]=new'Brick' yolo[77].Pos=Vector3.new(-90.5, -6.70000029, 53) yolo[77].Size=Vector3.new(9, 13, 20) yolo[77].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[77].Quaternion=Quaternion.new(0,0.70710678118655,-0.70710678118655,-0).unit yolo[77].Anchored=true yolo[77].Right=default.Universal yolo[77].Top=default.Universal yolo[77].Front=default.Universal yolo[77].Left=default.Universal yolo[77].Bottom=default.Universal yolo[77].Back=default.Universal
yolo[78]=new'Brick' yolo[78].Pos=Vector3.new(-96.5, -15.6999998, 47) yolo[78].Size=Vector3.new(11, 1, 32) yolo[78].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[78].Quaternion=Quaternion.new(0.70710678118655,0,0,-0.70710678118655).unit yolo[78].Anchored=true yolo[78].Right=default.Universal yolo[78].Top=default.Universal yolo[78].Front=default.Universal yolo[78].Left=default.Universal yolo[78].Bottom=default.Universal yolo[78].Back=default.Universal
yolo[79]=new'Brick' yolo[79].Pos=Vector3.new(-85.5, -15.6999998, 62.5) yolo[79].Size=Vector3.new(11, 23, 5) yolo[79].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[79].Quaternion=Quaternion.new(0.70710678118655,-0,0,0.70710678118655).unit yolo[79].Anchored=true yolo[79].Right=default.Universal yolo[79].Top=default.Universal yolo[79].Front=default.Universal yolo[79].Left=default.Universal yolo[79].Bottom=default.Universal yolo[79].Back=default.Universal
yolo[80]=new'Brick' yolo[80].Pos=Vector3.new(-78.5, -20.1999607, 55.5) yolo[80].Size=Vector3.new(1, 1, 1) yolo[80].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[80].Quaternion=Quaternion.new(0.56096003663883,-0.030870578709623,-0.70644398767102,-0.43047386817026).unit yolo[80].Anchored=true yolo[80].Right=default.Universal yolo[80].Top=default.Universal yolo[80].Front=default.Universal yolo[80].Left=default.Universal yolo[80].Bottom=default.Universal yolo[80].Back=default.Universal
yolo[81]=new'Brick' yolo[81].Pos=Vector3.new(-78, -19.699955, 46.5) yolo[81].Size=Vector3.new(2, 1, 1) yolo[81].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[81].Quaternion=Quaternion.new(-0.38267388725682,1.5258609684019e-005,0.92388348080884,1.5258967030571e-005).unit yolo[81].Anchored=true yolo[81].Right=default.Universal yolo[81].Top=default.Universal yolo[81].Front=default.Universal yolo[81].Left=default.Universal yolo[81].Bottom=default.Universal yolo[81].Back=default.Universal
yolo[82]=new'Brick' yolo[82].Pos=Vector3.new(-74.5, -16.6999092, 45.5) yolo[82].Size=Vector3.new(2, 1, 2) yolo[82].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[82].Quaternion=Quaternion.new(0.37994253836165,0.59637364277957,0.59637045211468,-0.37990049457725).unit yolo[82].Anchored=true yolo[82].Right=default.Universal yolo[82].Top=default.Universal yolo[82].Front=default.Universal yolo[82].Left=default.Universal yolo[82].Bottom=default.Universal yolo[82].Back=default.Universal
yolo[83]=new'Brick' yolo[83].Pos=Vector3.new(-74.5, -15.6999998, 43) yolo[83].Size=Vector3.new(4, 1, 5) yolo[83].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[83].Quaternion=Quaternion.new(0.5,0.5,0.5,-0.5).unit yolo[83].Anchored=true yolo[83].Right=default.Universal yolo[83].Top=default.Universal yolo[83].Front=default.Universal yolo[83].Left=default.Universal yolo[83].Bottom=default.Universal yolo[83].Back=default.Universal
yolo[84]=new'Brick' yolo[84].Pos=Vector3.new(-74.5, -15.699913, 21.5) yolo[84].Size=Vector3.new(12, 1, 5) yolo[84].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[84].Quaternion=Quaternion.new(-0.49994660139688,0.50000762863776,0.50000762956901,0.50003814481914).unit yolo[84].Anchored=true yolo[84].Right=default.Universal yolo[84].Top=default.Universal yolo[84].Front=default.Universal yolo[84].Left=default.Universal yolo[84].Bottom=default.Universal yolo[84].Back=default.Universal
yolo[85]=new'Brick' yolo[85].Pos=Vector3.new(-74.5, -12.1999998, 24) yolo[85].Size=Vector3.new(42, 1, 4) yolo[85].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[85].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[85].Anchored=true yolo[85].Right=default.Universal yolo[85].Top=default.Universal yolo[85].Front=default.Universal yolo[85].Left=default.Universal yolo[85].Bottom=default.Universal yolo[85].Back=default.Universal
yolo[86]=new'Brick' yolo[86].Pos=Vector3.new(-74.5, -19.2000008, 22.5) yolo[86].Size=Vector3.new(45, 1, 4) yolo[86].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[86].Quaternion=Quaternion.new(-0.5,0.5,-0.5,-0.5).unit yolo[86].Anchored=true yolo[86].Right=default.Universal yolo[86].Top=default.Universal yolo[86].Front=default.Universal yolo[86].Left=default.Universal yolo[86].Bottom=default.Universal yolo[86].Back=default.Universal
yolo[87]=new'Brick' yolo[87].Pos=Vector3.new(-103.5, -20.7000008, 31.5) yolo[87].Size=Vector3.new(63, 59, 1) yolo[87].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[87].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[87].Anchored=true yolo[87].Right=default.None yolo[87].Top=default.None yolo[87].Front=default.None yolo[87].Left=default.None yolo[87].Bottom=default.None yolo[87].Back=default.None
yolo[88]=new'Brick' yolo[88].Pos=Vector3.new(-45.5, -10.1999998, 34.5) yolo[88].Size=Vector3.new(9, 1, 2) yolo[88].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[88].Quaternion=Quaternion.new(0.70710678118655,-0.70710678118655,0,0).unit yolo[88].Anchored=true yolo[88].Right=default.None yolo[88].Top=default.None yolo[88].Front=default.None yolo[88].Left=default.None yolo[88].Bottom=default.None yolo[88].Back=default.None
yolo[89]=new'Brick' yolo[89].Pos=Vector3.new(-68, -18.6999474, 22.5) yolo[89].Size=Vector3.new(44, 2, 13) yolo[89].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[89].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,0).unit yolo[89].Anchored=true yolo[89].Right=default.Universal yolo[89].Top=default.Universal yolo[89].Front=default.Universal yolo[89].Left=default.Universal yolo[89].Bottom=default.Universal yolo[89].Back=default.Universal
yolo[90]=new'Brick' yolo[90].Pos=Vector3.new(-61.5, -17.6999168, 22) yolo[90].Size=Vector3.new(45, 1, 25) yolo[90].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[90].Quaternion=Quaternion.new(0.70709523273549,-1.5258789774987e-005,-0.70711830875245,-1.5258630912989e-005).unit yolo[90].Anchored=true yolo[90].Right=default.None yolo[90].Top=default.None yolo[90].Front=default.None yolo[90].Left=default.None yolo[90].Bottom=default.None yolo[90].Back=default.None
yolo[91]=new'Brick' yolo[91].Pos=Vector3.new(-44.483902, -17.6999474, 23.7165527) yolo[91].Size=Vector3.new(12, 1, 22) yolo[91].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[91].Quaternion=Quaternion.new(0.99619303189831,-1.5258670674117e-005,-0.087174100472256,-1.5258670674117e-005).unit yolo[91].Anchored=true yolo[91].Right=default.None yolo[91].Top=default.None yolo[91].Front=default.None yolo[91].Left=default.None yolo[91].Bottom=default.None yolo[91].Back=default.None
yolo[92]=new'Brick' yolo[92].Pos=Vector3.new(-46.0423126, -17.6999474, 6.78771973) yolo[92].Size=Vector3.new(21, 1, 17) yolo[92].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[92].Quaternion=Quaternion.new(0.84338102396839,-1.5258795954047e-005,-0.5373161949661,-1.5258795954047e-005).unit yolo[92].Anchored=true yolo[92].Right=default.None yolo[92].Top=default.None yolo[92].Front=default.None yolo[92].Left=default.None yolo[92].Bottom=default.None yolo[92].Back=default.None
yolo[93]=new'Brick' yolo[93].Pos=Vector3.new(-37.6485291, -13.1999092, 26.3225098) yolo[93].Size=Vector3.new(3, 3, 3) yolo[93].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[93].Quaternion=Quaternion.new(-0.18301574520261,-0.18302413985922,-0.68301039868267,0.68301111601414).unit yolo[93].Anchored=true yolo[93].Right=default.None yolo[93].Top=default.None yolo[93].Front=default.None yolo[93].Left=default.None yolo[93].Bottom=default.None yolo[93].Back=default.None
yolo[94]=new'Brick' yolo[94].Pos=Vector3.new(-38.5, -16.199913, 28) yolo[94].Size=Vector3.new(3, 3, 3) yolo[94].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[94].Quaternion=Quaternion.new(0.092299840369909,0.092300851282406,0.70106822499605,-0.70104539186664).unit yolo[94].Anchored=true yolo[94].Right=default.None yolo[94].Top=default.None yolo[94].Front=default.None yolo[94].Left=default.None yolo[94].Bottom=default.None yolo[94].Back=default.None
yolo[95]=new'Brick' yolo[95].Pos=Vector3.new(-37.9958344, -16.199913, 24.3529053) yolo[95].Size=Vector3.new(3, 3, 3) yolo[95].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[95].Quaternion=Quaternion.new(0.061631199282393,0.061631199282393,-0.70440220928493,0.70443273366941).unit yolo[95].Anchored=true yolo[95].Right=default.None yolo[95].Top=default.None yolo[95].Front=default.None yolo[95].Left=default.None yolo[95].Bottom=default.None yolo[95].Back=default.None
yolo[96]=new'Brick' yolo[96].Pos=Vector3.new(-106.62439, -16.199913, 71.5944824) yolo[96].Size=Vector3.new(3, 2, 1) yolo[96].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[96].Quaternion=Quaternion.new(-0.29880955973218,0.2988444346728,0.64085607804935,0.64086529929051).unit yolo[96].Anchored=true yolo[96].Right=default.Universal yolo[96].Top=default.Universal yolo[96].Front=default.Universal yolo[96].Left=default.Universal yolo[96].Bottom=default.Universal yolo[96].Back=default.Universal
yolo[97]=new'Brick' yolo[97].Pos=Vector3.new(-102, -3.69984436, 67) yolo[97].Size=Vector3.new(9, 5, 1) yolo[97].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[97].Quaternion=Quaternion.new(0.66906125254294,-0.42628852604874,-0.51344751662436,-0.32711889629846).unit yolo[97].Anchored=true yolo[97].Right=default.Universal yolo[97].Top=default.Universal yolo[97].Front=default.Universal yolo[97].Left=default.Universal yolo[97].Bottom=default.Universal yolo[97].Back=default.Universal
yolo[98]=new'Brick' yolo[98].Pos=Vector3.new(-99, -9.69992828, 60.5) yolo[98].Size=Vector3.new(34, 5, 15) yolo[98].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[98].Quaternion=Quaternion.new(-0.49994660139688,0.50000762863776,0.50000762956901,0.50003814481914).unit yolo[98].Anchored=true yolo[98].Right=default.Universal yolo[98].Top=default.Universal yolo[98].Front=default.Universal yolo[98].Left=default.Universal yolo[98].Bottom=default.Universal yolo[98].Back=default.Universal
yolo[99]=new'Brick' yolo[99].Pos=Vector3.new(-114.5, -17.0999336, 74.6000977) yolo[99].Size=Vector3.new(62, 36, 1) yolo[99].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[99].Quaternion=Quaternion.new(-0.49994660139688,0.50000762863776,0.50000762956901,0.50003814481914).unit yolo[99].Anchored=true yolo[99].Right=default.Universal yolo[99].Top=default.None yolo[99].Front=default.Universal yolo[99].Left=default.Universal yolo[99].Bottom=default.Universal yolo[99].Back=default.None
yolo[100]=new'Brick' yolo[100].Pos=Vector3.new(-114.5, -18.6999474, 44) yolo[100].Size=Vector3.new(36, 1, 4) yolo[100].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[100].Quaternion=Quaternion.new(0.70710678118655,-0.70710678118655,-0,0).unit yolo[100].Anchored=true yolo[100].Right=default.Universal yolo[100].Top=default.Universal yolo[100].Front=default.Universal yolo[100].Left=default.Universal yolo[100].Bottom=default.Universal yolo[100].Back=default.Universal
yolo[101]=new'Brick' yolo[101].Pos=Vector3.new(-87.6080322, -11.199913, 65.7768555) yolo[101].Size=Vector3.new(12, 24, 18) yolo[101].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[101].Quaternion=Quaternion.new(-0.40553300829323,0.40558538523719,0.57922674989966,0.57925799845827).unit yolo[101].Anchored=true yolo[101].Right=default.Universal yolo[101].Top=default.Universal yolo[101].Front=default.Universal yolo[101].Left=default.Universal yolo[101].Bottom=default.Universal yolo[101].Back=default.Universal
yolo[102]=new'Brick' yolo[102].Pos=Vector3.new(-23.0184937, -14.8999252, 115.813477) yolo[102].Size=Vector3.new(4, 1, 5) yolo[102].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[102].Quaternion=Quaternion.new(0.70642104609468,-0.70644228763244,0.030838285743423,0.030838285743423).unit yolo[102].Anchored=true yolo[102].Right=default.None yolo[102].Top=default.None yolo[102].Front=default.None yolo[102].Left=default.None yolo[102].Bottom=default.None yolo[102].Back=default.None
yolo[103]=new'Brick' yolo[103].Pos=Vector3.new(11.7389526, -19.699955, 28.2192383) yolo[103].Size=Vector3.new(10, 8, 32) yolo[103].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[103].Quaternion=Quaternion.new(0.97638941184579,0.022659419344126,0.12852533215408,0.17213520018537).unit yolo[103].Anchored=true yolo[103].Right=default.Universal yolo[103].Top=default.Universal yolo[103].Front=default.Universal yolo[103].Left=default.Universal yolo[103].Bottom=default.Universal yolo[103].Back=default.Universal
yolo[104]=new'Brick' yolo[104].Pos=Vector3.new(-33.5, -12.1000004, 39.5) yolo[104].Size=Vector3.new(1, 1, 3) yolo[104].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[104].Quaternion=Quaternion.new(0.5,0.5,0.5,0.5).unit yolo[104].Anchored=true yolo[104].Right=default.None yolo[104].Top=default.None yolo[104].Front=default.None yolo[104].Left=default.None yolo[104].Bottom=default.None yolo[104].Back=default.None
yolo[105]=new'Brick' yolo[105].Pos=Vector3.new(-33.5, -16.5, 39.5) yolo[105].Size=Vector3.new(1, 1, 3) yolo[105].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[105].Quaternion=Quaternion.new(0.5,0.5,0.5,0.5).unit yolo[105].Anchored=true yolo[105].Right=default.None yolo[105].Top=default.None yolo[105].Front=default.None yolo[105].Left=default.None yolo[105].Bottom=default.None yolo[105].Back=default.None
yolo[106]=new'Brick' yolo[106].Pos=Vector3.new(-33.5, -10.5, 39.5) yolo[106].Size=Vector3.new(1, 1, 3) yolo[106].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[106].Quaternion=Quaternion.new(0.5,0.5,0.5,0.5).unit yolo[106].Anchored=true yolo[106].Right=default.None yolo[106].Top=default.None yolo[106].Front=default.None yolo[106].Left=default.None yolo[106].Bottom=default.None yolo[106].Back=default.None
yolo[107]=new'Brick' yolo[107].Pos=Vector3.new(-22, -12.1999998, 36) yolo[107].Size=Vector3.new(12, 13, 34) yolo[107].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[107].Quaternion=Quaternion.new(0,0,1,0).unit yolo[107].Anchored=true yolo[107].Right=default.Universal yolo[107].Top=default.Universal yolo[107].Front=default.Universal yolo[107].Left=default.Universal yolo[107].Bottom=default.Universal yolo[107].Back=default.Universal
yolo[108]=new'Brick' yolo[108].Pos=Vector3.new(-71, -20.6999969, 54) yolo[108].Size=Vector3.new(2, 1, 2) yolo[108].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[108].Quaternion=Quaternion.new(-0.21914978105438,0.92166813452922,0.10221882983539,0.30340162333929).unit yolo[108].Anchored=true yolo[108].Right=default.Universal yolo[108].Top=default.Universal yolo[108].Front=default.Universal yolo[108].Left=default.Universal yolo[108].Bottom=default.Universal yolo[108].Back=default.Universal
yolo[109]=new'Brick' yolo[109].Pos=Vector3.new(-66.5857849, -19.699955, 59.4143066) yolo[109].Size=Vector3.new(4, 2, 6) yolo[109].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[109].Quaternion=Quaternion.new(-0.38267388725682,1.5258609684019e-005,0.92388348080884,1.5258967030571e-005).unit yolo[109].Anchored=true yolo[109].Right=default.Universal yolo[109].Top=default.Universal yolo[109].Front=default.Universal yolo[109].Left=default.Universal yolo[109].Bottom=default.Universal yolo[109].Back=default.Universal
yolo[110]=new'Brick' yolo[110].Pos=Vector3.new(-72, -18.4697227, 45.5062256) yolo[110].Size=Vector3.new(2, 3, 1) yolo[110].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[110].Quaternion=Quaternion.new(0.86519865130179,-0.4995293982821,0.037765704878295,0.021804022045536).unit yolo[110].Anchored=true yolo[110].Right=default.None yolo[110].Top=default.None yolo[110].Front=default.None yolo[110].Left=default.None yolo[110].Bottom=default.None yolo[110].Back=default.None
yolo[111]=new'Brick' yolo[111].Pos=Vector3.new(-59, -17.6999474, 56.5) yolo[111].Size=Vector3.new(2, 1, 4) yolo[111].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[111].Quaternion=Quaternion.new(0.95371576667733,-1.5258602226604e-005,-0.3007058676925,-1.5258602226604e-005).unit yolo[111].Anchored=true yolo[111].Right=default.None yolo[111].Top=default.None yolo[111].Front=default.None yolo[111].Left=default.None yolo[111].Bottom=default.None yolo[111].Back=default.None
yolo[112]=new'Brick' yolo[112].Pos=Vector3.new(-45, -16.2000008, 34.5) yolo[112].Size=Vector3.new(1, 10, 4) yolo[112].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[112].Quaternion=Quaternion.new(-0.5,0.5,-0.5,-0.5).unit yolo[112].Anchored=true yolo[112].Right=default.None yolo[112].Top=default.None yolo[112].Front=default.None yolo[112].Left=default.None yolo[112].Bottom=default.None yolo[112].Back=default.None
yolo[113]=new'Brick' yolo[113].Pos=Vector3.new(-63.5, -20.2000008, 46.5) yolo[113].Size=Vector3.new(5, 5, 5) yolo[113].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[113].Quaternion=Quaternion.new(0.70710678118655,0,0,-0.70710678118655).unit yolo[113].Anchored=true yolo[113].Right=default.Universal yolo[113].Top=default.Universal yolo[113].Front=default.Universal yolo[113].Left=default.Universal yolo[113].Bottom=default.Universal yolo[113].Back=default.Universal
yolo[114]=new'Brick' yolo[114].Pos=Vector3.new(-69, -21.2000008, 59) yolo[114].Size=Vector3.new(6, 6, 6) yolo[114].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[114].Quaternion=Quaternion.new(0.5,0.5,0.5,-0.5).unit yolo[114].Anchored=true yolo[114].Right=default.Universal yolo[114].Top=default.Universal yolo[114].Front=default.Universal yolo[114].Left=default.Universal yolo[114].Bottom=default.Universal yolo[114].Back=default.Universal
yolo[115]=new'Brick' yolo[115].Pos=Vector3.new(-64.6881256, -21.1143742, 51) yolo[115].Size=Vector3.new(2, 2, 2) yolo[115].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[115].Quaternion=Quaternion.new(0.64088134615634,0.29882079709528,0.64084045033501,-0.29883230488715).unit yolo[115].Anchored=true yolo[115].Right=default.Universal yolo[115].Top=default.Universal yolo[115].Front=default.Universal yolo[115].Left=default.Universal yolo[115].Bottom=default.Universal yolo[115].Back=default.Universal
yolo[116]=new'Brick' yolo[116].Pos=Vector3.new(-68.5, -21.6999741, 46) yolo[116].Size=Vector3.new(6, 6, 6) yolo[116].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[116].Quaternion=Quaternion.new(0.49997711385363,0.50000762863784,0.5000076291035,-0.5000076291035).unit yolo[116].Anchored=true yolo[116].Right=default.Universal yolo[116].Top=default.Universal yolo[116].Front=default.Universal yolo[116].Left=default.Universal yolo[116].Bottom=default.Universal yolo[116].Back=default.Universal
yolo[117]=new'Brick' yolo[117].Pos=Vector3.new(-69, -21.7000008, 52.5) yolo[117].Size=Vector3.new(11, 2, 10) yolo[117].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[117].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,-0).unit yolo[117].Anchored=true yolo[117].Right=default.Universal yolo[117].Top=default.Universal yolo[117].Front=default.Universal yolo[117].Left=default.Universal yolo[117].Bottom=default.Universal yolo[117].Back=default.Universal
yolo[118]=new'Brick' yolo[118].Pos=Vector3.new(-67.5, -20.1999607, 45.5) yolo[118].Size=Vector3.new(5, 2, 13) yolo[118].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[118].Quaternion=Quaternion.new(-0.29881740699295,0.64086365325032,-0.29881740699295,0.64086365325032).unit yolo[118].Anchored=true yolo[118].Right=default.Universal yolo[118].Top=default.Universal yolo[118].Front=default.Universal yolo[118].Left=default.Universal yolo[118].Bottom=default.Universal yolo[118].Back=default.Universal
yolo[119]=new'Brick' yolo[119].Pos=Vector3.new(-62.5, -19.9999428, 52) yolo[119].Size=Vector3.new(5, 2, 18) yolo[119].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[119].Quaternion=Quaternion.new(1.525896526695e-005,-0.34200351673594,0.93969869279047,1.5258709268564e-005).unit yolo[119].Anchored=true yolo[119].Right=default.Universal yolo[119].Top=default.Universal yolo[119].Front=default.Universal yolo[119].Left=default.Universal yolo[119].Bottom=default.Universal yolo[119].Back=default.Universal
yolo[120]=new'Brick' yolo[120].Pos=Vector3.new(-68, -20.1999969, 59.5) yolo[120].Size=Vector3.new(5, 2, 13) yolo[120].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[120].Quaternion=Quaternion.new(0.65328626473349,-0.27063209319329,0.65325402286103,-0.27061876072004).unit yolo[120].Anchored=true yolo[120].Right=default.Universal yolo[120].Top=default.Universal yolo[120].Front=default.Universal yolo[120].Left=default.Universal yolo[120].Bottom=default.Universal yolo[120].Back=default.Universal
yolo[121]=new'Brick' yolo[121].Pos=Vector3.new(-33.5, -13.6999998, 39.5) yolo[121].Size=Vector3.new(1, 1, 3) yolo[121].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[121].Quaternion=Quaternion.new(0.5,0.5,0.5,0.5).unit yolo[121].Anchored=true yolo[121].Right=default.None yolo[121].Top=default.None yolo[121].Front=default.None yolo[121].Left=default.None yolo[121].Bottom=default.None yolo[121].Back=default.None
yolo[122]=new'Brick' yolo[122].Pos=Vector3.new(-39, -8.19999981, 61.5) yolo[122].Size=Vector3.new(3, 22, 4) yolo[122].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[122].Quaternion=Quaternion.new(-0.5,0.5,-0.5,-0.5).unit yolo[122].Anchored=true yolo[122].Right=default.None yolo[122].Top=default.None yolo[122].Front=default.None yolo[122].Left=default.None yolo[122].Bottom=default.None yolo[122].Back=default.None
yolo[123]=new'Brick' yolo[123].Pos=Vector3.new(-49.5, -8.19990158, 47.5) yolo[123].Size=Vector3.new(1, 26, 4) yolo[123].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[123].Quaternion=Quaternion.new(0.70710678118655,-0.70710678118655,-0,0).unit yolo[123].Anchored=true yolo[123].Right=default.None yolo[123].Top=default.None yolo[123].Front=default.None yolo[123].Left=default.None yolo[123].Bottom=default.None yolo[123].Back=default.None
yolo[124]=new'Brick' yolo[124].Pos=Vector3.new(25.7896729, -20.1999607, 48.1188965) yolo[124].Size=Vector3.new(17, 12, 32) yolo[124].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[124].Quaternion=Quaternion.new(0.99619303189831,-1.5258670674117e-005,-0.087174100472256,-1.5258670674117e-005).unit yolo[124].Anchored=true yolo[124].Right=default.Universal yolo[124].Top=default.None yolo[124].Front=default.Universal yolo[124].Left=default.Universal yolo[124].Bottom=default.Universal yolo[124].Back=default.Universal
yolo[125]=new'Brick' yolo[125].Pos=Vector3.new(15.3040924, -19.699955, 44.2392578) yolo[125].Size=Vector3.new(10, 8, 28) yolo[125].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[125].Quaternion=Quaternion.new(0.98106460399199,-0.015151965070507,-0.085830580347827,0.1729581294673).unit yolo[125].Anchored=true yolo[125].Right=default.Universal yolo[125].Top=default.Universal yolo[125].Front=default.Universal yolo[125].Left=default.Universal yolo[125].Bottom=default.Universal yolo[125].Back=default.Universal
yolo[126]=new'Brick' yolo[126].Pos=Vector3.new(-8.5, -18.1999435, 41) yolo[126].Size=Vector3.new(38, 2, 58) yolo[126].Colour=Colour4.new(4.0000002365559,175.00000476837,236.00001633167,101.99999392033) yolo[126].Quaternion=Quaternion.new(1,-1.52587890625e-005,-1.52587890625e-005,-1.52587890625e-005).unit yolo[126].Anchored=true yolo[126].Right=default.None yolo[126].Top=default.None yolo[126].Front=default.None yolo[126].Left=default.None yolo[126].Bottom=default.None yolo[126].Back=default.None
yolo[127]=new'Brick' yolo[127].Pos=Vector3.new(-33.5, -15.1000004, 39.5) yolo[127].Size=Vector3.new(1, 1, 3) yolo[127].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[127].Quaternion=Quaternion.new(0.5,0.5,0.5,0.5).unit yolo[127].Anchored=true yolo[127].Right=default.None yolo[127].Top=default.None yolo[127].Front=default.None yolo[127].Left=default.None yolo[127].Bottom=default.None yolo[127].Back=default.None
yolo[128]=new'Brick' yolo[128].Pos=Vector3.new(5.62307739, -18.9723473, 49.5771484) yolo[128].Size=Vector3.new(2, 1, 1) yolo[128].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[128].Quaternion=Quaternion.new(0.2988328795262,0.40556775044504,0.64084682711218,0.5792487069149).unit yolo[128].Anchored=true yolo[128].Right=default.Universal yolo[128].Top=default.Universal yolo[128].Front=default.Universal yolo[128].Left=default.Universal yolo[128].Bottom=default.Universal yolo[128].Back=default.Universal
yolo[129]=new'Brick' yolo[129].Pos=Vector3.new(-28.5, -13.6999998, 45) yolo[129].Size=Vector3.new(1, 14, 9) yolo[129].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[129].Quaternion=Quaternion.new(0.70710678118655,-0.70710678118655,0,0).unit yolo[129].Anchored=true yolo[129].Right=default.None yolo[129].Top=default.None yolo[129].Front=default.None yolo[129].Left=default.None yolo[129].Bottom=default.None yolo[129].Back=default.None
yolo[130]=new'Brick' yolo[130].Pos=Vector3.new(-49.5, -14.1999998, 57.5) yolo[130].Size=Vector3.new(11, 1, 8) yolo[130].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[130].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[130].Anchored=true yolo[130].Right=default.None yolo[130].Top=default.None yolo[130].Front=default.None yolo[130].Left=default.None yolo[130].Bottom=default.None yolo[130].Back=default.None
yolo[131]=new'Brick' yolo[131].Pos=Vector3.new(-38.5, -10.1999998, 57.5) yolo[131].Size=Vector3.new(11, 23, 2) yolo[131].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[131].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[131].Anchored=true yolo[131].Right=default.None yolo[131].Top=default.None yolo[131].Front=default.None yolo[131].Left=default.None yolo[131].Bottom=default.None yolo[131].Back=default.None
yolo[132]=new'Brick' yolo[132].Pos=Vector3.new(-39, -14.1999998, 60.5) yolo[132].Size=Vector3.new(1, 22, 8) yolo[132].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[132].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[132].Anchored=true yolo[132].Right=default.None yolo[132].Top=default.None yolo[132].Front=default.None yolo[132].Left=default.None yolo[132].Bottom=default.None yolo[132].Back=default.None
yolo[133]=new'Brick' yolo[133].Pos=Vector3.new(-38.5, -17.7000008, 47.5) yolo[133].Size=Vector3.new(27, 21, 1) yolo[133].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[133].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[133].Anchored=true yolo[133].Right=default.None yolo[133].Top=default.None yolo[133].Front=default.None yolo[133].Left=default.None yolo[133].Bottom=default.None yolo[133].Back=default.None
yolo[134]=new'Brick' yolo[134].Pos=Vector3.new(-32.383728, -14.39991, 68.2836914) yolo[134].Size=Vector3.new(34, 12, 15) yolo[134].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[134].Quaternion=Quaternion.new(-0.04359446569336,1.5258582826542e-005,0.99904930849408,1.5258865948556e-005).unit yolo[134].Anchored=true yolo[134].Right=default.Universal yolo[134].Top=default.Universal yolo[134].Front=default.Universal yolo[134].Left=default.Universal yolo[134].Bottom=default.Universal yolo[134].Back=default.Universal
yolo[135]=new'Brick' yolo[135].Pos=Vector3.new(-22, -9.22384644, 56.6816406) yolo[135].Size=Vector3.new(12, 3, 9) yolo[135].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[135].Quaternion=Quaternion.new(1.5258291194233e-005,1.5258197166404e-005,0.99144272372682,0.1305424270141).unit yolo[135].Anchored=true yolo[135].Right=default.Universal yolo[135].Top=default.Universal yolo[135].Front=default.Universal yolo[135].Left=default.Universal yolo[135].Bottom=default.Universal yolo[135].Back=default.Universal
yolo[136]=new'Brick' yolo[136].Pos=Vector3.new(-13.7156372, -19.8997231, 69.1826172) yolo[136].Size=Vector3.new(10, 8, 29) yolo[136].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[136].Quaternion=Quaternion.new(0.72606632764539,-0.11732722786461,-0.66534252135093,0.12800854247136).unit yolo[136].Anchored=true yolo[136].Right=default.Universal yolo[136].Top=default.Universal yolo[136].Front=default.Universal yolo[136].Left=default.Universal yolo[136].Bottom=default.Universal yolo[136].Back=default.Universal
yolo[137]=new'Brick' yolo[137].Pos=Vector3.new(-21.087738, -20.3999424, 93.9194336) yolo[137].Size=Vector3.new(43, 12, 52) yolo[137].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[137].Quaternion=Quaternion.new(0.73727459372437,-1.5258695790467e-005,-0.67558909823403,-1.5258695790467e-005).unit yolo[137].Anchored=true yolo[137].Right=default.Universal yolo[137].Top=default.None yolo[137].Front=default.Universal yolo[137].Left=default.Universal yolo[137].Bottom=default.Universal yolo[137].Back=default.Universal
yolo[138]=new'Brick' yolo[138].Pos=Vector3.new(5.03419495, -19.8997231, 62.3515625) yolo[138].Size=Vector3.new(10, 8, 27) yolo[138].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[138].Quaternion=Quaternion.new(0.89252858264418,-0.073410085411869,-0.416214219649,0.1573639615996).unit yolo[138].Anchored=true yolo[138].Right=default.Universal yolo[138].Top=default.Universal yolo[138].Front=default.Universal yolo[138].Left=default.Universal yolo[138].Bottom=default.Universal yolo[138].Back=default.Universal
yolo[139]=new'Brick' yolo[139].Pos=Vector3.new(-54.5, -17.6999474, 50.5) yolo[139].Size=Vector3.new(10, 1, 13) yolo[139].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[139].Quaternion=Quaternion.new(1,-1.52587890625e-005,-1.52587890625e-005,-1.52587890625e-005).unit yolo[139].Anchored=true yolo[139].Right=default.None yolo[139].Top=default.None yolo[139].Front=default.None yolo[139].Left=default.None yolo[139].Bottom=default.None yolo[139].Back=default.None
yolo[140]=new'Brick' yolo[140].Pos=Vector3.new(-25, -18.6999474, 46.5) yolo[140].Size=Vector3.new(92, 2, 73) yolo[140].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[140].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,0).unit yolo[140].Anchored=true yolo[140].Right=default.Universal yolo[140].Top=default.Universal yolo[140].Front=default.Universal yolo[140].Left=default.Universal yolo[140].Bottom=default.Universal yolo[140].Back=default.Universal
yolo[141]=new'Brick' yolo[141].Pos=Vector3.new(-31.1429443, -14.1470566, 79.0512695) yolo[141].Size=Vector3.new(34, 5, 12) yolo[141].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[141].Quaternion=Quaternion.new(-0.011276135148614,0.042158329346773,-0.25855088205631,0.96501138134407).unit yolo[141].Anchored=true yolo[141].Right=default.Universal yolo[141].Top=default.Universal yolo[141].Front=default.Universal yolo[141].Left=default.Universal yolo[141].Bottom=default.Universal yolo[141].Back=default.Universal
yolo[142]=new'Brick' yolo[142].Pos=Vector3.new(-28.5, -8.19999981, 47.5) yolo[142].Size=Vector3.new(1, 27, 4) yolo[142].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[142].Quaternion=Quaternion.new(0,0,0.70710678118655,0.70710678118655).unit yolo[142].Anchored=true yolo[142].Right=default.None yolo[142].Top=default.None yolo[142].Front=default.None yolo[142].Left=default.None yolo[142].Bottom=default.None yolo[142].Back=default.None
yolo[143]=new'Brick' yolo[143].Pos=Vector3.new(-36.5, -13.699913, 52.5) yolo[143].Size=Vector3.new(1, 16, 8) yolo[143].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[143].Quaternion=Quaternion.new(-0.49994660139688,0.50000762863776,0.50000762956901,0.50003814481914).unit yolo[143].Anchored=true yolo[143].Right=default.None yolo[143].Top=default.None yolo[143].Front=default.None yolo[143].Left=default.None yolo[143].Bottom=default.None yolo[143].Back=default.None
yolo[144]=new'Brick' yolo[144].Pos=Vector3.new(-39, -9.69999981, 47.5) yolo[144].Size=Vector3.new(11, 22, 1) yolo[144].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[144].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[144].Anchored=true yolo[144].Right=default.None yolo[144].Top=default.None yolo[144].Front=default.None yolo[144].Left=default.None yolo[144].Bottom=default.None yolo[144].Back=default.None
yolo[145]=new'Brick' yolo[145].Pos=Vector3.new(12.1664886, -20.3999424, 70.0734863) yolo[145].Size=Vector3.new(16, 12, 36) yolo[145].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[145].Quaternion=Quaternion.new(0.90630543473485,-1.5258445316588e-005,-0.42262331819134,-1.5258212500185e-005).unit yolo[145].Anchored=true yolo[145].Right=default.Universal yolo[145].Top=default.None yolo[145].Front=default.Universal yolo[145].Left=default.Universal yolo[145].Bottom=default.Universal yolo[145].Back=default.Universal
yolo[146]=new'Brick' yolo[146].Pos=Vector3.new(-1.5, -6.69990158, 110) yolo[146].Size=Vector3.new(34, 39, 12) yolo[146].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[146].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,0).unit yolo[146].Anchored=true yolo[146].Right=default.Universal yolo[146].Top=default.Universal yolo[146].Front=default.Universal yolo[146].Left=default.Universal yolo[146].Bottom=default.Universal yolo[146].Back=default.Universal
yolo[147]=new'Brick' yolo[147].Pos=Vector3.new(-25.9693909, -21.8999557, 118.437988) yolo[147].Size=Vector3.new(38, 9, 7) yolo[147].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[147].Quaternion=Quaternion.new(0.99904928612107,-1.5258394268507e-005,0.043593948361514,-1.5258394268507e-005).unit yolo[147].Anchored=true yolo[147].Right=default.Universal yolo[147].Top=default.Universal yolo[147].Front=default.Universal yolo[147].Left=default.Universal yolo[147].Bottom=default.Universal yolo[147].Back=default.Universal
yolo[148]=new'Brick' yolo[148].Pos=Vector3.new(-25.4028931, -20.3999424, 124.91333) yolo[148].Size=Vector3.new(8, 12, 38) yolo[148].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[148].Quaternion=Quaternion.new(0.73727459372437,-1.5258695790467e-005,-0.67558909823403,-1.5258695790467e-005).unit yolo[148].Anchored=true yolo[148].Right=default.Universal yolo[148].Top=default.Universal yolo[148].Front=default.Universal yolo[148].Left=default.Universal yolo[148].Bottom=default.Universal yolo[148].Back=default.Universal
yolo[149]=new'Brick' yolo[149].Pos=Vector3.new(-11.6835785, -12.8998909, 122.984863) yolo[149].Size=Vector3.new(3, 3, 3) yolo[149].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[149].Quaternion=Quaternion.new(0.52131557232828,0.52133343718066,-0.4777529015467,0.47772240267071).unit yolo[149].Anchored=true yolo[149].Right=default.None yolo[149].Top=default.None yolo[149].Front=default.None yolo[149].Left=default.None yolo[149].Bottom=default.None yolo[149].Back=default.None
yolo[150]=new'Brick' yolo[150].Pos=Vector3.new(-15.0735779, -12.8998909, 122.503906) yolo[150].Size=Vector3.new(3, 3, 3) yolo[150].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[150].Quaternion=Quaternion.new(0.61238553587066,0.61236493238514,-0.35356978752299,0.35352731553656).unit yolo[150].Anchored=true yolo[150].Right=default.None yolo[150].Top=default.None yolo[150].Front=default.None yolo[150].Left=default.None yolo[150].Bottom=default.None yolo[150].Back=default.None
yolo[151]=new'Brick' yolo[151].Pos=Vector3.new(-49.5, -10.1999998, 47) yolo[151].Size=Vector3.new(12, 1, 2) yolo[151].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[151].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[151].Anchored=true yolo[151].Right=default.None yolo[151].Top=default.None yolo[151].Front=default.None yolo[151].Left=default.None yolo[151].Bottom=default.None yolo[151].Back=default.None
yolo[152]=new'Brick' yolo[152].Pos=Vector3.new(-49.5, -13.1999998, 51) yolo[152].Size=Vector3.new(4, 1, 6) yolo[152].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[152].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[152].Anchored=true yolo[152].Right=default.None yolo[152].Top=default.None yolo[152].Front=default.None yolo[152].Left=default.None yolo[152].Bottom=default.None yolo[152].Back=default.None
yolo[153]=new'Brick' yolo[153].Pos=Vector3.new(28.9920959, 9.80012512, -15.6004639) yolo[153].Size=Vector3.new(11, 10, 1) yolo[153].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[153].Quaternion=Quaternion.new(-0.27059530322535,-0.65327105185381,0.65328449528381,0.27061876453489).unit yolo[153].Anchored=true yolo[153].Right=default.None yolo[153].Top=default.None yolo[153].Front=default.None yolo[153].Left=default.None yolo[153].Bottom=default.None yolo[153].Back=default.None
yolo[154]=new'Brick' yolo[154].Pos=Vector3.new(17.6783905, 6.80011749, -20.5501709) yolo[154].Size=Vector3.new(4, 24, 1) yolo[154].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[154].Quaternion=Quaternion.new(-0.27059533450195,0.65330149993564,-0.65325404799451,0.27061873358558).unit yolo[154].Anchored=true yolo[154].Right=default.None yolo[154].Top=default.None yolo[154].Front=default.None yolo[154].Left=default.None yolo[154].Bottom=default.None yolo[154].Back=default.None
yolo[155]=new'Brick' yolo[155].Pos=Vector3.new(18.385498, 13.8000908, -19.8431396) yolo[155].Size=Vector3.new(3, 22, 1) yolo[155].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[155].Quaternion=Quaternion.new(0.65327104031045,0.27059532106837,-0.27061873724236,-0.65328450682741).unit yolo[155].Anchored=true yolo[155].Right=default.None yolo[155].Top=default.None yolo[155].Front=default.None yolo[155].Left=default.None yolo[155].Bottom=default.None yolo[155].Back=default.None
yolo[156]=new'Brick' yolo[156].Pos=Vector3.new(23.3352509, 10.8001289, -14.8933105) yolo[156].Size=Vector3.new(5, 8, 1) yolo[156].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[156].Quaternion=Quaternion.new(0.65327104031045,0.27059532106837,-0.27061873724236,-0.65328450682741).unit yolo[156].Anchored=true yolo[156].Right=default.None yolo[156].Top=default.None yolo[156].Front=default.None yolo[156].Left=default.None yolo[156].Bottom=default.None yolo[156].Back=default.None
yolo[157]=new'Brick' yolo[157].Pos=Vector3.new(-26.3264923, -17.4000168, 55.7719727) yolo[157].Size=Vector3.new(1, 1, 2) yolo[157].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[157].Quaternion=Quaternion.new(0.84338102396839,-1.5258795954047e-005,-0.5373161949661,-1.5258795954047e-005).unit yolo[157].Anchored=true yolo[157].Right=default.None yolo[157].Top=default.None yolo[157].Front=default.None yolo[157].Left=default.None yolo[157].Bottom=default.None yolo[157].Back=default.None
yolo[158]=new'Brick' yolo[158].Pos=Vector3.new(-24.6360168, -17.4000168, 59.3972168) yolo[158].Size=Vector3.new(1, 1, 2) yolo[158].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[158].Quaternion=Quaternion.new(0.84338102396839,-1.5258795954047e-005,-0.5373161949661,-1.5258795954047e-005).unit yolo[158].Anchored=true yolo[158].Right=default.None yolo[158].Top=default.None yolo[158].Front=default.None yolo[158].Left=default.None yolo[158].Bottom=default.None yolo[158].Back=default.None
yolo[159]=new'Brick' yolo[159].Pos=Vector3.new(-36.5, 3.29999995, -53) yolo[159].Size=Vector3.new(24, 40, 63) yolo[159].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[159].Quaternion=Quaternion.new(0.70710678118655,0,-0.70710678118655,0).unit yolo[159].Anchored=true yolo[159].Right=default.Universal yolo[159].Top=default.Universal yolo[159].Front=default.Universal yolo[159].Left=default.Universal yolo[159].Bottom=default.Universal yolo[159].Back=default.Universal
yolo[160]=new'Brick' yolo[160].Pos=Vector3.new(-56.8121338, -2.69988632, -40.5415039) yolo[160].Size=Vector3.new(22, 29, 90) yolo[160].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[160].Quaternion=Quaternion.new(0.79333202140229,-1.5258785986894e-005,-0.60878908682642,-1.5258785986894e-005).unit yolo[160].Anchored=true yolo[160].Right=default.Universal yolo[160].Top=default.Universal yolo[160].Front=default.Universal yolo[160].Left=default.Universal yolo[160].Bottom=default.Universal yolo[160].Back=default.Universal
yolo[161]=new'Brick' yolo[161].Pos=Vector3.new(37.5, 1.2999382, -66.5) yolo[161].Size=Vector3.new(104, 44, 9) yolo[161].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[161].Quaternion=Quaternion.new(1,0,0,0).unit yolo[161].Anchored=true yolo[161].Right=default.Universal yolo[161].Top=default.Universal yolo[161].Front=default.Universal yolo[161].Left=default.Universal yolo[161].Bottom=default.Universal yolo[161].Back=default.Universal
yolo[162]=new'Brick' yolo[162].Pos=Vector3.new(-68, 3.39993668, -45.5) yolo[162].Size=Vector3.new(22, 22, 89) yolo[162].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[162].Quaternion=Quaternion.new(0.60821380385357,0.034592834567492,0.79257406493659,-0.026564447870954).unit yolo[162].Anchored=true yolo[162].Right=default.Universal yolo[162].Top=default.Universal yolo[162].Front=default.Universal yolo[162].Left=default.Universal yolo[162].Bottom=default.Universal yolo[162].Back=default.Universal
yolo[163]=new'Brick' yolo[163].Pos=Vector3.new(-4.60203552, -16.6999397, -24.4743652) yolo[163].Size=Vector3.new(17, 1, 11) yolo[163].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[163].Quaternion=Quaternion.new(0.99904928612107,-1.5258394268507e-005,0.043593948361514,-1.5258394268507e-005).unit yolo[163].Anchored=true yolo[163].Right=default.None yolo[163].Top=default.None yolo[163].Front=default.None yolo[163].Left=default.None yolo[163].Bottom=default.None yolo[163].Back=default.None
yolo[164]=new'Brick' yolo[164].Pos=Vector3.new(93.5, -3.20000005, 14) yolo[164].Size=Vector3.new(34, 13, 20) yolo[164].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[164].Quaternion=Quaternion.new(0,0.70710678118655,-0.70710678118655,-0).unit yolo[164].Anchored=true yolo[164].Right=default.Universal yolo[164].Top=default.Universal yolo[164].Front=default.Universal yolo[164].Left=default.Universal yolo[164].Bottom=default.Universal yolo[164].Back=default.Universal
yolo[165]=new'Brick' yolo[165].Pos=Vector3.new(93.5, 7.94687271, -9.24963379) yolo[165].Size=Vector3.new(10, 13, 32) yolo[165].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[165].Quaternion=Quaternion.new(0.061631199282393,-0.70440220928493,0.70443273366941,0.061631199282393).unit yolo[165].Anchored=true yolo[165].Right=default.Universal yolo[165].Top=default.Universal yolo[165].Front=default.Universal yolo[165].Left=default.Universal yolo[165].Bottom=default.Universal yolo[165].Back=default.Universal
yolo[166]=new'Brick' yolo[166].Pos=Vector3.new(93.5, 10.8000002, -6) yolo[166].Size=Vector3.new(6, 13, 22) yolo[166].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[166].Quaternion=Quaternion.new(0.70710678118655,0,0,-0.70710678118655).unit yolo[166].Anchored=true yolo[166].Right=default.Universal yolo[166].Top=default.Universal yolo[166].Front=default.Universal yolo[166].Left=default.Universal yolo[166].Bottom=default.Universal yolo[166].Back=default.Universal
yolo[167]=new'Brick' yolo[167].Pos=Vector3.new(93.5, 4.60800171, -15.8442383) yolo[167].Size=Vector3.new(8, 13, 24) yolo[167].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[167].Quaternion=Quaternion.new(0.69031953027718,-0.15306310502248,-0.15306045068795,-0.69036449853368).unit yolo[167].Anchored=true yolo[167].Right=default.Universal yolo[167].Top=default.Universal yolo[167].Front=default.Universal yolo[167].Left=default.Universal yolo[167].Bottom=default.Universal yolo[167].Back=default.Universal
yolo[168]=new'Brick' yolo[168].Pos=Vector3.new(116.970261, -2.70008469, 37.7198486) yolo[168].Size=Vector3.new(13, 71, 34) yolo[168].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[168].Quaternion=Quaternion.new(0.15304769753068,-0.15302519176897,0.69032967786042,0.6903655749362).unit yolo[168].Anchored=true yolo[168].Right=default.Universal yolo[168].Top=default.Universal yolo[168].Front=default.Universal yolo[168].Left=default.Universal yolo[168].Bottom=default.Universal yolo[168].Back=default.Universal
yolo[169]=new'Brick' yolo[169].Pos=Vector3.new(124.229095, -10.0081863, 0.785644531) yolo[169].Size=Vector3.new(26, 14, 22) yolo[169].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[169].Quaternion=Quaternion.new(0.76081996123518,-0.22048303276248,-0.27241794585405,0.54619468605213).unit yolo[169].Anchored=true yolo[169].Right=default.Universal yolo[169].Top=default.Universal yolo[169].Front=default.Universal yolo[169].Left=default.Universal yolo[169].Bottom=default.Universal yolo[169].Back=default.Universal
yolo[170]=new'Brick' yolo[170].Pos=Vector3.new(41.0129166, -10.199913, -74.9974365) yolo[170].Size=Vector3.new(111, 29, 68) yolo[170].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[170].Quaternion=Quaternion.new(-0.38267388725682,1.5258609684019e-005,0.92388348080884,1.5258967030571e-005).unit yolo[170].Anchored=true yolo[170].Right=default.Universal yolo[170].Top=default.Universal yolo[170].Front=default.Universal yolo[170].Left=default.Universal yolo[170].Bottom=default.Universal yolo[170].Back=default.Universal
yolo[171]=new'Brick' yolo[171].Pos=Vector3.new(-47.9445038, -7.69990158, -18.97229) yolo[171].Size=Vector3.new(1, 10, 7) yolo[171].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[171].Quaternion=Quaternion.new(0.092299839056163,0.092300852640358,-0.70103770378431,0.7010759134131).unit yolo[171].Anchored=true yolo[171].Right=default.Universal yolo[171].Top=default.Universal yolo[171].Front=default.Universal yolo[171].Left=default.Universal yolo[171].Bottom=default.Universal yolo[171].Back=default.Universal
yolo[172]=new'Brick' yolo[172].Pos=Vector3.new(-59.6473999, 1.30018234, -14.4176025) yolo[172].Size=Vector3.new(3, 3, 3) yolo[172].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[172].Quaternion=Quaternion.new(0.40557069957182,0.4055882638181,-0.57920036147564,0.57925598676016).unit yolo[172].Anchored=true yolo[172].Right=default.None yolo[172].Top=default.None yolo[172].Front=default.None yolo[172].Left=default.None yolo[172].Bottom=default.None yolo[172].Back=default.None
yolo[173]=new'Brick' yolo[173].Pos=Vector3.new(-58.1581726, 4.3001709, -13.4389648) yolo[173].Size=Vector3.new(3, 3, 3) yolo[173].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[173].Quaternion=Quaternion.new(0.54171204942379,0.54166776550629,-0.45453584003484,0.45446812669208).unit yolo[173].Anchored=true yolo[173].Right=default.None yolo[173].Top=default.None yolo[173].Front=default.None yolo[173].Left=default.None yolo[173].Bottom=default.None yolo[173].Back=default.None
yolo[174]=new'Brick' yolo[174].Pos=Vector3.new(-56.2816315, 1.30015182, -12.9543457) yolo[174].Size=Vector3.new(3, 3, 3) yolo[174].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[174].Quaternion=Quaternion.new(0.1527327474014,0.15273008714254,-0.6904059304571,0.69042441597214).unit yolo[174].Anchored=true yolo[174].Right=default.None yolo[174].Top=default.None yolo[174].Front=default.None yolo[174].Left=default.None yolo[174].Bottom=default.None yolo[174].Back=default.None
yolo[175]=new'Brick' yolo[175].Pos=Vector3.new(97, -20.2000008, -26) yolo[175].Size=Vector3.new(158, 1, 120) yolo[175].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[175].Quaternion=Quaternion.new(0.70710678118655,0,-0.70710678118655,0).unit yolo[175].Anchored=true yolo[175].Right=default.None yolo[175].Top=default.None yolo[175].Front=default.None yolo[175].Left=default.None yolo[175].Bottom=default.None yolo[175].Back=default.None
yolo[176]=new'Brick' yolo[176].Pos=Vector3.new(91.628212, 16.8002243, -27.6219482) yolo[176].Size=Vector3.new(7, 6, 18) yolo[176].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[176].Quaternion=Quaternion.new(-0.13050736387916,1.5258464195704e-005,0.99144733785704,1.5258942588725e-005).unit yolo[176].Anchored=true yolo[176].Right=default.Universal yolo[176].Top=default.Universal yolo[176].Front=default.Universal yolo[176].Left=default.Universal yolo[176].Bottom=default.Universal yolo[176].Back=default.Universal
yolo[177]=new'Brick' yolo[177].Pos=Vector3.new(93.5, -3.20000005, -55) yolo[177].Size=Vector3.new(13, 34, 64) yolo[177].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[177].Quaternion=Quaternion.new(0,0,1,0).unit yolo[177].Anchored=true yolo[177].Right=default.Universal yolo[177].Top=default.Universal yolo[177].Front=default.Universal yolo[177].Left=default.Universal yolo[177].Bottom=default.Universal yolo[177].Back=default.Universal
yolo[178]=new'Brick' yolo[178].Pos=Vector3.new(-65.5723572, -17.1999397, -13.3476563) yolo[178].Size=Vector3.new(8, 9, 2) yolo[178].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[178].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[178].Anchored=true yolo[178].Right=default.None yolo[178].Top=default.None yolo[178].Front=default.None yolo[178].Left=default.None yolo[178].Bottom=default.None yolo[178].Back=default.None
yolo[179]=new'Brick' yolo[179].Pos=Vector3.new(-65.089386, -16.199913, -13.4770508) yolo[179].Size=Vector3.new(8, 8, 2) yolo[179].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[179].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[179].Anchored=true yolo[179].Right=default.None yolo[179].Top=default.None yolo[179].Front=default.None yolo[179].Left=default.None yolo[179].Bottom=default.None yolo[179].Back=default.None
yolo[180]=new'Brick' yolo[180].Pos=Vector3.new(-57.224823, -7.69990158, -22.6972656) yolo[180].Size=Vector3.new(1, 10, 7) yolo[180].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[180].Quaternion=Quaternion.new(-0.092271330255619,-0.092271330255619,0.70107579967694,-0.70104525666198).unit yolo[180].Anchored=true yolo[180].Right=default.Universal yolo[180].Top=default.Universal yolo[180].Front=default.Universal yolo[180].Left=default.Universal yolo[180].Bottom=default.Universal yolo[180].Back=default.Universal
yolo[181]=new'Brick' yolo[181].Pos=Vector3.new(-65, -10.6998978, -21.5) yolo[181].Size=Vector3.new(1, 1, 2) yolo[181].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[181].Quaternion=Quaternion.new(0,0,1,0).unit yolo[181].Anchored=true yolo[181].Right=default.None yolo[181].Top=default.None yolo[181].Front=default.None yolo[181].Left=default.None yolo[181].Bottom=default.None yolo[181].Back=default.None
yolo[182]=new'Brick' yolo[182].Pos=Vector3.new(-61, -10.6998978, -21.5) yolo[182].Size=Vector3.new(1, 1, 2) yolo[182].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[182].Quaternion=Quaternion.new(1.52587890625e-005,1.52587890625e-005,1,1.52587890625e-005).unit yolo[182].Anchored=true yolo[182].Right=default.None yolo[182].Top=default.None yolo[182].Front=default.None yolo[182].Left=default.None yolo[182].Bottom=default.None yolo[182].Back=default.None
yolo[183]=new'Brick' yolo[183].Pos=Vector3.new(-65, -8.69964218, -21.5) yolo[183].Size=Vector3.new(1, 1, 2) yolo[183].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[183].Quaternion=Quaternion.new(0,0,1,0).unit yolo[183].Anchored=true yolo[183].Right=default.None yolo[183].Top=default.None yolo[183].Front=default.None yolo[183].Left=default.None yolo[183].Bottom=default.None yolo[183].Back=default.None
yolo[184]=new'Brick' yolo[184].Pos=Vector3.new(-63, -9.70012665, -20.5) yolo[184].Size=Vector3.new(1, 3, 5) yolo[184].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[184].Quaternion=Quaternion.new(0.70710678118655,0,-0.70710678118655,0).unit yolo[184].Anchored=true yolo[184].Right=default.None yolo[184].Top=default.None yolo[184].Front=default.None yolo[184].Left=default.None yolo[184].Bottom=default.None yolo[184].Back=default.None
yolo[185]=new'Brick' yolo[185].Pos=Vector3.new(-61, -8.69964218, -21.5) yolo[185].Size=Vector3.new(1, 1, 2) yolo[185].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[185].Quaternion=Quaternion.new(0,0,1,0).unit yolo[185].Anchored=true yolo[185].Right=default.None yolo[185].Top=default.None yolo[185].Front=default.None yolo[185].Left=default.None yolo[185].Bottom=default.None yolo[185].Back=default.None
yolo[186]=new'Brick' yolo[186].Pos=Vector3.new(-16.7229004, -16.6999092, -35.7382813) yolo[186].Size=Vector3.new(51, 1, 35) yolo[186].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[186].Quaternion=Quaternion.new(0.92388292436397,-1.5258883684807e-005,0.38267523062729,-1.5258692706094e-005).unit yolo[186].Anchored=true yolo[186].Right=default.None yolo[186].Top=default.None yolo[186].Front=default.None yolo[186].Left=default.None yolo[186].Bottom=default.None yolo[186].Back=default.None
yolo[187]=new'Brick' yolo[187].Pos=Vector3.new(-69.7948456, 3.80011368, -1.34838867) yolo[187].Size=Vector3.new(8, 1, 9) yolo[187].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[187].Quaternion=Quaternion.new(0.90630543473485,-1.5258445316588e-005,-0.42262331819134,-1.5258212500185e-005).unit yolo[187].Anchored=true yolo[187].Right=default.None yolo[187].Top=default.None yolo[187].Front=default.None yolo[187].Left=default.None yolo[187].Bottom=default.None yolo[187].Back=default.None
yolo[188]=new'Brick' yolo[188].Pos=Vector3.new(-32, -16.6999092, -23) yolo[188].Size=Vector3.new(35, 1, 19) yolo[188].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[188].Quaternion=Quaternion.new(0.70709523273549,-1.5258789774987e-005,-0.70711830875245,-1.5258630912989e-005).unit yolo[188].Anchored=true yolo[188].Right=default.None yolo[188].Top=default.None yolo[188].Front=default.None yolo[188].Left=default.None yolo[188].Bottom=default.None yolo[188].Back=default.None
yolo[189]=new'Brick' yolo[189].Pos=Vector3.new(-80.742981, -10.699913, -13.9414063) yolo[189].Size=Vector3.new(10, 19, 1) yolo[189].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[189].Quaternion=Quaternion.new(0.70107196964703,0.70104570702898,0.092271385869933,-0.092298440088767).unit yolo[189].Anchored=true yolo[189].Right=default.Universal yolo[189].Top=default.Universal yolo[189].Front=default.Universal yolo[189].Left=default.Universal yolo[189].Bottom=default.Universal yolo[189].Back=default.Universal
yolo[190]=new'Brick' yolo[190].Pos=Vector3.new(-40.5369263, -8.69991684, -31.9615479) yolo[190].Size=Vector3.new(3, 1, 11) yolo[190].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[190].Quaternion=Quaternion.new(0.56100173400507,0.56097671683779,-0.43047935674291,0.4304296403317).unit yolo[190].Anchored=true yolo[190].Right=default.Universal yolo[190].Top=default.Universal yolo[190].Front=default.Universal yolo[190].Left=default.Universal yolo[190].Bottom=default.Universal yolo[190].Back=default.Universal
yolo[191]=new'Brick' yolo[191].Pos=Vector3.new(-37.844696, -6.19989395, -16.1185303) yolo[191].Size=Vector3.new(4, 1, 6) yolo[191].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[191].Quaternion=Quaternion.new(-0.092271330255619,-0.092271330255619,0.70107579967694,-0.70104525666198).unit yolo[191].Anchored=true yolo[191].Right=default.Universal yolo[191].Top=default.Universal yolo[191].Front=default.Universal yolo[191].Left=default.Universal yolo[191].Bottom=default.Universal yolo[191].Back=default.Universal
yolo[192]=new'Brick' yolo[192].Pos=Vector3.new(-66.6769714, -7.19990158, -21.3338623) yolo[192].Size=Vector3.new(10, 1, 8) yolo[192].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[192].Quaternion=Quaternion.new(0.56100173400507,0.56097671683779,-0.43047935674291,0.4304296403317).unit yolo[192].Anchored=true yolo[192].Right=default.Universal yolo[192].Top=default.Universal yolo[192].Front=default.Universal yolo[192].Left=default.Universal yolo[192].Bottom=default.Universal yolo[192].Back=default.Universal
yolo[193]=new'Brick' yolo[193].Pos=Vector3.new(-70.3419189, -8.19990158, -15.6931152) yolo[193].Size=Vector3.new(11, 1, 8) yolo[193].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[193].Quaternion=Quaternion.new(0.70107196964703,0.70104570702898,0.092271385869933,-0.092298440088767).unit yolo[193].Anchored=true yolo[193].Right=default.Universal yolo[193].Top=default.Universal yolo[193].Front=default.Universal yolo[193].Left=default.Universal yolo[193].Bottom=default.Universal yolo[193].Back=default.Universal
yolo[194]=new'Brick' yolo[194].Pos=Vector3.new(-54.3187256, -12.1998978, -29.3039551) yolo[194].Size=Vector3.new(29, 1, 18) yolo[194].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[194].Quaternion=Quaternion.new(0.70107196964703,0.70104570702898,0.092271385869933,-0.092298440088767).unit yolo[194].Anchored=true yolo[194].Right=default.Universal yolo[194].Top=default.Universal yolo[194].Front=default.Universal yolo[194].Left=default.Universal yolo[194].Bottom=default.Universal yolo[194].Back=default.Universal
yolo[195]=new'Brick' yolo[195].Pos=Vector3.new(-39.7604675, -16.199913, -29.0637207) yolo[195].Size=Vector3.new(9, 1, 10) yolo[195].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[195].Quaternion=Quaternion.new(0.56100173400507,0.56097671683779,-0.43047935674291,0.4304296403317).unit yolo[195].Anchored=true yolo[195].Right=default.Universal yolo[195].Top=default.Universal yolo[195].Front=default.Universal yolo[195].Left=default.Universal yolo[195].Bottom=default.Universal yolo[195].Back=default.Universal
yolo[196]=new'Brick' yolo[196].Pos=Vector3.new(-86.490097, -10.699913, -5.05615234) yolo[196].Size=Vector3.new(14, 15, 1) yolo[196].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[196].Quaternion=Quaternion.new(-0.4055695211861,-0.4055695211861,0.57924775052282,-0.57921715060901).unit yolo[196].Anchored=true yolo[196].Right=default.Universal yolo[196].Top=default.Universal yolo[196].Front=default.Universal yolo[196].Left=default.Universal yolo[196].Bottom=default.Universal yolo[196].Back=default.Universal
yolo[197]=new'Brick' yolo[197].Pos=Vector3.new(-20.5, -18.1999435, -17) yolo[197].Size=Vector3.new(47, 3, 96) yolo[197].Colour=Colour4.new(215.00001758337,197.00001865625,154.00000602007,255) yolo[197].Quaternion=Quaternion.new(0.70710678118655,0,-0.70710678118655,0).unit yolo[197].Anchored=true yolo[197].Right=default.Universal yolo[197].Top=default.Universal yolo[197].Front=default.Universal yolo[197].Left=default.Universal yolo[197].Bottom=default.Universal yolo[197].Back=default.Universal
yolo[198]=new'Brick' yolo[198].Pos=Vector3.new(-74.1362915, -7.19990158, -10.5352783) yolo[198].Size=Vector3.new(9, 1, 8) yolo[198].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[198].Quaternion=Quaternion.new(0.43046106947847,0.43046791219985,0.56099237529639,-0.56097076220827).unit yolo[198].Anchored=true yolo[198].Right=default.Universal yolo[198].Top=default.Universal yolo[198].Front=default.Universal yolo[198].Left=default.Universal yolo[198].Bottom=default.Universal yolo[198].Back=default.Universal
yolo[199]=new'Brick' yolo[199].Pos=Vector3.new(-68.1488495, -7.69990158, -8.03503418) yolo[199].Size=Vector3.new(11, 1, 8) yolo[199].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[199].Quaternion=Quaternion.new(0.70107196964703,0.70104570702898,0.092271385869933,-0.092298440088767).unit yolo[199].Anchored=true yolo[199].Right=default.Universal yolo[199].Top=default.Universal yolo[199].Front=default.Universal yolo[199].Left=default.Universal yolo[199].Bottom=default.Universal yolo[199].Back=default.Universal
yolo[200]=new'Brick' yolo[200].Pos=Vector3.new(-56.9483795, -2.1998558, -19.7995605) yolo[200].Size=Vector3.new(39, 18, 4) yolo[200].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[200].Quaternion=Quaternion.new(0.092299839056163,0.092300852640358,-0.70103770378431,0.7010759134131).unit yolo[200].Anchored=true yolo[200].Right=default.Universal yolo[200].Top=default.Universal yolo[200].Front=default.Universal yolo[200].Left=default.Universal yolo[200].Bottom=default.Universal yolo[200].Back=default.Universal
yolo[201]=new'Brick' yolo[201].Pos=Vector3.new(-46.5380249, -6.19989395, -13.7890625) yolo[201].Size=Vector3.new(2, 1, 6) yolo[201].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[201].Quaternion=Quaternion.new(0.092299839056163,0.092300852640358,-0.70103770378431,0.7010759134131).unit yolo[201].Anchored=true yolo[201].Right=default.Universal yolo[201].Top=default.Universal yolo[201].Front=default.Universal yolo[201].Left=default.Universal yolo[201].Bottom=default.Universal yolo[201].Back=default.Universal
yolo[202]=new'Brick' yolo[202].Pos=Vector3.new(-54.2654419, -6.19989395, -11.7185059) yolo[202].Size=Vector3.new(2, 1, 6) yolo[202].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[202].Quaternion=Quaternion.new(-0.092271330255619,-0.092271330255619,0.70107579967694,-0.70104525666198).unit yolo[202].Anchored=true yolo[202].Right=default.Universal yolo[202].Top=default.Universal yolo[202].Front=default.Universal yolo[202].Left=default.Universal yolo[202].Bottom=default.Universal yolo[202].Back=default.Universal
yolo[203]=new'Brick' yolo[203].Pos=Vector3.new(-49.9187775, -14.699913, -12.8833008) yolo[203].Size=Vector3.new(29, 1, 13) yolo[203].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[203].Quaternion=Quaternion.new(-0.092271330255619,-0.092271330255619,0.70107579967694,-0.70104525666198).unit yolo[203].Anchored=true yolo[203].Right=default.Universal yolo[203].Top=default.Universal yolo[203].Front=default.Universal yolo[203].Left=default.Universal yolo[203].Bottom=default.Universal yolo[203].Back=default.Universal
yolo[204]=new'Brick' yolo[204].Pos=Vector3.new(-47.4868927, -16.6999092, -13.4838867) yolo[204].Size=Vector3.new(30, 1, 30) yolo[204].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[204].Quaternion=Quaternion.new(0.84338102396839,-1.5258795954047e-005,-0.5373161949661,-1.5258795954047e-005).unit yolo[204].Anchored=true yolo[204].Right=default.None yolo[204].Top=default.None yolo[204].Front=default.None yolo[204].Left=default.None yolo[204].Bottom=default.None yolo[204].Back=default.None
yolo[205]=new'Brick' yolo[205].Pos=Vector3.new(-52, -16.6999092, 4.5) yolo[205].Size=Vector3.new(6, 1, 10) yolo[205].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[205].Quaternion=Quaternion.new(0.70709523273549,-1.5258789774987e-005,-0.70711830875245,-1.5258630912989e-005).unit yolo[205].Anchored=true yolo[205].Right=default.None yolo[205].Top=default.None yolo[205].Front=default.None yolo[205].Left=default.None yolo[205].Bottom=default.None yolo[205].Back=default.None
yolo[206]=new'Brick' yolo[206].Pos=Vector3.new(-69.6169739, -7.1999321, -1.32141113) yolo[206].Size=Vector3.new(9, 22, 10) yolo[206].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[206].Quaternion=Quaternion.new(0.90630543473485,-1.5258445316588e-005,-0.42262331819134,-1.5258212500185e-005).unit yolo[206].Anchored=true yolo[206].Right=default.Universal yolo[206].Top=default.Universal yolo[206].Front=default.Universal yolo[206].Left=default.Universal yolo[206].Bottom=default.Universal yolo[206].Back=default.Universal
yolo[207]=new'Brick' yolo[207].Pos=Vector3.new(-62.4757996, -6.19989395, -9.51855469) yolo[207].Size=Vector3.new(3, 1, 6) yolo[207].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[207].Quaternion=Quaternion.new(0.092299839056163,0.092300852640358,-0.70103770378431,0.7010759134131).unit yolo[207].Anchored=true yolo[207].Right=default.Universal yolo[207].Top=default.Universal yolo[207].Front=default.Universal yolo[207].Left=default.Universal yolo[207].Bottom=default.Universal yolo[207].Back=default.Universal
yolo[208]=new'Brick' yolo[208].Pos=Vector3.new(-96.5, -9.22506714, -14.2978516) yolo[208].Size=Vector3.new(14, 19, 17) yolo[208].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[208].Quaternion=Quaternion.new(0.70709523273549,-1.5258789774987e-005,-0.70711830875245,-1.5258630912989e-005).unit yolo[208].Anchored=true yolo[208].Right=default.Universal yolo[208].Top=default.Universal yolo[208].Front=default.Universal yolo[208].Left=default.Universal yolo[208].Bottom=default.Universal yolo[208].Back=default.Universal
yolo[209]=new'Brick' yolo[209].Pos=Vector3.new(-93, -15.6999998, 0.5) yolo[209].Size=Vector3.new(8, 1, 11) yolo[209].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[209].Quaternion=Quaternion.new(0.70710678118655,0.70710678118655,-0,0).unit yolo[209].Anchored=true yolo[209].Right=default.Universal yolo[209].Top=default.Universal yolo[209].Front=default.Universal yolo[209].Left=default.Universal yolo[209].Bottom=default.Universal yolo[209].Back=default.Universal
yolo[210]=new'Brick' yolo[210].Pos=Vector3.new(-74.5, -13.6999998, 2) yolo[210].Size=Vector3.new(4, 1, 7) yolo[210].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[210].Quaternion=Quaternion.new(-0.5,0.5,0.5,0.5).unit yolo[210].Anchored=true yolo[210].Right=default.Universal yolo[210].Top=default.Universal yolo[210].Front=default.Universal yolo[210].Left=default.Universal yolo[210].Bottom=default.Universal yolo[210].Back=default.Universal
yolo[211]=new'Brick' yolo[211].Pos=Vector3.new(-77.5, -15.1999998, 0.5) yolo[211].Size=Vector3.new(7, 1, 11) yolo[211].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[211].Quaternion=Quaternion.new(0.70710678118655,0.70710678118655,-0,0).unit yolo[211].Anchored=true yolo[211].Right=default.Universal yolo[211].Top=default.Universal yolo[211].Front=default.Universal yolo[211].Left=default.Universal yolo[211].Bottom=default.Universal yolo[211].Back=default.Universal
yolo[212]=new'Brick' yolo[212].Pos=Vector3.new(70.0000076, -23.6999569, -25) yolo[212].Size=Vector3.new(55, 7, 98) yolo[212].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[212].Quaternion=Quaternion.new(1,-1.52587890625e-005,-1.52587890625e-005,-1.52587890625e-005).unit yolo[212].Anchored=true yolo[212].Right=default.Universal yolo[212].Top=default.Universal yolo[212].Front=default.Universal yolo[212].Left=default.Universal yolo[212].Bottom=default.Universal yolo[212].Back=default.Universal
yolo[213]=new'Brick' yolo[213].Pos=Vector3.new(-20.2584229, -14.699913, -22.3032227) yolo[213].Size=Vector3.new(3, 3, 3) yolo[213].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[213].Quaternion=Quaternion.new(-0.27060958253979,-0.27059807502169,0.65330820247411,-0.65324999182979).unit yolo[213].Anchored=true yolo[213].Right=default.None yolo[213].Top=default.None yolo[213].Front=default.None yolo[213].Left=default.None yolo[213].Bottom=default.None yolo[213].Back=default.None
yolo[214]=new'Brick' yolo[214].Pos=Vector3.new(-37.8286133, -11.6998978, -29.5814209) yolo[214].Size=Vector3.new(3, 3, 3) yolo[214].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[214].Quaternion=Quaternion.new(0.56100173400507,0.56097671683779,-0.43047935674291,0.4304296403317).unit yolo[214].Anchored=true yolo[214].Right=default.None yolo[214].Top=default.None yolo[214].Front=default.None yolo[214].Left=default.None yolo[214].Bottom=default.None yolo[214].Back=default.None
yolo[215]=new'Brick' yolo[215].Pos=Vector3.new(-38, -14.699913, -31) yolo[215].Size=Vector3.new(3, 3, 3) yolo[215].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[215].Quaternion=Quaternion.new(0.65330333446689,0.65326033358684,-0.27062135822115,0.27057305059051).unit yolo[215].Anchored=true yolo[215].Right=default.None yolo[215].Top=default.None yolo[215].Front=default.None yolo[215].Left=default.None yolo[215].Bottom=default.None yolo[215].Back=default.None
yolo[216]=new'Brick' yolo[216].Pos=Vector3.new(-37.3109894, -14.6999283, -27.6495361) yolo[216].Size=Vector3.new(3, 3, 3) yolo[216].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[216].Quaternion=Quaternion.new(0.092299840369909,0.092300851282406,0.70106822499605,-0.70104539186664).unit yolo[216].Anchored=true yolo[216].Right=default.None yolo[216].Top=default.None yolo[216].Front=default.None yolo[216].Left=default.None yolo[216].Bottom=default.None yolo[216].Back=default.None
yolo[217]=new'Brick' yolo[217].Pos=Vector3.new(-114.169861, -4.69987106, -9.5) yolo[217].Size=Vector3.new(28, 43, 43) yolo[217].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[217].Quaternion=Quaternion.new(0.86601430559897,-1.5258596807188e-005,-0.50001923477137,-1.5258372062787e-005).unit yolo[217].Anchored=true yolo[217].Right=default.Universal yolo[217].Top=default.Universal yolo[217].Front=default.Universal yolo[217].Left=default.Universal yolo[217].Bottom=default.Universal yolo[217].Back=default.Universal
yolo[218]=new'Brick' yolo[218].Pos=Vector3.new(-118, 3.79999995, 22) yolo[218].Size=Vector3.new(40, 22, 44) yolo[218].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[218].Quaternion=Quaternion.new(1,0,0,0).unit yolo[218].Anchored=true yolo[218].Right=default.Universal yolo[218].Top=default.Universal yolo[218].Front=default.Universal yolo[218].Left=default.Universal yolo[218].Bottom=default.Universal yolo[218].Back=default.Universal
yolo[219]=new'Brick' yolo[219].Pos=Vector3.new(-132.5, -13.6999998, 32) yolo[219].Size=Vector3.new(13, 1, 26) yolo[219].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[219].Quaternion=Quaternion.new(0,0.70710678118655,-0.70710678118655,-0).unit yolo[219].Anchored=true yolo[219].Right=default.Universal yolo[219].Top=default.Universal yolo[219].Front=default.Universal yolo[219].Left=default.Universal yolo[219].Bottom=default.Universal yolo[219].Back=default.Universal
yolo[220]=new'Brick' yolo[220].Pos=Vector3.new(-96.5, -15.6999998, 12) yolo[220].Size=Vector3.new(11, 1, 24) yolo[220].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[220].Quaternion=Quaternion.new(0.70710678118655,0,0,-0.70710678118655).unit yolo[220].Anchored=true yolo[220].Right=default.Universal yolo[220].Top=default.Universal yolo[220].Front=default.Universal yolo[220].Left=default.Universal yolo[220].Bottom=default.Universal yolo[220].Back=default.Universal
yolo[221]=new'Brick' yolo[221].Pos=Vector3.new(-77.0780334, -15.6999283, -19.5821533) yolo[221].Size=Vector3.new(20, 12, 9) yolo[221].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[221].Quaternion=Quaternion.new(0.092299839056163,0.092300852640358,-0.70103770378431,0.7010759134131).unit yolo[221].Anchored=true yolo[221].Right=default.Universal yolo[221].Top=default.Universal yolo[221].Front=default.Universal yolo[221].Left=default.Universal yolo[221].Bottom=default.Universal yolo[221].Back=default.Universal
yolo[222]=new'Brick' yolo[222].Pos=Vector3.new(-71.5295868, -15.6999283, -7.12915039) yolo[222].Size=Vector3.new(16, 1, 9) yolo[222].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[222].Quaternion=Quaternion.new(0.092299839056163,0.092300852640358,-0.70103770378431,0.7010759134131).unit yolo[222].Anchored=true yolo[222].Right=default.Universal yolo[222].Top=default.Universal yolo[222].Front=default.Universal yolo[222].Left=default.Universal yolo[222].Bottom=default.Universal yolo[222].Back=default.Universal
yolo[223]=new'Brick' yolo[223].Pos=Vector3.new(-79.9122314, -15.6999283, -2.66210938) yolo[223].Size=Vector3.new(6, 1, 9) yolo[223].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[223].Quaternion=Quaternion.new(0.40557069957182,0.4055882638181,-0.57920036147564,0.57925598676016).unit yolo[223].Anchored=true yolo[223].Right=default.Universal yolo[223].Top=default.Universal yolo[223].Front=default.Universal yolo[223].Left=default.Universal yolo[223].Bottom=default.Universal yolo[223].Back=default.Universal
yolo[224]=new'Brick' yolo[224].Pos=Vector3.new(-89.6494598, -15.6999283, -10.9949951) yolo[224].Size=Vector3.new(21, 9, 9) yolo[224].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[224].Quaternion=Quaternion.new(0.40557069957182,0.4055882638181,-0.57920036147564,0.57925598676016).unit yolo[224].Anchored=true yolo[224].Right=default.Universal yolo[224].Top=default.Universal yolo[224].Front=default.Universal yolo[224].Left=default.Universal yolo[224].Bottom=default.Universal yolo[224].Back=default.Universal
yolo[225]=new'Brick' yolo[225].Pos=Vector3.new(-37.5605011, -12.1998978, -20.8533936) yolo[225].Size=Vector3.new(10, 1, 18) yolo[225].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[225].Quaternion=Quaternion.new(0.56100173400507,0.56097671683779,-0.43047935674291,0.4304296403317).unit yolo[225].Anchored=true yolo[225].Right=default.Universal yolo[225].Top=default.Universal yolo[225].Front=default.Universal yolo[225].Left=default.Universal yolo[225].Bottom=default.Universal yolo[225].Back=default.Universal
yolo[226]=new'Brick' yolo[226].Pos=Vector3.new(-52.7311096, -16.199913, -21.4471436) yolo[226].Size=Vector3.new(17, 28, 10) yolo[226].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[226].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[226].Anchored=true yolo[226].Right=default.None yolo[226].Top=default.None yolo[226].Front=default.None yolo[226].Left=default.None yolo[226].Bottom=default.None yolo[226].Back=default.None
yolo[227]=new'Brick' yolo[227].Pos=Vector3.new(-62.6745911, -13.1999092, -14.1240234) yolo[227].Size=Vector3.new(8, 7, 2) yolo[227].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[227].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[227].Anchored=true yolo[227].Right=default.None yolo[227].Top=default.None yolo[227].Front=default.None yolo[227].Left=default.None yolo[227].Bottom=default.None yolo[227].Back=default.None
yolo[228]=new'Brick' yolo[228].Pos=Vector3.new(-62.6745758, -14.199913, -14.1240234) yolo[228].Size=Vector3.new(8, 9, 2) yolo[228].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[228].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[228].Anchored=true yolo[228].Right=default.None yolo[228].Top=default.None yolo[228].Front=default.None yolo[228].Left=default.None yolo[228].Bottom=default.None yolo[228].Back=default.None
yolo[229]=new'Brick' yolo[229].Pos=Vector3.new(-63.1575317, -15.199913, -13.9946289) yolo[229].Size=Vector3.new(8, 10, 2) yolo[229].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[229].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[229].Anchored=true yolo[229].Right=default.None yolo[229].Top=default.None yolo[229].Front=default.None yolo[229].Left=default.None yolo[229].Bottom=default.None yolo[229].Back=default.None
yolo[230]=new'Brick' yolo[230].Pos=Vector3.new(-66.0553284, -18.1999435, -13.2182617) yolo[230].Size=Vector3.new(8, 10, 2) yolo[230].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[230].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[230].Anchored=true yolo[230].Right=default.None yolo[230].Top=default.None yolo[230].Front=default.None yolo[230].Left=default.None yolo[230].Bottom=default.None yolo[230].Back=default.None
yolo[231]=new'Brick' yolo[231].Pos=Vector3.new(-66.5382843, -19.199955, -13.0887451) yolo[231].Size=Vector3.new(8, 11, 2) yolo[231].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[231].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[231].Anchored=true yolo[231].Right=default.None yolo[231].Top=default.None yolo[231].Front=default.None yolo[231].Left=default.None yolo[231].Bottom=default.None yolo[231].Back=default.None
yolo[232]=new'Brick' yolo[232].Pos=Vector3.new(-67.0212402, -20.1999607, -12.9593506) yolo[232].Size=Vector3.new(8, 12, 2) yolo[232].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[232].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[232].Anchored=true yolo[232].Right=default.None yolo[232].Top=default.None yolo[232].Front=default.None yolo[232].Left=default.None yolo[232].Bottom=default.None yolo[232].Back=default.None
yolo[233]=new'Brick' yolo[233].Pos=Vector3.new(-72.6874084, -20.6999607, -10.9234619) yolo[233].Size=Vector3.new(9, 24, 1) yolo[233].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[233].Quaternion=Quaternion.new(0.43045549018076,-0.43043525498494,0.56098954998642,0.56100293874241).unit yolo[233].Anchored=true yolo[233].Right=default.None yolo[233].Top=default.None yolo[233].Front=default.None yolo[233].Left=default.None yolo[233].Bottom=default.None yolo[233].Back=default.None
yolo[234]=new'Brick' yolo[234].Pos=Vector3.new(-83.5, -20.6999969, -4.5) yolo[234].Size=Vector3.new(9, 13, 1) yolo[234].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[234].Quaternion=Quaternion.new(0.69635198878592,-0.69636942888313,-0.12278817595776,-0.12278817595776).unit yolo[234].Anchored=true yolo[234].Right=default.None yolo[234].Top=default.None yolo[234].Front=default.None yolo[234].Left=default.None yolo[234].Bottom=default.None yolo[234].Back=default.None
yolo[235]=new'Brick' yolo[235].Pos=Vector3.new(47.0488968, -8.24934006, 5.23303223) yolo[235].Size=Vector3.new(22, 11, 1) yolo[235].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[235].Quaternion=Quaternion.new(0.68305961074581,-0.70287556045177,0.19838380350116,0.0062729395516585).unit yolo[235].Anchored=true yolo[235].Right=default.None yolo[235].Top=default.None yolo[235].Front=default.None yolo[235].Left=default.None yolo[235].Bottom=default.None yolo[235].Back=default.None
yolo[236]=new'Brick' yolo[236].Pos=Vector3.new(44.5626907, -12.0405502, 0.711425781) yolo[236].Size=Vector3.new(22, 1, 9) yolo[236].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[236].Quaternion=Quaternion.new(0.68305961074581,-0.70287556045177,0.19838380350116,0.0062729395516585).unit yolo[236].Anchored=true yolo[236].Right=default.None yolo[236].Top=default.None yolo[236].Front=default.None yolo[236].Left=default.None yolo[236].Bottom=default.None yolo[236].Back=default.None
yolo[237]=new'Brick' yolo[237].Pos=Vector3.new(47.4373093, -12.1596756, 10.2885742) yolo[237].Size=Vector3.new(22, 1, 9) yolo[237].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[237].Quaternion=Quaternion.new(0.68305961074581,-0.70287556045177,0.19838380350116,0.0062729395516585).unit yolo[237].Anchored=true yolo[237].Right=default.None yolo[237].Top=default.None yolo[237].Front=default.None yolo[237].Left=default.None yolo[237].Bottom=default.None yolo[237].Back=default.None
yolo[238]=new'Brick' yolo[238].Pos=Vector3.new(44.9511032, -15.9509201, 5.76696777) yolo[238].Size=Vector3.new(22, 11, 1) yolo[238].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[238].Quaternion=Quaternion.new(0.68305961074581,-0.70287556045177,0.19838380350116,0.0062729395516585).unit yolo[238].Anchored=true yolo[238].Right=default.None yolo[238].Top=default.None yolo[238].Front=default.None yolo[238].Left=default.None yolo[238].Bottom=default.None yolo[238].Back=default.None
yolo[239]=new'Brick' yolo[239].Pos=Vector3.new(21.6294098, -20.1999607, -0.0170898438) yolo[239].Size=Vector3.new(31, 12, 98) yolo[239].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[239].Quaternion=Quaternion.new(0.99144693205492,-1.5258442920815e-005,0.13050749244476,-1.5258442920815e-005).unit yolo[239].Anchored=true yolo[239].Right=default.Universal yolo[239].Top=default.None yolo[239].Front=default.Universal yolo[239].Left=default.Universal yolo[239].Bottom=default.Universal yolo[239].Back=default.Universal
yolo[240]=new'Brick' yolo[240].Pos=Vector3.new(-83.4035339, -19.6999245, 8.56091309) yolo[240].Size=Vector3.new(1, 1, 2) yolo[240].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[240].Quaternion=Quaternion.new(0.34202414540541,1.525843765659e-005,0.9396911605038,1.5258827222474e-005).unit yolo[240].Anchored=true yolo[240].Right=default.None yolo[240].Top=default.None yolo[240].Front=default.None yolo[240].Left=default.None yolo[240].Bottom=default.None yolo[240].Back=default.None
yolo[241]=new'Brick' yolo[241].Pos=Vector3.new(-80.3393555, -19.6999245, 11.1320801) yolo[241].Size=Vector3.new(1, 1, 2) yolo[241].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[241].Quaternion=Quaternion.new(0.34202414540541,1.525843765659e-005,0.9396911605038,1.5258827222474e-005).unit yolo[241].Anchored=true yolo[241].Right=default.None yolo[241].Top=default.None yolo[241].Front=default.None yolo[241].Left=default.None yolo[241].Bottom=default.None yolo[241].Back=default.None
yolo[242]=new'Brick' yolo[242].Pos=Vector3.new(-83.4035339, -17.6998863, 8.56091309) yolo[242].Size=Vector3.new(1, 1, 2) yolo[242].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[242].Quaternion=Quaternion.new(0.34202414540541,1.525843765659e-005,0.9396911605038,1.5258827222474e-005).unit yolo[242].Anchored=true yolo[242].Right=default.None yolo[242].Top=default.None yolo[242].Front=default.None yolo[242].Left=default.None yolo[242].Bottom=default.None yolo[242].Back=default.None
yolo[243]=new'Brick' yolo[243].Pos=Vector3.new(-82.514267, -18.7002296, 10.6126709) yolo[243].Size=Vector3.new(1, 3, 5) yolo[243].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[243].Quaternion=Quaternion.new(-0.42260601361742,1.5258942896512e-005,0.90631349110995,1.5258609480296e-005).unit yolo[243].Anchored=true yolo[243].Right=default.None yolo[243].Top=default.None yolo[243].Front=default.None yolo[243].Left=default.None yolo[243].Bottom=default.None yolo[243].Back=default.None
yolo[244]=new'Brick' yolo[244].Pos=Vector3.new(-80.3393555, -17.6998863, 11.1320801) yolo[244].Size=Vector3.new(1, 1, 2) yolo[244].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[244].Quaternion=Quaternion.new(0.34202414540541,1.525843765659e-005,0.9396911605038,1.5258827222474e-005).unit yolo[244].Anchored=true yolo[244].Right=default.None yolo[244].Top=default.None yolo[244].Front=default.None yolo[244].Left=default.None yolo[244].Bottom=default.None yolo[244].Back=default.None
yolo[245]=new'Brick' yolo[245].Pos=Vector3.new(-103.5, -6.70000029, 22.5) yolo[245].Size=Vector3.new(9, 59, 45) yolo[245].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[245].Quaternion=Quaternion.new(0,0.70710678118655,-0.70710678118655,-0).unit yolo[245].Anchored=true yolo[245].Right=default.Universal yolo[245].Top=default.Universal yolo[245].Front=default.Universal yolo[245].Left=default.Universal yolo[245].Bottom=default.Universal yolo[245].Back=default.Universal
yolo[246]=new'Brick' yolo[246].Pos=Vector3.new(43.3653641, -20.4001255, -8.58532715) yolo[246].Size=Vector3.new(18, 7, 71) yolo[246].Colour=Colour4.new(58.000004142523,125.0000077486,21.000000648201,255) yolo[246].Quaternion=Quaternion.new(0.976438636554,-0.019974082470213,0.12089735320006,-0.17763050116362).unit yolo[246].Anchored=true yolo[246].Right=default.Universal yolo[246].Top=default.None yolo[246].Front=default.Universal yolo[246].Left=default.Universal yolo[246].Bottom=default.Universal yolo[246].Back=default.Universal
yolo[247]=new'Brick' yolo[247].Pos=Vector3.new(-119.5, 12.4564095, 28.7919922) yolo[247].Size=Vector3.new(40, 19, 34) yolo[247].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[247].Quaternion=Quaternion.new(0.98481053602136,0.17363088183479,-1.5258656923138e-005,-1.5258656923138e-005).unit yolo[247].Anchored=true yolo[247].Right=default.Universal yolo[247].Top=default.Universal yolo[247].Front=default.Universal yolo[247].Left=default.Universal yolo[247].Bottom=default.Universal yolo[247].Back=default.Universal
yolo[248]=new'Brick' yolo[248].Pos=Vector3.new(-114, -14.1999998, 20.5) yolo[248].Size=Vector3.new(14, 1, 36) yolo[248].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[248].Quaternion=Quaternion.new(-0.5,0.5,-0.5,0.5).unit yolo[248].Anchored=true yolo[248].Right=default.Universal yolo[248].Top=default.Universal yolo[248].Front=default.Universal yolo[248].Left=default.Universal yolo[248].Bottom=default.Universal yolo[248].Back=default.Universal
yolo[249]=new'Brick' yolo[249].Pos=Vector3.new(87.4541931, -3.2000885, 25.2427979) yolo[249].Size=Vector3.new(14, 34, 17) yolo[249].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[249].Quaternion=Quaternion.new(-0.34200351962159,1.5258881675998e-005,0.93969868486178,1.5258708429452e-005).unit yolo[249].Anchored=true yolo[249].Right=default.Universal yolo[249].Top=default.Universal yolo[249].Front=default.Universal yolo[249].Left=default.Universal yolo[249].Bottom=default.Universal yolo[249].Back=default.Universal
yolo[250]=new'Brick' yolo[250].Pos=Vector3.new(63, -6.20000029, 45) yolo[250].Size=Vector3.new(74, 40, 44) yolo[250].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[250].Quaternion=Quaternion.new(0,0,1,0).unit yolo[250].Anchored=true yolo[250].Right=default.Universal yolo[250].Top=default.Universal yolo[250].Front=default.Universal yolo[250].Left=default.Universal yolo[250].Bottom=default.Universal yolo[250].Back=default.Universal
yolo[251]=new'Brick' yolo[251].Pos=Vector3.new(48.1509857, 3.92856216, -17.8413086) yolo[251].Size=Vector3.new(22, 1, 9) yolo[251].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[251].Quaternion=Quaternion.new(0.38943070439738,-0.11085807111457,0.59082168342157,0.69784235168491).unit yolo[251].Anchored=true yolo[251].Right=default.None yolo[251].Top=default.None yolo[251].Front=default.None yolo[251].Left=default.None yolo[251].Bottom=default.None yolo[251].Back=default.None
yolo[252]=new'Brick' yolo[252].Pos=Vector3.new(41.4055786, 3.94360733, -10.4588623) yolo[252].Size=Vector3.new(22, 1, 9) yolo[252].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[252].Quaternion=Quaternion.new(0.38943070439738,-0.11085807111457,0.59082168342157,0.69784235168491).unit yolo[252].Anchored=true yolo[252].Right=default.None yolo[252].Top=default.None yolo[252].Front=default.None yolo[252].Left=default.None yolo[252].Bottom=default.None yolo[252].Back=default.None
yolo[253]=new'Brick' yolo[253].Pos=Vector3.new(46.0001907, 7.57980728, -13.0410156) yolo[253].Size=Vector3.new(22, 11, 1) yolo[253].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[253].Quaternion=Quaternion.new(0.38943070439738,-0.11085807111457,0.59082168342157,0.69784235168491).unit yolo[253].Anchored=true yolo[253].Right=default.None yolo[253].Top=default.None yolo[253].Front=default.None yolo[253].Left=default.None yolo[253].Bottom=default.None yolo[253].Back=default.None
yolo[254]=new'Brick' yolo[254].Pos=Vector3.new(43.556366, 0.29233551, -15.2591553) yolo[254].Size=Vector3.new(22, 11, 1) yolo[254].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[254].Quaternion=Quaternion.new(0.38943070439738,-0.11085807111457,0.59082168342157,0.69784235168491).unit yolo[254].Anchored=true yolo[254].Right=default.None yolo[254].Top=default.None yolo[254].Front=default.None yolo[254].Left=default.None yolo[254].Bottom=default.None yolo[254].Back=default.None
yolo[255]=new'Brick' yolo[255].Pos=Vector3.new(48.5, -12.2001114, -19) yolo[255].Size=Vector3.new(15, 39, 28) yolo[255].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[255].Quaternion=Quaternion.new(0.69638138870798,-0.12279565894498,-0.12278930982643,0.69634546455516).unit yolo[255].Anchored=true yolo[255].Right=default.Universal yolo[255].Top=default.Universal yolo[255].Front=default.Universal yolo[255].Left=default.Universal yolo[255].Bottom=default.Universal yolo[255].Back=default.Universal
yolo[256]=new'Brick' yolo[256].Pos=Vector3.new(21.9210205, 4.8001709, -32.5710449) yolo[256].Size=Vector3.new(1, 35, 24) yolo[256].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[256].Quaternion=Quaternion.new(0.65327104031045,0.27059532106837,-0.27061873724236,-0.65328450682741).unit yolo[256].Anchored=true yolo[256].Right=default.None yolo[256].Top=default.None yolo[256].Front=default.None yolo[256].Left=default.None yolo[256].Bottom=default.None yolo[256].Back=default.None
yolo[257]=new'Brick' yolo[257].Pos=Vector3.new(39.9522476, 9.80012512, -27.9748535) yolo[257].Size=Vector3.new(11, 5, 3) yolo[257].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[257].Quaternion=Quaternion.new(-0.27059530322535,-0.65327105185381,0.65328449528381,0.27061876453489).unit yolo[257].Anchored=true yolo[257].Right=default.None yolo[257].Top=default.None yolo[257].Front=default.None yolo[257].Left=default.None yolo[257].Bottom=default.None yolo[257].Back=default.None
yolo[258]=new'Brick' yolo[258].Pos=Vector3.new(37.1238174, 7.80011368, -33.6317139) yolo[258].Size=Vector3.new(7, 15, 1) yolo[258].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[258].Quaternion=Quaternion.new(0.65327104031045,0.27059532106837,-0.27061873724236,-0.65328450682741).unit yolo[258].Anchored=true yolo[258].Right=default.None yolo[258].Top=default.None yolo[258].Front=default.None yolo[258].Left=default.None yolo[258].Bottom=default.None yolo[258].Back=default.None
yolo[259]=new'Brick' yolo[259].Pos=Vector3.new(14.1428528, 10.8001289, -24.0856934) yolo[259].Size=Vector3.new(5, 4, 1) yolo[259].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[259].Quaternion=Quaternion.new(0.27061054794618,0.65326472458452,0.65328450429284,0.27061874155736).unit yolo[259].Anchored=true yolo[259].Right=default.None yolo[259].Top=default.None yolo[259].Front=default.None yolo[259].Left=default.None yolo[259].Bottom=default.None yolo[259].Back=default.None
yolo[260]=new'Brick' yolo[260].Pos=Vector3.new(7.2182312, 5.80010605, -31.510376) yolo[260].Size=Vector3.new(2, 9, 1) yolo[260].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[260].Quaternion=Quaternion.new(0.64084896966133,0.29882481762098,-0.29884798280263,-0.64086366502496).unit yolo[260].Anchored=true yolo[260].Right=default.None yolo[260].Top=default.None yolo[260].Front=default.None yolo[260].Left=default.None yolo[260].Bottom=default.None yolo[260].Back=default.None
yolo[261]=new'Brick' yolo[261].Pos=Vector3.new(8.68206787, 6.59182739, -29.5805664) yolo[261].Size=Vector3.new(2, 5, 1) yolo[261].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[261].Quaternion=Quaternion.new(0.77797774717848,0.2334549998223,-0.3210319558879,-0.48701936864628).unit yolo[261].Anchored=true yolo[261].Right=default.None yolo[261].Top=default.None yolo[261].Front=default.None yolo[261].Left=default.None yolo[261].Bottom=default.None yolo[261].Back=default.None
yolo[262]=new'Brick' yolo[262].Pos=Vector3.new(12.3750916, 10.3001289, -25.8535156) yolo[262].Size=Vector3.new(6, 1, 3) yolo[262].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[262].Quaternion=Quaternion.new(0.42550743130025,0.70282419396324,-0.55824892748355,-0.11549764256369).unit yolo[262].Anchored=true yolo[262].Right=default.None yolo[262].Top=default.None yolo[262].Front=default.None yolo[262].Left=default.None yolo[262].Bottom=default.None yolo[262].Back=default.None
yolo[263]=new'Brick' yolo[263].Pos=Vector3.new(3.18270874, 5.80010605, -37.1672363) yolo[263].Size=Vector3.new(2, 2, 1) yolo[263].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[263].Quaternion=Quaternion.new(0.030869008309602,0.030869008309602,-0.70641641663117,0.70644691726549).unit yolo[263].Anchored=true yolo[263].Right=default.None yolo[263].Top=default.None yolo[263].Front=default.None yolo[263].Left=default.None yolo[263].Bottom=default.None yolo[263].Back=default.None
yolo[264]=new'Brick' yolo[264].Pos=Vector3.new(4.59692383, 4.8001709, -45.6524658) yolo[264].Size=Vector3.new(2, 2, 1) yolo[264].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[264].Quaternion=Quaternion.new(0.18301575172735,0.18302413371196,-0.6829798130952,0.68304170300343).unit yolo[264].Anchored=true yolo[264].Right=default.None yolo[264].Top=default.None yolo[264].Front=default.None yolo[264].Left=default.None yolo[264].Bottom=default.None yolo[264].Back=default.None
yolo[265]=new'Brick' yolo[265].Pos=Vector3.new(32.4290924, 7.61191177, -38.1895752) yolo[265].Size=Vector3.new(7, 1, 5) yolo[265].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[265].Quaternion=Quaternion.new(0.60757508139665,-0.19126975396553,0.35533293308557,-0.684100293172).unit yolo[265].Anchored=true yolo[265].Right=default.None yolo[265].Top=default.None yolo[265].Front=default.None yolo[265].Left=default.None yolo[265].Bottom=default.None yolo[265].Back=default.None
yolo[266]=new'Brick' yolo[266].Pos=Vector3.new(37.1238327, 4.8001709, -41.40979) yolo[266].Size=Vector3.new(2, 2, 1) yolo[266].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[266].Quaternion=Quaternion.new(0.59640340281496,0.59635248666106,0.37991327230877,-0.37991132029632).unit yolo[266].Anchored=true yolo[266].Right=default.None yolo[266].Top=default.None yolo[266].Front=default.None yolo[266].Left=default.None yolo[266].Bottom=default.None yolo[266].Back=default.None
yolo[267]=new'Brick' yolo[267].Pos=Vector3.new(18.0319519, 6.80011749, -44.2382813) yolo[267].Size=Vector3.new(3, 3, 3) yolo[267].Colour=Colour4.new(160.00000566244,95.000001937151,53.000004440546,255) yolo[267].Quaternion=Quaternion.new(1.5259106038348e-005,1.5258946190389e-005,0.70712568399159,-0.70708785781395).unit yolo[267].Anchored=true yolo[267].Right=default.None yolo[267].Top=default.None yolo[267].Front=default.None yolo[267].Left=default.None yolo[267].Bottom=default.None yolo[267].Back=default.None
yolo[268]=new'Brick' yolo[268].Pos=Vector3.new(39.792511, 10.8894234, -30.9476318) yolo[268].Size=Vector3.new(3, 6, 1) yolo[268].Colour=Colour4.new(204.00001823902,142.00000673532,105.0000089407,255) yolo[268].Quaternion=Quaternion.new(0.83444927220758,0.1803442798888,-0.33659485488996,-0.39732510861623).unit yolo[268].Anchored=true yolo[268].Right=default.None yolo[268].Top=default.None yolo[268].Front=default.None yolo[268].Left=default.None yolo[268].Bottom=default.None yolo[268].Back=default.None
yolo[269]=new'Brick' yolo[269].Pos=Vector3.new(57, -12.7001076, -40.5) yolo[269].Size=Vector3.new(26, 33, 16) yolo[269].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[269].Quaternion=Quaternion.new(-0.030836120246706,0.030867821930436,0.70641981995108,0.70644697321745).unit yolo[269].Anchored=true yolo[269].Right=default.Universal yolo[269].Top=default.Universal yolo[269].Front=default.Universal yolo[269].Left=default.Universal yolo[269].Bottom=default.Universal yolo[269].Back=default.Universal
yolo[270]=new'Brick' yolo[270].Pos=Vector3.new(111.965637, -3.2000885, -48.9378662) yolo[270].Size=Vector3.new(13, 56, 35) yolo[270].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[270].Quaternion=Quaternion.new(0.24185160190192,0.24186177951891,-0.66442945696911,0.66448791228482).unit yolo[270].Anchored=true yolo[270].Right=default.Universal yolo[270].Top=default.Universal yolo[270].Front=default.Universal yolo[270].Left=default.Universal yolo[270].Bottom=default.Universal yolo[270].Back=default.Universal
yolo[271]=new'Brick' yolo[271].Pos=Vector3.new(128.5, -2.70000005, -9) yolo[271].Size=Vector3.new(13, 34, 42) yolo[271].Colour=Colour4.new(124.00000780821,92.000002115965,70.000003427267,255) yolo[271].Quaternion=Quaternion.new(1,0,0,0).unit yolo[271].Anchored=true yolo[271].Right=default.Universal yolo[271].Top=default.Universal yolo[271].Front=default.Universal yolo[271].Left=default.Universal yolo[271].Bottom=default.Universal yolo[271].Back=default.Universal
yolo[272]=new'Brick' yolo[272].Pos=Vector3.new(-113.5, -11.1000004, 87.5) yolo[272].Size=Vector3.new(1, 11, 1) yolo[272].Colour=Colour4.new(17.000000886619,17.000000886619,17.000000886619,255) yolo[272].Quaternion=Quaternion.new(1,0,0,0).unit yolo[272].Anchored=true yolo[272].Right=default.None yolo[272].Top=default.Studs yolo[272].Front=default.None yolo[272].Left=default.None yolo[272].Bottom=default.Inlet yolo[272].Back=default.None
yolo[273]=new'Brick' yolo[273].Pos=Vector3.new(-113.5, -7.5999999, 84) yolo[273].Size=Vector3.new(1, 4, 6) yolo[273].Colour=Colour4.new(248.00001561642,248.00001561642,248.00001561642,255) yolo[273].Quaternion=Quaternion.new(1,0,0,0).unit yolo[273].Anchored=true yolo[273].Right=default.None yolo[273].Top=default.Studs yolo[273].Front=default.None yolo[273].Left=default.None yolo[273].Bottom=default.Inlet yolo[273].Back=default.None
yolo[274]=new'Brick' yolo[274].Pos=Vector3.new(-53.5, -11.6999998, 22.5) yolo[274].Size=Vector3.new(1, 11, 1) yolo[274].Colour=Colour4.new(17.000000886619,17.000000886619,17.000000886619,255) yolo[274].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,-0).unit yolo[274].Anchored=true yolo[274].Right=default.None yolo[274].Top=default.Studs yolo[274].Front=default.None yolo[274].Left=default.None yolo[274].Bottom=default.Inlet yolo[274].Back=default.None
yolo[275]=new'Brick' yolo[275].Pos=Vector3.new(-57, -8.19999981, 22.5) yolo[275].Size=Vector3.new(1, 4, 6) yolo[275].Colour=Colour4.new(248.00001561642,248.00001561642,248.00001561642,255) yolo[275].Quaternion=Quaternion.new(0.70710678118655,0,0.70710678118655,-0).unit yolo[275].Anchored=true yolo[275].Right=default.None yolo[275].Top=default.Studs yolo[275].Front=default.None yolo[275].Left=default.None yolo[275].Bottom=default.Inlet yolo[275].Back=default.None
yolo[276]=new'Brick' yolo[276].Pos=Vector3.new(18.8786774, 10.7999878, -34.4141846) yolo[276].Size=Vector3.new(1, 11, 1) yolo[276].Colour=Colour4.new(17.000000886619,17.000000886619,17.000000886619,255) yolo[276].Quaternion=Quaternion.new(-0.38267388725682,1.5258609684019e-005,0.92388348080884,1.5258967030571e-005).unit yolo[276].Anchored=true yolo[276].Right=default.None yolo[276].Top=default.Studs yolo[276].Front=default.None yolo[276].Left=default.None yolo[276].Bottom=default.Inlet yolo[276].Back=default.None
yolo[277]=new'Brick' yolo[277].Pos=Vector3.new(21.3535461, 14.2999954, -31.9393311) yolo[277].Size=Vector3.new(1, 4, 6) yolo[277].Colour=Colour4.new(248.00001561642,248.00001561642,248.00001561642,255) yolo[277].Quaternion=Quaternion.new(-0.38267388725682,1.5258609684019e-005,0.92388348080884,1.5258967030571e-005).unit yolo[277].Anchored=true yolo[277].Right=default.None yolo[277].Top=default.Studs yolo[277].Front=default.None yolo[277].Left=default.None yolo[277].Bottom=default.Inlet yolo[277].Back=default.None
--]]
end
