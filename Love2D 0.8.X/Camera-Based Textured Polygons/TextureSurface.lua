--By xXxMoNkEyMaNxXx

local unpack=unpack

local abs=math.abs
local sqrt=math.sqrt
local sin,cos=math.sin,math.cos

local quad=love.graphics.quad
local poly=love.graphics.polygon
local setEffect=love.graphics.setPixelEffect
local glsl=love.graphics.newPixelEffect(love.filesystem.read'Texture.glsl')
local gl_send=glsl.send

local PRE_COMPUTE={love.graphics.getWidth(),love.graphics.getHeight()}

module(...)

local data={}
local send=function(index,value)
	data[index]=value
	gl_send(glsl,index,value)
end

function QuaternionToMatrix(q)
	local w,x,y,z=q[4],q[1],q[2],q[3]
	return
	{1-2*y^2-2*z^2,2*x*y+2*w*z,2*x*z-2*w*y},
	{2*x*y-2*w*z,1-2*x^2-2*z^2,2*y*z+2*w*x},
	{2*x*z+2*w*y,2*y*z-2*w*x,1-2*x^2-2*y^2}
end

--[['prepare' - Prepare an image to be rendered to a surface.
	'img'=Image;						The image you want to render onto the surface.
	'sfc_centre'={x,y,z};				The center point of the surface.
	'sfc_norm'={x,y,z};					A unit vector perpendicular to the surface.
	'sfc_right_dir'={x,y,z};			A unit vector contained in the surface that will represent the X axis on the image.
	'sfc_up_dir'={x,y,z};				A unit vector contained in the surface that will represent the Y axis on the image.
	'repeat_'={x,y};					Repeat the texture every {x,y} units.
	(Set to the size of the surface for one appearance.)
--]]

function prepare(img,repeat_,sfc_centre,sfc_right_dir,sfc_up_dir,sfc_norm)
	send("img",img)
	send("p0",sfc_centre)
	send("pp1",sfc_right_dir)
	send("pp2",sfc_up_dir)
	send("n",sfc_norm)
	send("rep",{repeat_[1]*2,repeat_[2]*2})
end

--[['setCamera' - Sets the camera's position and rotation in one of three ways:
	'pos'={x,y,z};		Only change position.
	nil;
	nil;

	'pos'={x,y,z};		Position of camera.
	'quat'={x,y,z,w};	Quaternion. Note that w is after x,y, and z.
	'angle'=nil;		The quaternion already describes the rotation.

	or

	'pos'={x,y,z};		Position of camera.
	'axis'={x,y,z};		Direction the camera points.
	'angle'=radians;	Rotate the camera on the specified axis.
--]]
function setCamera(pos,quat,angle)
	send("p",pos)
	if quat then
		if angle then
			local mul=sin(angle/2)
			local w,x,y,z=cos(angle/2),quat[1]*mul,quat[2]*mul,quat[3]*mul
			local mag=sqrt(w^2+x^2+y^2+z^2)
			local q={x/mag,y/mag,z/mag,w/mag}
			send("q",q)
			data.mat={QuaternionToMatrix(q)}
		else
			send("q",quat)
			data.mat={QuaternionToMatrix(quat)}
		end
	end
end

--[['setSizeFOV' - arguments
viewsize={love.graphics.getWidth(),love.graphics.getHeight()}

fov:
	The field of view of the Camera.
	This can be calculated as tan(Y-visibility/2),
	where Y-visibility is the angle between the direction at the top of the screen,
	the camera, and the direction at the bottom of the screen. (In radians)
--]]
function setFOV(fov,viewsize)
	send("fov",fov)
	if viewsize then
		send("vs",viewsize)
	end
end


--Use this function like love.graphics.setPixelEffect(enable), but it only enables this effect.
local loaded=false
function preload(loadup)--True to set, false to unset...
	if loadup then
		setEffect(glsl)
	else
		setEffect()
	end
	loaded=loadup and true or false--Convert to bool (Actually not necessary, but it is most likely easier to compute later if-statements at high speed.)
end

--(vs.x+relpos.x/relpos.z*vs.y*fov)/2, (vs.y-vs.y*relpos.y/relpos.z*fov)/2

function worldToScreen(mat,pos)
	--pos-cross(2*q.xyz,q.w*pos-cross(q.xyz,pos))
	--local relpos={pos[1]*data.pp1[1]+pos[2]*data.pp2[1]+pos[3]*data.n[1],pos[1]*data.pp1[2]+pos[2]*data.pp2[2]+pos[3]*data.n[2],pos[1]*data.pp1[3]+pos[2]*data.pp2[3]+pos[3]*data.n[3]}
	local relz=abs(pos[1]*mat[1][3]+pos[2]*mat[2][3]+pos[3]*mat[3][3])
	return
	(data.vs[1] + (pos[1]*mat[1][1]+pos[2]*mat[2][1]+pos[3]*mat[3][1]) * data.vs[2]*data.fov/relz)/2,
	(data.vs[2] - (pos[1]*mat[1][2]+pos[2]*mat[2][2]+pos[3]*mat[3][2]) * data.vs[2]*data.fov/relz)/2
end
--[[
local function qmul(q,v)
	return
end
local function plane(norm,rel,dir)
	return dot(rel,norm)/dot(dir,norm)
end
function screenToWorld(pos)
	--qmul(q,v)=v+cross(2*q.xyz,cross(q.xyz,v)+q.w*v)
	--d=qmul(q,pos)
	pos+cross(2*data.q[1],2*data.q[2],2*data.q[3],cross(q.xyz,v)+q.w*v)
	--h=p-d*plane(n,p-p0,d)
	--diff=h-p0

end
local function mul(mat,v)
	return {v[1]*mat[1][1]+v[2]*mat[2][1]+v[3]*mat[3][1], v[1]*mat[1][2]+v[2]*mat[2][2]+v[3]*mat[3][2], v[1]*mat[1][3]+v[2]*mat[2][3]+v[3]*mat[3][3]}
end
--]]
function vertices(size)--compute vertices if size is {x,y}
	local v1x,v1y=worldToScreen(data.mat,{data.p[1]-data.p0[1]+size[1]*data.pp1[1]+size[2]*data.pp2[1], data.p[2]-data.p0[2]+size[1]*data.pp1[2]+size[2]*data.pp2[2], data.p[3]-data.p0[3]+size[1]*data.pp1[3]+size[2]*data.pp2[3]})
	local v2x,v2y=worldToScreen(data.mat,{data.p[1]-data.p0[1]+size[1]*data.pp1[1]-size[2]*data.pp2[1], data.p[2]-data.p0[2]+size[1]*data.pp1[2]-size[2]*data.pp2[2], data.p[3]-data.p0[3]+size[1]*data.pp1[3]-size[2]*data.pp2[3]})
	local v3x,v3y=worldToScreen(data.mat,{data.p[1]-data.p0[1]-size[1]*data.pp1[1]-size[2]*data.pp2[1], data.p[2]-data.p0[2]-size[1]*data.pp1[2]-size[2]*data.pp2[2], data.p[3]-data.p0[3]-size[1]*data.pp1[3]-size[2]*data.pp2[3]})
	local v4x,v4y=worldToScreen(data.mat,{data.p[1]-data.p0[1]-size[1]*data.pp1[1]+size[2]*data.pp2[1], data.p[2]-data.p0[2]-size[1]*data.pp1[2]+size[2]*data.pp2[2], data.p[3]-data.p0[3]-size[1]*data.pp1[3]+size[2]*data.pp2[3]})
	return v1x,v1y,v2x,v2y,v3x,v3y,v4x,v4y
end
--[['render' - Use to prepare, set effect, and render all in one go.
	I should think that most people wouldn't need this, but it could be useful to do just one texture
	when using other pixel effects or no pixel effects on other things without unloading.
	Comment it out/remove it if you want.
--]]
local prepare,vertices=prepare,vertices
function render(img,prep,size,once)
	prepare(img,unpack(prep))
	if once then
		setEffect(glsl)
	elseif not loaded then
		setEffect(glsl)
	end
	quad("fill",vertices(size))
	if once then
		setEffect()
	end
end
-----------------------------------------------------------

--auto setup
setFOV(1,PRE_COMPUTE)
setCamera({0,0,0},{0,0,0,1})
