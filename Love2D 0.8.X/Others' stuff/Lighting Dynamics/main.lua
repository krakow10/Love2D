

function math.dist(x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function love.load()
	player = {x = 250, y = 250, w = 25, h = 25, speed = 50, torchPower = 5}

	tilesX = love.graphics.getWidth() / 15
	tilesY = love.graphics.getHeight() / 15
	loaded = false
	x = 0
	y = 0

	TreeNum = 10
	ct = 0
	trees = {}
end

function love.draw()--Please use Lua when you're using Lua.

	for i, t in ipairs(trees) do
	love.graphics.setColor(100, 255, 100, t.transparency)
	love.graphics.rectangle("fill", t.x, t.y, t.w, t.h)
	end

love.graphics.setColor(100, 100, 255, 255)
love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

end

function love.update(dt)

	if ct < TreeNum then--Oh my god this is terrible, you could easily generate all the tiles at once with no delay.
	ct = ct + 1
	table.insert(trees, {transparency = 0, x = math.random(0, love.graphics.getWidth()-10), y = math.random(0, love.graphics.getHeight()-20), w = 10, h = 20})
	end

	for i, t in ipairs(trees) do
		t.transparency = 255 / math.dist(player.x, player.y, t.x, t.y) * player.torchPower
	end


	if love.keyboard.isDown'w' and player.y > 0 then
	player.y = player.y - dt * player.speed
	end
	if love.keyboard.isDown's' and player.y < love.graphics.getHeight() - player.h then
		player.y = player.y + dt * player.speed
	end
	if love.keyboard.isDown'a' and player.x > 0 then
		player.x = player.x - dt * player.speed
	end
	if love.keyboard.isDown'd' and player.x < love.graphics.getWidth() - player.w then
		player.x = player.x + dt * player.speed
	end
end
