--By xXxMoNkEyMaNxXx
--[[
	+x R Blue
	+y U White
	+z F Red
	-x L Green
	-y D Yellow
	-z B Orange
--]]

local function new(size)
	--Data is stored as 6 regular 2D tables which the axes are the next two in the sequence
	--aka [x][y][z],[y][z][-x],[z][-x][-y]
	local cube={pos={0,0,0},quat={1,0,0,0},size=size}
	for colour=1,6 do
		local face={}
		for axis1=1,size do
			local ax1={}
			for axis2=1,size do
				ax1[axis2]=colour--math.random(6)--
			end
			face[axis1]=ax1
		end
		cube[colour]=face
	end
	return cube
end

local function turn(axis,index)
	--
end

return {
	new=new,
	turn=turn,
}
