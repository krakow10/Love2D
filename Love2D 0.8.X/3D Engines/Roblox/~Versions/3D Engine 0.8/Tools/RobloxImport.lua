--Not a module, must be run as a plugin in roblox, then directly planted in the load function.

local next=next
local max=math.max
local sqrt=math.sqrt
local concat=table.concat
--[[
local function QuaternionFromCFrame(cf)
	local mx,my,mz,m00,m01,m02,m10,m11,m12,m20,m21,m22=cf:components()
	local trace=m00+m11+m22
	if trace>0 then
		local s=sqrt(1+trace)
		local recip=0.5/s
		return (m21-m12)*recip,(m02-m20)*recip,(m10-m01)*recip,s*0.5
	else
		local big=max(m00,m11,m22)
		if big==m00 then
			local s=sqrt(m00-m11-m22+1)
			local recip=0.5/s
			return 0.5*s,(m10+m01)*recip,(m20+m02)*recip,(m21-m12)*recip
		elseif big==m11 then
			local s=sqrt(m11-m22-m00+1)
			local recip=0.5/s
			return (m01+m10)*recip,0.5*s,(m21+m12)*recip,(m02-m20)*recip
		elseif big==m22 then
			local s=sqrt(m22-m00-m11+1)
			local recip=0.5/s
			return (m02+m20)*recip,(m12+m21)*recip,0.5*s,(m10-m01)*recip
		end
	end
end
--]]
local function QuaternionFromCFrame(cf)
	local mx,my,mz,m00,m01,m02,m10,m11,m12,m20,m21,m22=cf:components()
	local t = m00+m11+m22
	local r = sqrt(1+t)
	local s = 0.5/r
	return 0.5*r,(m21-m12)*s,(m02-m20)*s,(m10-m01)*s
end
local i=0
local spew=function(part)
	if part.Transparency<1 then
		i=i+1
		local I="yolo["..i.."]"
		local c=part.BrickColor.Color
		print(concat{I,"=new'Brick' ",I,".Pos=Vector3.new(",tostring(part.Position),") ",I,".Size=Vector3.new(",tostring(part.Size),") ",I,".Colour=Colour4.new(",(c.r*255),",",(c.g*255),",",(c.b*255),",",((1-part.Transparency)*255),") ",I,".Quaternion=Quaternion.new(",concat({QuaternionFromCFrame(part.CFrame)},","),").unit ",I,".Anchored=true"})
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
