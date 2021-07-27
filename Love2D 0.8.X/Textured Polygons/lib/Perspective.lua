--By xXxMoNkEyMaNxXx
local glsl=love.graphics.newPixelEffect(love.filesystem.read'Texture.glsl')
local gl_send=glsl.send
local q=love.graphics.quad
local setEffect=love.graphics.setPixelEffect
gl_send(glsl,"SIZEY",love.graphics.getHeight())--So annoying

module(...)
function preload(loadup)
	if loadup then
		setEffect(glsl)
	else
		setEffect()
	end
end
function quad(img,v1,v2,v3,v4)
	gl_send(glsl,"img",img)
	gl_send(glsl,"v1",v1)
	gl_send(glsl,"v2",v2)
	gl_send(glsl,"v3",v3)
	gl_send(glsl,"v4",v4)
	q("fill",v1[1],v1[2],v2[1],v2[2],v3[1],v3[2],v4[1],v4[2])
end
