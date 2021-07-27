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

--using'love'

Class=require'Class'
using'Class'
Vector3=require'Vector3'
Quaternion=require'Quaternion'

local q=Quaternion.new(random()*2-1,random()*2-1,random()*2-1,random()*2-1).unit
local v=Vector3.new(random()*2-1,random()*2-1,random()*2-1)
print(v)
print(q*v*q)
