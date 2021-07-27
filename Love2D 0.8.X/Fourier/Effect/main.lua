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
local modf=math.modf

local char=string.char

local range1,range2=20,20000
local rangeD=range2-range1

local acc=1000

local newFile=love.filesystem.newFile

local rawData=love.sound.newSoundData'sound.ogg'
local getSample=rawData.getSample

local dataSize=rawData:getSize()
local dataRate=rawData:getSampleRate()
local bps=rawData:getChannels()*rawData:getBits()/8

local data={}
for x=1,dataSize/bps do
	data[x]=getSample(rawData,x-1)
end
local Ndata=#data

local function ft(hz)
	local r,i=0,0
	for x=1,Ndata do
		local dx=data[x]
		local t=-tau*hz*(x-1)/Ndata
		r,i=r+dx*cos(t),i+dx*sin(t)
	end
	return r/Ndata,i/Ndata
end

local t0=tick()

local re={}
local im={}
for x=1,acc do
	re[x],im[x]=ft(range1+rangeD*x/acc)
end

local t1=tick()

local function cft(hz)
	local r,i=0,0
	for x=1,acc do
		local rx,ix=re[x],im[x]
		local t=tau*hz*(x-1)/acc
		local c,s=cos(t),sin(t)
		r,i=r+rx*c-ix*s,i+rx*s+ix*c
	end
	return r/acc,i/acc
end

local function _2b(f)
	local i1,f1=modf(max(0,127.5*(f%2)))
	return char(i1)..char(floor(f1*255))
end

local refile,imfile=newFile'FTre',newFile'FTim'
refile:open'w' imfile:open'w'
for x=1,Ndata do
	local r,i=cft(x)
	refile:write(_2b(r)) imfile:write(_2b(i))
end
refile:close() imfile:close()

local t2=tick()

print("T10",t1-t0)
print("T21",t2-t1)

love.event.quit()
