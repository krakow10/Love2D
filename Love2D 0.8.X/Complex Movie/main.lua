--By xXxMoNkEyMaNxXx
local id=love.filesystem.setIdentity
local exists=love.filesystem.exists
local newFile=love.filesystem.newFile
local settings=io.open("options/settings.lua","r")
if settings then
	local func=loadstring(settings:read'*a')
	if func then
		func()
	end
	settings:close()
end

--Settings
local file=image or "nature.jpg"
local out=resolution or {640,480}
local fps=tonumber(fps) or 30
local start=start or 1
local length=tonumber(duration) or 4
local view=tonumber(view) or 2
local nframes=fps*length
local operation=io.open("options/equation.glsl","r")
if operation then
	equation=operation:read'*a'
	operation:close()
end
eq=equation or
[[
	vec2 c=rect(t/10,t);
	return Cpow(c,z);
]]
--z is the position on the complex plane
--t is time in seconds since the beginning of the video
--the result is where on the image to map to

--More settings
local folder="Movie"
local framen="Frame%04i.png"
local frameb="Frame%04d.png"

id'Images'
local input=love.graphics.newImage(file)
id(folder)
--Set up image and aspects
local iwh={input:getWidth(),input:getHeight()}
local owh={math.min(1,out[2]/out[1]*iwh[1]/iwh[2]),math.min(1,out[1]/out[2]*iwh[2]/iwh[1])}
local window={2*view,2*view*iwh[2]/iwh[1]}

--Setup shader
local setEffect=love.graphics.setPixelEffect
local code=love.filesystem.read'Render.glsl':gsub("&EQ&",eq)
local shader=love.graphics.newPixelEffect(code)
shader:send("img",input)
shader:send("relsize",owh)
shader:send("outsize",out)
shader:send("window",window)

--Find first unused folder name
local n=0
do
	local num=io.open("options/file","r")
	n=num:read'*n' or n
	num:close()
	num=nil
end

local frame=start
local screen={love.graphics.getWidth(),love.graphics.getHeight()}
local swh={math.min(math.max(1,screen[1]/out[1]),screen[2]/out[2]),math.min(math.max(1,screen[2]/out[2]),screen[1]/out[1])}
local concat=table.concat
local format=string.format
local draw=love.graphics.draw
local rect=love.graphics.rectangle
local setc=love.graphics.setCaption
local setCanvas=love.graphics.setCanvas
local output=love.graphics.newCanvas(out[1],out[2])

--Render a frame

function love.draw()
	if frame<=nframes then
		setc("Generating... "..frame.."/"..nframes.." - "..format("%.2f",frame/nframes*100).."%")

		--Render image with GPU
		shader:send("time",frame/fps)
		output:clear()
		setCanvas(output)
		setEffect(shader)
		rect("fill",0,0,out[1],out[2])
		setCanvas()
		setEffect()
		draw(output,screen[1]/2,screen[2]/2,0,swh[1],swh[2],out[1]/2,out[2]/2)

		--Export to png
		local fname=format(framen,frame)
		local outfile=newFile(fname)
		outfile:open'w'
		output:getImageData():encode(fname)
		outfile:close()
		outfile=nil
		frame=frame+1
	else
		setc'Rendering...'
	end
end
--[[
local wait=love.timer.sleep
for f=start,nframes do
	render(f)
	wait(0.001)
end
--]]
function love.update()
	if frame>nframes then
		os.execute(concat{"ffmpeg.exe -i ",format("%q",concat{love.filesystem.getSaveDirectory(),"/",frameb})," -r ",30," -vframes ",math.floor(nframes)," -b:v 45000k -y ",format("%q",concat{love.filesystem.getWorkingDirectory(),"/Movie",n,".avi"})})
		id''
		do
			local num=io.open("options/file","w")
			num:write(tonumber(n+1))
			num:close()
			num=nil
		end
		love.event.quit()
	end
end

