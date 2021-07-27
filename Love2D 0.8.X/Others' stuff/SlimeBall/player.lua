abilities = {"Meteor Shower", "Radioactive Wave", "Reduce Spawning"}
powerups = {"Invincibility", "Speed", "Black Hole"}
NumAbilities = 3
NumPowerups = 3
player = {gamemode = "menu"}

--Load player
function player.load()
	player.x = (love.graphics.getWidth() / 2) - 60
	player.y = (love.graphics.getHeight() / 2) - 60
	player.width = 60
	player.height = 60
	player.xVel = 0
	player.yVel = 0
	player.friction = 7
	player.speed = 2500
	player.score = 0
	player.moving = false
	player.powerup = "-"
	player.ability = "-"
	player.invincible = false
	player.trail = {}
end

--Draw player
function player.draw()
	for _, v in ipairs(player.trail) do
		love.graphics.setColor(255, 255, 255, v.t)
		love.graphics.circle("fill", v.x, v.y, v.r)
	end 
	love.graphics.setColor(255, 255, 255)
	love.graphics.setBlendMode("additive")
	love.graphics.draw(Glow, player.x-(player.width/2)-27.5, player.y-(player.height/2)-27.5)
	love.graphics.setBlendMode("alpha")
	love.graphics.circle("fill", player.x, player.y, 30)
end

--Create slime trail
function trail(dt)
	if player.moving then
		table.insert(player.trail, {x = player.x, y = player.y, r = 30, t = 255})
	end	

	for _, v in ipairs(player.trail) do
		if v.r > 1 then
			v.r = v.r - 100 * dt
			v.t = v.t - 850 * dt
		else
			table.remove(player.trail, _) 
		end 
	end
end

--Player physics
function player.physics(dt)
	player.x = player.x + player.xVel * dt
	player.y = player.y + player.yVel * dt
	player.yVel = player.yVel * (1 - math.sin(dt * player.friction, 1))
	player.xVel = player.xVel * (1 - math.sin(dt * player.friction, 1))
end 

--Move player
function player.move(dt)
	if love.keyboard.isDown(options.right) and player.xVel < player.speed or love.keyboard.isDown(options.right2) and player.xVel < player.speed then
			player.xVel = player.xVel + player.speed * dt
	end
	
	if love.keyboard.isDown(options.left) and player.xVel > -player.speed or love.keyboard.isDown(options.left2) and player.xVel < player.speed then
		player.xVel = player.xVel - player.speed * dt
	end 
	
	if love.keyboard.isDown(options.down) and player.yVel < player.speed or love.keyboard.isDown(options.down2) and player.xVel < player.speed then
		player.yVel = player.yVel + player.speed * dt
	end 
	
	if love.keyboard.isDown(options.up) and player.yVel > - player.speed or love.keyboard.isDown(options.up2) and player.xVel < player.speed then
		player.yVel = player.yVel - player.speed * dt
	end 
	
	if love.keyboard.isDown(options.up) or love.keyboard.isDown(options.down) or love.keyboard.isDown(options.left) or love.keyboard.isDown(options.right) or love.keyboard.isDown(options.up2) or love.keyboard.isDown(options.down2) or love.keyboard.isDown(options.left2) or love.keyboard.isDown(options.right2) then
		player.moving = true
	else
		player.moving = false
	end
end 

function player.boundary()
	if player.x < -player.width then
		player.x = love.graphics.getWidth()
	end 
	
	if player.x >= love.graphics.getWidth() + player.width then
		player.x = -player.width
	end 
	
	if player.y >= love.graphics.getHeight() + player.height then
		player.y = -player.height
	end
	
	if player.y < -player.height then 
		player.y = love.graphics.getHeight()
	end 
end 

--Eat blob
function eatBlob(i, v) 
	playSound(sounds.slimeATK)
	player.score = player.score + (math.floor(v.radius/5))
	v.collide = true
end

--Check for player collisions
function player.collisionCheck(dt)
	for _, v in ipairs(particles) do
		if CheckCollision(player.x-(player.width/2), player.y-(player.height/2), player.width, player.height, v.x-v.radius, v.y-v.radius, v.radius*2, v.radius*2) then
			if player.width/2 >= v.radius then 
				eatBlob(_, v)
			elseif player.width/2 < v.radius and not player.invincible then
				player.gamemode = "gameover"
				love.audio.stop(currentSong) 
			end 
		end
	end 
	
	for _, v in ipairs(abilitiesOnScreen) do
		if CheckCollision(player.x-(player.width/2), player.y-(player.height/2), player.width, player.height, v.x, v.y, 50, 50) then
			if player.ability == "-" then
				playSound(sounds.powerup)
				player.ability = v.ability
				table.remove(abilitiesOnScreen, _)
			end 
		end 
	end
	
	for _, v in ipairs(powerupsOnScreen) do
		if CheckCollision(player.x-(player.width/2), player.y-(player.height/2), player.width, player.height, v.x, v.y, 50, 50) then
			if player.powerup == "-" then
				playSound(sounds.powerup)
				local ps = nil
				if v.powerup == "Black Hole" then
					ps = love.graphics.newParticleSystem(Particle1, 1000)
					if quality == "high" then
						ps:setBufferSize(250)
					elseif quality == "medium" then
						ps:setBufferSize(150)
					elseif quality == "small" then
						ps:setBufferSize(50)
					end 
					ps:setColors(79,83,83,255,81,83,81,255)
					ps:setDirection(6.2831852)
					ps:setEmissionRate(1850)
					ps:setGravity(100,200)
					ps:setLifetime(60)
					ps:setParticleLife(0.5,1)
					ps:setRadialAcceleration(-10000,-10000)
					ps:setRotation(0,0)	
					ps:setSizes(1,1,1)
					ps:setSpeed(100,200)
					ps:setSpin(200,400)
					ps:setSpread(6.2831852)
					ps:setTangentialAcceleration(3973,5000)
					ps:start()
				end
				player.powerup = v.powerup
				table.insert(activePowerups, {name = v.powerup, ps = ps})
				table.remove(powerupsOnScreen, _)
			end 
		end
	end 
end

--Draw player
function drawPlayer()
	if player.gamemode == "playing" then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.printf("Score: "..player.score, 20, 20, love.graphics.getWidth()-40, "left")
		love.graphics.printf("Ability: "..player.ability, 0, 20, love.graphics.getWidth()-50, "center")
		love.graphics.printf("Powerup: "..player.powerup, 20, 20, love.graphics.getWidth()-40, "right") 
	end 

	player.draw()
end

--Update player functions
function updatePlayer(dt)
	if player.gamemode == "playing" then
		if not pause then
			player.physics(dt)
			player.move(dt)
			player.boundary()
			player.collisionCheck(dt)
			trail(dt)
		end 
	end 
end

--Check for collision function
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)

  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end
