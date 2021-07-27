--Not a module, must be run as a plugin in roblox, then directly planted in the load function.

local next=next
local max=math.max
local sqrt=math.sqrt
local concat=table.concat
local function QuaternionFromCFrame(cf)
	local mx,my,mz,m00,m01,m02,m10,m11,m12,m20,m21,m22=cf:components()
	local trace=m00+m11+m22
	local w,x,y,z
	if trace>0 then
		local s=sqrt(1+trace)
		local recip=0.5/s
		x,y,z,w=(m21-m12)*recip,(m02-m20)*recip,(m10-m01)*recip,s*0.5
	else
		local big=max(m00,m11,m22)
		if big==m00 then
			local s=sqrt(m00-m11-m22+1)
			local recip=0.5/s
			x,y,z,w=0.5*s,(m10+m01)*recip,(m20+m02)*recip,(m21-m12)*recip
		elseif big==m11 then
			local s=sqrt(m11-m22-m00+1)
			local recip=0.5/s
			x,y,z,w=(m01+m10)*recip,0.5*s,(m21+m12)*recip,(m02-m20)*recip
		elseif big==m22 then
			local s=sqrt(m22-m00-m11+1)
			local recip=0.5/s
			x,y,z,w=(m02+m20)*recip,(m12+m21)*recip,0.5*s,(m10-m01)*recip
		end
	end
	return w,x,y,z
end
--[[
local function QuaternionFromCFrame(cf)
	local mx,my,mz,m00,m01,m02,m10,m11,m12,m20,m21,m22=cf:components()
	local t = m00+m11+m22
	local r = sqrt(1+t)
	local s = 0.5/r
	return 0.5*r,(m21-m12)*s,(m02-m20)*s,(m10-m01)*s
end
--]]
local function getSurface(surface)
	if surface==Enum.SurfaceType.Studs then
		return "Studs"
	elseif surface==Enum.SurfaceType.Glue then
		return "Glue"
	elseif surface==Enum.SurfaceType.Inlet then
		return "Inlet"
	elseif surface==Enum.SurfaceType.Universal then
		return "Universal"
	elseif surface==Enum.SurfaceType.Weld then
		return "Weld"
	else
		return "None"
	end
end

local i=0
local spew=function(part)
	if part.Transparency<1 then
		i=i+1
		local I="yolo["..i.."]"
		local c=part.BrickColor.Color
		print(concat{
		I,"=new'Brick' ",
		I,".Pos=Vector3.new(",tostring(part.Position),") ",
		I,".Size=Vector3.new(",tostring(part.Size),") ",
		I,".Colour=Colour4.new(",(c.r*255),",",(c.g*255),",",(c.b*255),",",((1-part.Transparency)*255),") ",
		I,".Quaternion=Quaternion.new(",concat({QuaternionFromCFrame(part.CFrame)},","),").unit ",
		I,".Anchored=true ",
		I,".Right=default.",getSurface(part.RightSurface)," ",
		I,".Top=default.",getSurface(part.TopSurface)," ",
		I,".Front=default.",getSurface(part.FrontSurface)," ",
		I,".Left=default.",getSurface(part.LeftSurface)," ",
		I,".Bottom=default.",getSurface(part.BottomSurface)," ",
		I,".Back=default.",getSurface(part.BackSurface)," "})
		if i%250==249 then
			wait(10)
		else
			wait()
		end
	end
end

local recurse
recurse=function(obj)
	if obj.ClassName=="Part" then
		spew(obj)
	end
	for _,child in next,obj:GetChildren() do
		recurse(child)
	end
end
print'local yolo={}'
recurse(workspace)
