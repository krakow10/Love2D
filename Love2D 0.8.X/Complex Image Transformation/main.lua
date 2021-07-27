--By xXxMoNkEyMaNxXx

--Settings
local file="img/nature.jpg"
local view=5
local outx=1680
local eq=
[[
	//return Cpow(one+i,z);
	//return Catan(zeta(z),fac(z));
	//return Cpow(z,Carg(z));
	//return Catanh(z);
	//return Cpow(z,z);
	//return Cpow(z,3);
	//return Cmul(z,z);
	//return zeta(z);
	return fac(z);
]]

--Set up image and aspects
local input=love.graphics.newImage(file)
local iwh={input:getWidth(),input:getHeight()}
local owh={outx,outx*iwh[2]/iwh[1]}
local window={2*view,2*view*iwh[2]/iwh[1]}

--Set up shader
local code=love.filesystem.read'glsl/Draw.glsl':gsub("&EQ&",eq)
local shader=love.graphics.newPixelEffect(code)
love.graphics.setPixelEffect(shader)
shader:send("window",window)
shader:send("outsize",owh)

--Render image with GPU
local output=love.graphics.newCanvas(owh[1],owh[2])
output:renderTo(function()
	love.graphics.draw(input,0,0,0,owh[1]/iwh[1],owh[2]/iwh[2])
end)

--Find first unused filename
love.filesystem.setIdentity'Results'
local exists=love.filesystem.exists
local n=1
while exists("Output"..n..".png") do n=n+1 end

--Export to png
local fname="Output"..n..".png"
local outfile=love.filesystem.newFile(fname)
outfile:open'w'
output:getImageData():encode(fname)
outfile:close()
love.event.quit()
