local socket=require'socket'

local select=select

local min=math.min
local floor=math.floor
local random=math.random

local concat=table.concat
local insert=table.insert

local print=love.graphics.print
local rect=love.graphics.rectangle
local setColor=love.graphics.setColor

local isKey=love.keyboard.isDown

local getClipboardText=love.system.getClipboardText

local hasFocus=love.window.hasFocus

local w,h=love.window.getDimensions()

local lineHeight=17

beep=love.audio.newSource("newmessage.mp3","static")
newmessage={
love.audio.newSource("newmessage1.mp3","static"),
love.audio.newSource("newmessage2.mp3","static"),
love.audio.newSource("newmessage3.mp3","static"),
love.audio.newSource("newmessage4.mp3","static"),
love.audio.newSource("newmessage5.mp3","static"),
love.audio.newSource("newmessage6.mp3","static"),
love.audio.newSource("newmessage7.mp3","static"),
love.audio.newSource("newmessage8.mp3","static"),
love.audio.newSource("newmessage9.mp3","static"),
love.audio.newSource("newmessage10.mp3","static"),
love.audio.newSource("newmessage11.mp3","static"),
love.audio.newSource("newmessage12.mp3","static"),
love.audio.newSource("newmessage13.mp3","static"),
love.audio.newSource("newmessage14.mp3","static"),
love.audio.newSource("newmessage15.mp3","static"),
love.audio.newSource("newmessage16.mp3","static"),
love.audio.newSource("newmessage17.mp3","static"),
}

local connected=false
local ip,port="localhost",25565
local output={"Say '/name name' to name yourself.","Say '/connect' to connect to "..ip..":"..port.."."}

local tcp=socket.tcp()

local function totext(...)
    local tbl={}
    for i=1,select("#",...) do
       tbl[i]=tostring(select(i,...))
    end
    return concat(tbl,"; ")
end

local name="anonymous"
local text=""
function love.textinput(c)
	text=text..c
end

function love.keypressed(k)
	if k=="return" then
        local newip,newport=text:match("^/ip (%d?%d?%d%.%d?%d?%d%.%d?%d?%d%.%d?%d?%d):?(%d*)$")
        if newip then
            ip,port=newip,tonumber(newport) or port
            insert(output,1,"You have changed the server ip.")
            insert(output,1,"Say '/connect' to connect to "..ip..":"..port..".")
        elseif text=="/connect" then
            if connected then
                tcp:close()
                tcp=socket.tcp()
            end
            tcp:settimeout(3)
            insert(output,1,"Connecting...")
            connected=tcp:connect(ip,port)==1
            if not connected then
                insert(output,1,"Connection failed")
            end
            tcp:settimeout(0.01)
		elseif text:sub(1,6)=="/name " then
			local name0=name
			name=text:sub(7)
			if connected then
				tcp:send(name0.." has changed their name to "..name)
			end
        else
			if connected then
				tcp:send(name..": "..text)
			end
        end
        text=""
    elseif k=="backspace" then
        text=text:sub(1,-2)
	elseif k=="v" and isKey'lctrl' then
		text=text..getClipboardText()
	end
end

function love.draw()
	setColor(255,255,255,255)
    print("server ip: "..ip,0,0)
    print("port: "..port,0,lineHeight)
	for i=1,min(#output,floor(h/lineHeight)-3) do
		print(output[i],0,h-(i+1)*lineHeight)
	end
	rect("fill",0,h-lineHeight,w,lineHeight)
	setColor(0,0,0,255)
	print(text,0,h-lineHeight)
end

function love.update()
    if connected then
        local _,_,rcv=tcp:receive()
        if rcv and #rcv>0 then
            insert(output,1,rcv)
			if hasFocus() then
				beep:play()
			else
				newmessage[random(#newmessage)]:play()
			end
        end
    end
end

function love.resize(x,y)
	w,h=x,y
end

function love.quit()
	tcp:close()
end
