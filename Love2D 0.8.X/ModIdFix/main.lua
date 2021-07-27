local isDir=love.filesystem.isDirectory
local isFile=love.filesystem.isFile
local newFile=love.filesystem.newFile
local iterate=love.filesystem.enumerate
local read,write=love.filesystem.read,love.filesystem.write

local time=love.timer.getTime
local insert=table.insert
local concat=table.concat
local min=math.min

local printing={}
local uprint=function(...)
	local S=""
	for _,s in next,{...} do
		S=S..tostring(s)
	end
	local final=S:gsub("%s+"," ")
	insert(printing,1,final)
end

local id_list=setmetatable({},{
	__call=function(list)
		local v
		for i,_ in ipairs(list) do
			v=i
		end
		return v+1
	end
})

local function addIds(query)
	for low,high in query:gmatch'(%d+)%-(%d+)' do
		for i=low,high do
			id_list[i]=true
		end
	end
end
local function fix(text)
	local numbadids=0
	local explanation={}
	if text then
		local start,ids,finish=text:match'block%s*()(%b{})()'
		local newids=""
		if ids then
			for yolo,idstring in ids:gmatch'(%s+[%w%.]+=)(%d+)' do
				local id=tonumber(idstring)
				if id then
					if id_list[id] then
						local newid=id_list()
						--uprint("Bad id '",id,"' changed to '",newid,"'.")
						explanation[#explanation+1]=id.."->"..newid
						id=newid
						numbadids=numbadids+1
					end
					id_list[id]=true
					newids=newids..yolo..id
				else
					newids=newids..yolo
				end
			end
			if numbadids==0 then
				return false
			else
				return text:sub(1,start)..newids.."\n"..text:sub(finish-1),numbadids,concat(explanation," ")
			end
		else
			return false
		end
	end
end
local total=0
love.filesystem.setIdentity'config'
local save=love.filesystem.getSaveDirectory()
local recurse
recurse=function(folder)
	--uprint(folder)
	for _,fname in next,iterate(folder) do
		--uprint(fname)
		local dir=folder.."/"..fname
		local ext=fname:match'%.%w+$'
		if isFile(dir) and ext==".cfg" or ext==".conf" then
			--uprint("Fixing "..fname)
			local file=newFile(dir)
			local fixed,num,expl
			if file:open'r' then
				fixed,num,expl=fix(file:read())
				file:close()
			else
				uprint'Failed to read'
			end
			if fixed and file:open'w' then
				file:write(fixed)
				file:close()
				uprint("Fixed ",num," collision",num==1 and "" or "s"," in ",fname,": ",expl)
				total=total+num
			elseif fixed==false then
				--uprint'No collisions'
			else
				uprint'Failed to write'
			end
		elseif isDir(dir) then
			recurse(dir)
		end
	end
end
local init=time()
uprint("Recursing ",save)
addIds[[1-157 256-407 2256-2267]]
recurse''
uprint("Done! There were a total of ",total," collision",total==1 and "" or "s",". [",time()-init,"s]")

function love.draw()
	local max=min(#printing,25)
	for i=1,max do
		love.graphics.print(printing[i],0,20*(max-i))
	end
end
