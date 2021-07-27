--By xXxMoNkEyMaNxXx
local type=type
local pcall=pcall
local unpack=unpack

local ld=love.filesystem.load

local loader={}

function loader.load(fname)
	local ran,f=pcall(ld,fname)
	if ran then
		return f
	else
		print(f)
	end
end

function loader.run(program)
	if type(program)=="function" then
		local ret={pcall(program)}
		if ret[1] then
			return unpack(ret,2)
		else
			print(ret[2])
		end
	else
		print'No valid program to run'
	end
end

function loader.open(fname)
	return loader.run(loader.load(fname))
end

_G.loader=loader
return loader
