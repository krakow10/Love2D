--By xXxMoNkEyMaNxXx
require'vec'
require'mat'
require'gfx'
require'physics'

local draw=love.graphics.draw
function love.draw()
	gfx.displayData(physics[0])
	for x=0,#physics do
		for y=1,#physics[x] do
			draw(physics[x][y],x*(physics.View[3]+1)+1,(y-1)*(physics.View[4]+1)+1)
		end
	end
	--gfx.draw()
end

function love.update(t)
	physics.update(t)
	gfx.update(t)
end

function love.mousepressed(x,y,b)
	gfx.mouseDown(b)
end

love.keypressed=gfx.keyDown
