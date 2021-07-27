--By xXxMoNkEyMaNxXx
local tick=love.timer.getMicroTime

local tau=2*math.pi
local sqrt=math.sqrt
local cos,sin=math.cos,math.sin
local floor=math.floor
local max,min=math.max,math.min
local abs=math.abs
local log=math.log
local exp=math.exp
local format=string.format

local range1,range2=log(20),log(20000)
local rangeD=range2-range1

local size1,size2=1024,192
local fps=29.4


local line=love.graphics.line
local rect=love.graphics.rectangle
local colour=love.graphics.setColor
local newFile=love.filesystem.newFile

local img=love.graphics.newCanvas(size1,size2)
love.graphics.setCanvas(img)


local rawData=love.sound.newSoundData'sound.ogg'
local sample=rawData.getSample

local dataSize=rawData:getSize()
local dataRate=rawData:getSampleRate()
local bps=rawData:getBits()/8*rawData:getChannels()

local data={}
for x=1,dataSize/bps do
	data[x]=sample(rawData,x-1)
end

local sec=#data/dataRate
print(sec)
local sf=dataRate/fps--Samples/frame

local function presence(hz,s0,sn)
	local r,i=0,0
	for x=s0,s0+sn-1 do
		local dx=data[x+1]
		local t=-tau*hz*(x-s0)/sn
		r,i=r+dx*cos(t),i+dx*sin(t)
	end
	return sqrt(r*r+i*i)/sn
end

local vmin=0
local vmax=0.1


local t0=tick()
local s0=0
for f=1,min(100,floor(#data/sf)) do
	local s1=floor(f*sf+0.5)

	local len={}
	for x=0,size1-1 do
		local l=presence(exp(range1+rangeD*x/size1),s0,s1-s0)
		len[x]=l
		vmax=max(vmax,l)
	end

	local l1={}
	for i=0,size1-1 do
		l1[2*i+1],l1[2*i+2]=i,(size2-1)*(1-(len[i]-vmin)/(vmax-vmin))
	end

	colour(0,255,0,255)
	line(l1)

	local file=newFile("F"..format("%.4i",f)..".png")
	file:open'w'
	img:getImageData():encode(file)
	file:close()

	colour(255,255,255,255)
	rect("fill",0,0,size1,size2)
	s0=s1
end

local t1=tick()

print("Elapsed",t1-t0)

print(vmax)

love.event.quit()
