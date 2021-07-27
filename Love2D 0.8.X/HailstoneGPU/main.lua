--By xXxMoNkEyMaNxXx
local v={love.graphics.getWidth(),love.graphics.getHeight()}
local f={640,480}
local a={v[1]/f[1],v[2]/f[2]}
local cpf=f[1]*f[2]*2--Skip even numbers
local o=cpf--Skip the first frame, it's negligable and n will never reach i when i is 0.

local p=love.graphics.newPixelEffect(love.filesystem.read'GPU.frag')
local send=p.send
local C0,C1={255,255,255,255},{0,0,0,255}
send(p,"C0",C0)
send(p,"C1",C1)
send(p,"r",f)
send(p,"o",o)

local sc=love.graphics.setCanvas
local sp=love.graphics.setPixelEffect
local cap=love.graphics.setCaption
local colour=love.graphics.setColor

local draw=love.graphics.draw
local print=love.graphics.print
local rect=love.graphics.rectangle

local fps=love.timer.getFPS
local tick=love.timer.getMicroTime

local c=love.graphics.newCanvas(unpack(f))

local toggle=true
local init=tick()
function love.draw()
	sc(c)
	sp(p)
	rect("fill",0,0,f[1],f[2])
	sc()
	sp()
	o=o+cpf
	draw(c,0,0,0,a[1],a[2])
	local d=fps()
	if toggle then
		colour(C1)
	else
		colour(C0)
	end
	print("Hailstone series calculated: "..o,0,0)
	print("Calculations per second: "..cpf*d,0,20)
	print("Elapsed time: "..tick()-init,0,40)
	colour(255,255,255,255)
	toggle=not toggle
	cap("Umad? - "..d.." FPS")
	send(p,"o",o)
end
