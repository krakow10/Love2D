--By xXxMoNkEyMaNxXx

local rubik=require'rubik'
local render=require'render'
local control=require'control'

local cube=rubik.new(21)
--cube.turnAxis=1
--cube.turnIndex=10
render.addCube(cube)
render.cam.pos={0,0,40}
render.cam.FOV=0.5

control.setRender(render)

love.draw=render.draw
love.update=control.update
