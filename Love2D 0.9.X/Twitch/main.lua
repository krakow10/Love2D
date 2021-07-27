local socket=require'socket'

local tcp=socket.tcp()

tcp:connect("irc.twitch.tv",6667)

tcp:send("PASS oauth:rlerlu8w9aqeoyj0zovhst6xl02mcbe")
tcp:send("NICK Krakow10")

local stuff={}

function love.draw()
	for i=1,math.min(#stuff,100) do
		love.graphics.print(stuff[i],0,0)
	end
end

local t_acc=0
local t_trigger=0.2
function love.update(dt)
	t_acc=t_acc+dt
	if t_acc>t_trigger then
		t_acc=t_acc-t_trigger
		local rcv=tcp:receive()
		stuff[#stuff+1]=rcv
		print(rcv)
	end
end
