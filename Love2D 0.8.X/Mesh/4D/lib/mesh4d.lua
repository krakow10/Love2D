local mesh4d={}

local read=love.filesystem.read
local newImage=love.graphics.newImage
function mesh4d.read(fname)
	local obj={}
	local file=read(fname)
	local folder=fname:match'^(.+/).-$'
	for item in file:gmatch'%b<>' do
		local i,v=item:match'^<%s*(%w+)%s*=%s*(.-)%s*>$'
		obj[i]=newImage(folder..v)
	end
	return obj
end

local window={0,0,love.graphics.getWidth(),love.graphics.getHeight()}
local shader=love.graphics.newPixelEffect(read'lib/view.frag')
local send=shader.send
send(shader,"Zoom",1)
send(shader,"Window",window)
local rect=love.graphics.rectangle
local setCanvas=love.graphics.setCanvas
local setEffect=love.graphics.setPixelEffect
function mesh4d.render(obj,meshnum,offset,matrix)--,canvas
	send(shader,"Row",meshnum/obj.Pairs:getHeight())
	send(shader,"Textures",obj.Textures)
	send(shader,"Map",obj.TextureMap)
	send(shader,"Vertices",obj.Vertices)
	send(shader,"Pairs",obj.Pairs)
	send(shader,"Prisms",obj.Prisms)
	send(shader,"NPrisms",obj.Prisms:getWidth())
	send(shader,"Offset",offset)
	send(shader,"Matrix",matrix)

	--setCanvas(canvas)
	setEffect(shader)
	rect("fill",window[1],window[2],window[3],window[4])
	setEffect()
	--setCanvas()
end

function mesh4d.updateCamera(offset,matrix)
	send(shader,"CameraOffset",offset)
	send(shader,"CameraMatrix",matrix)
end

function mesh4d.setWindow(offset,size)
	window={offset[1],offset[2],size[1],size[2]}
	send(shader,"Window",window)
end

function mesh4d.setZoom(z)
	send(shader,"Zoom",z)
end

_G.mesh4d=mesh4d
