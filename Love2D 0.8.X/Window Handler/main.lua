--By xXxMoNkEyMaNxXx
local version=1.22
_G.DebugMode=false--Set to true to see objects with focus highlighted

local loader=require'loader'--lfs wrapper
local eventHandler=require'callback'--Callback groups
local ctrl=eventHandler(require'ctrl')--Look in ctrl!

local manager=loader.open'manager.lua'--Look in here!
--Look in these folders too!
manager.addProgram'Minimal'
manager.addProgram'Grapher'
manager.addProgram'Mandelbrot'
manager.addProgram'Test'
manager.addProgram'List'
manager.addProgram'Splash'
manager.addProgram'Squares'

--To use the love callback below (event.update):
local event=eventHandler{}--eventHandler just returns this table. (for convenience)

function event.update()
	love.graphics.setCaption("Window Handler v"..string.format("%.1f",version).." - "..love.timer.getFPS())
end
