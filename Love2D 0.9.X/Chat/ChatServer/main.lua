local socket=require'socket'

local select=select

local min=math.min
local floor=math.floor

local concat=table.concat
local insert=table.insert
local remove=table.remove

local print=love.graphics.print

local w,h=love.window.getDimensions()

local lineHeight=17
local maxClients=100
local output={"Waiting for connections..."}

local function totext(...)
    local tbl={}
    for i=1,select("#",...) do
       tbl[i]=tostring(select(i,...))
    end
    return concat(tbl,"; ")
end

local tcp=socket.tcp()
tcp:bind("*",25565)
tcp:listen(maxClients)
local ip,port=tcp:getsockname()
insert(output,1,totext(ip,port))
tcp:settimeout(0.01)

local clients={}
function love.draw()
    print("local ip: "..ip,0,0)
    print("port: "..port,0,lineHeight)
	print("clients: "..#clients.."/"..maxClients,0,2*lineHeight)
	for i=1,min(#output,floor(h/lineHeight)-3) do
		print(output[i],0,h-i*lineHeight)
	end
end

function love.update(dt)
	local client=tcp:accept()
	local newContent={}
	if client then
		clients[#clients+1]=client
		client:send("Connected")
		local cip,cport=client:getpeername()
		local msg=cip..":"..cport.." connected"
		insert(output,1,msg)
        newContent[#newContent+1]=msg
	end
	for i=#clients,1,-1 do
		clients[i]:settimeout(0.01)
		local _,err,rcv=clients[i]:receive()
		if rcv and #rcv>0 then
			newContent[#newContent+1]=rcv
			--insert(output,1,rcv)
		end
        if err=="closed" then
            local cip,cport=clients[i]:getpeername()
            local msg=cip..":"..cport.." disconnected"
            insert(newContent,1,msg)
			insert(output,1,msg)
            remove(clients,i)
        end
	end
	for i=1,#newContent do
        local msg=newContent[i]
		for i=1,#clients do
			clients[i]:settimeout()
			clients[i]:send(msg)
		end
	end
end

function love.resize(x,y)
	w,h=x,y
end

function love.quit()
	tcp:close()
end
