--Tiles By xXxMoNkEyMaNxXx

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

Class=require'lib/Class'
using'Class'
local Vector2=require'class/Vector2'
