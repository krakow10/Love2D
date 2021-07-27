--By xXxMoNkEyMaNxXx
local tick=love.timer.getMicroTime

local t0=tick()

local tau=2*math.pi
local sqrt=math.sqrt
local cos,sin=math.cos,math.sin
local floor=math.floor
local max,min=math.max,math.min
local abs=math.abs
local log=math.log
local exp=math.exp

local sub=string.sub
local byte=string.byte
local char=string.char


local rawData=love.sound.newSoundData'sound.ogg'
local getSample=rawData.getSample

local dataSize=rawData:getSize()
local dataRate=rawData:getSampleRate()
local sizerate=dataSize*dataRate

local t1=tick()

local data={}
for x=1,dataSize do
	data[x]=getSample(rawData,x-1)
end

local t2=tick()

local function ft(hz,f_x,x)
	local t=-tau*hz*x
	return f_x*cos(t),f_x*sin(t)
end

local function presence(hz)
	local r,i=0,0
	for x=0,dataSize-1 do
		local r0,i0=ft(hz,data[x+1],x/dataSize)
		r,i=r+r0,i+i0
	end
	return r/sizerate,i/sizerate
end

local range1,range2=log(20),log(20000)
local rangeD=range2-range1

local size1,size2=2048,384

local re={}
local im={}
local le={}
local vmin=math.huge
local vmax=-math.huge

local t3=tick()

for x=0,size1-1 do
	local r,i=presence(exp(range1+rangeD*x/size1))
	local len=sqrt(r*r+i*i)
	re[x],im[x],le[x]=r,i,len
	vmax=max(vmax,len)
	vmin=min(vmin,r,i)
end

local t4=tick()

local line1={}
local line2={}
local line3={}
for i=0,size1-1 do
	line1[2*i+1],line1[2*i+2]=i,(size2-1)*(1-(re[i]-vmin)/(vmax-vmin))
	line2[2*i+1],line2[2*i+2]=i,(size2-1)*(1-(im[i]-vmin)/(vmax-vmin))
	line3[2*i+1],line3[2*i+2]=i,(size2-1)*(1-(le[i]-vmin)/(vmax-vmin))
end

local t5=tick()

local colour=love.graphics.setColor
local line=love.graphics.line
local img=love.graphics.newCanvas(size1,size2)
love.graphics.setCanvas(img)
colour(219,133,29,255)
line(line1)
colour(37,25,187,255)
line(line2)
colour(0,255,0,255)
line(line3)

local file=love.filesystem.newFile'Frequency.png'
file:open'w'
img:getImageData():encode(file)
file:close()

local t6=tick()

print("Initialization",t1-t0)
print("Data indexing",t2-t1)
print("Preparation",t3-t2)
print("Fourier transf.",t4-t3)
print("Linear encoding",t5-t4)
print("Exporting",t6-t5)
print("Min/max",vmin,vmax)

love.event.quit()
