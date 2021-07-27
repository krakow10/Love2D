particles = {}
explosions = {}
powerupsOnScreen = {}
abilitiesOnScreen = {}
activeAbilities = {}
activePowerups = {}
meteorShower = {}
maxParticles = 20
particleSpeed = 200
particleNum = 0
spawnSpeed = 1
abilityNum = 0
powerupNum = 0 

--Spawn particles
local wait = 0
powerupDelay = 0
abilityDelay = 0
activePowerupDelay = 0
local meteorDelay = 0
local meteorNum = 0
local waveDelay = 0
local powerupWait = math.random(30, 60)
local abilityWait = math.random(30, 60)
function particles.spawn(dt)
	if wait >= 1 then
		wait = 0
		if particleNum < maxParticles then
			particleNum = particleNum + 1
			particleSize = math.random(10, 40)
			local randomNum = math.random(1, 2)
			local particleX = 0
			local direction = true 
				if randomNum == 1 then
					direction = true
					particleX = 0
				elseif randomNum == 2 then
					direction = false
					particleX = love.graphics.getWidth()
				end 
				
		table.insert(particles, {x = particleX, y = math.random(10, (love.graphics.getHeight()-10)), radius = particleSize, right = direction, collide = false})
		end 
	else
		wait = wait + spawnSpeed * dt
	end 
	
	if abilityDelay >= abilityWait then
		abilityDelay = 0
		abilityWait = math.random(30, 60)
		
		if abilityNum < 1 then
			local ability = abilities[math.random(1, NumAbilities)]
			local ps = nil
			if ability == "Meteor Shower" then
				ps = love.graphics.newParticleSystem(Particle, 1000)
				if quality == "high" then
					ps:setBufferSize(250)
				elseif quality == "medium" then
					ps:setBufferSize(150)
				elseif quality == "small" then
					ps:setBufferSize(50)
				end
				ps:setColors(255,98,0,255,224,95,0,0)
				ps:setDirection(6.2831852)
				ps:setEmissionRate(165)
				ps:setGravity(0,110)
				ps:setLifetime(33)
				ps:setParticleLife(0.29,0.29)
				ps:setRadialAcceleration(274,274)
				ps:setRotation(0,0)
				ps:setSizes(1,1,1)
				ps:setSpeed(100,200)
				ps:setSpin(200,400)
				ps:setSpread(6.2831852)
				ps:setTangentialAcceleration(0,0)
				ps:start()
			end
			local x = math.random(10, love.graphics.getWidth()-30)
			local y = math.random(10, love.graphics.getHeight()-30)
			table.insert(abilitiesOnScreen, {x = x, y = y, delay = 10, wait = 0, ability = ability, alpha = 255, angle = 0, ps = ps})
		end
	else
		abilityDelay = abilityDelay + 1 * dt
	end
	
	if powerupDelay >= powerupWait then
		powerupDelay = 0
		powerupWait = math.random(30, 60)
		
		if powerupNum < 1 then
			local powerup = powerups[math.random(1, NumPowerups)]
			local ps = nil
			if powerup == "Black Hole" then
				ps = love.graphics.newParticleSystem(Particle1, 1000)
				if quality == "high" then
					ps:setBufferSize(250)
				elseif quality == "medium" then
					ps:setBufferSize(150)
				elseif quality == "small" then
					ps:setBufferSize(50)
				end
				ps:setColors(79,83,83,255,90,90,90,255)
				ps:setDirection(6.2831852)
				ps:setEmissionRate(200)
				ps:setGravity(100,200)
				ps:setLifetime(60)
				ps:setParticleLife(0.15,0.38)
				ps:setRadialAcceleration(411,411)
				ps:setRotation(0,0)
				ps:setSizes(1,1,1)
				ps:setSpeed(100,200)
				ps:setSpin(200,233)
				ps:setSpread(6.2831852)
				ps:setTangentialAcceleration(-205,-205)
				ps:start()
			end
			local x = math.random(10, love.graphics.getWidth()-30)
			local y = math.random(10, love.graphics.getHeight()-30)
			table.insert(powerupsOnScreen, {x = x, y = y, delay = 10, wait = 0, powerup = powerup, alpha = 255, angle = 0, ps = ps})
		end
	else
		powerupDelay = powerupDelay + 1 * dt
	end
	
	for _, v in ipairs(activeAbilities) do
		if v.name == "Meteor Shower" then 
			if meteorNum < 10 then 
				if meteorDelay >= math.random(1, 4) then
					meteorDelay = 0 
					meteorNum = meteorNum + 1
					local ps = love.graphics.newParticleSystem(Particle, 1000)
					if quality == "high" then
						ps:setBufferSize(250)
					elseif quality == "medium" then
						ps:setBufferSize(150)
					elseif quality == "small" then
						ps:setBufferSize(50)
					end
					ps:setColors(255,255,255,255,255,111,0,255)
					ps:setDirection(6.2831852)
					ps:setEmissionRate(200)
					ps:setGravity(124,124)
					ps:setLifetime(60)
					ps:setParticleLife(0.5,1)
					ps:setRadialAcceleration(0,0)
					ps:setRotation(0,0.087266461111111)
					ps:setSizes(1,2,1)
					ps:setSpeed(100,309)
					ps:setSpin(200,400)
					ps:setSpread(6.2831852)
					ps:setTangentialAcceleration(0,137)
					ps:start()
					playSound(sounds.woosh) 
					table.insert(meteorShower, {x = math.random(100, love.graphics.getWidth()+100), y = -50, boundary = false, ps = ps})
				else
					meteorDelay = meteorDelay + 1 * dt
				end
			else
				meteorNum = 0
				table.remove(activeAbilities, _) 
			end 
		elseif v.name == "Radioactive Wave" then
			if waveDelay >= 1 then
				waveDelay = 0
				playSound(sounds.zap) 
				explode(player.x, player.y, 1, 700, 500, "Radioactive Wave")
				table.remove(activeAbilities, _) 
			else
				waveDelay = waveDelay + 1 * dt
			end
		elseif v.name == "Reduce Spawning" then
			spawnSpeed = 1
			table.remove(activeAbilities, _) 
		end
	end
	
	for _, v in ipairs(activePowerups) do
		if v.name == "Speed" then 
			if activePowerupDelay < 10 then
				activePowerupDelay = activePowerupDelay + 1 * dt
				player.speed = 4000
			else
				activePowerupDelay = 0
				player.speed =  2500
				player.powerup = "-"
				table.remove(activePowerups, _) 
			end
		elseif v.name == "Invincibility" then
			if activePowerupDelay < 10 then
				activePowerupDelay = activePowerupDelay + 1 * dt
				player.invincible = true
			else
				activePowerupDelay = 0
				player.invincible = false
				player.powerup = "-"
				table.remove(activePowerups, _) 
			end
		elseif v.name == "Black Hole" then
			if activePowerupDelay < 10 then
				activePowerupDelay = activePowerupDelay + 1 * dt
			else
				activePowerupDelay = 0
				v.ps:stop() 
				player.powerup = "-"
				table.remove(activePowerups, _) 
			end
		end
	end
end 

--Clear map of particles
function particles.clear()
	for _, v in ipairs(particles) do
		table.remove(particles, _)
	end
	
	for _, v in ipairs(abilitiesOnScreen) do
		table.remove(abilitiesOnScreen, _)
	end
	
	for _, v in ipairs(powerupsOnScreen) do
		table.remove(powerupsOnScreen, _)
	end
	
	for _, v in ipairs(activeAbilities) do
		table.remove(activeAbilities, _)
	end
	
	for _, v in ipairs(activePowerups) do
		table.remove(activePowerups, _)
	end 
	
	activePowerupDelay = 0
end

--Draw particles
function drawParticles() 
	for _, v in ipairs(meteorShower) do
		if options.quality == "medium" or options.quality == "high" then
			love.graphics.setColorMode("modulate")
			love.graphics.setBlendMode("additive")
		end 
		love.graphics.draw(v.ps, 0, 0)
		love.graphics.setBlendMode("alpha")
	end
	
	for _, v in ipairs(particles) do
		love.graphics.setColor(0, 0, 0, 150)
		love.graphics.circle("fill", v.x, v.y, v.radius) 
	end
	
	for _, v in ipairs(abilitiesOnScreen) do
		love.graphics.setColor(255, 255, 255, v.alpha)

		if v.ability == "Meteor Shower" then
			if options.quality == "medium" or options.quality == "high" then
				love.graphics.setColorMode("modulate")
				love.graphics.setBlendMode("additive")
			end 
			love.graphics.draw(v.ps, 0, 0)  
			love.graphics.setBlendMode("alpha")
		elseif v.ability == "Radioactive Wave" then
			love.graphics.setBlendMode("additive")
			love.graphics.draw(SmallGlow, v.x-15, v.y-15)
			love.graphics.setBlendMode("alpha")
			love.graphics.draw(WaveAbility, v.x+23, v.y+23, v.angle, 1, 1, 25, 25)
		elseif v.ability == "Reduce Spawning" then
			love.graphics.setBlendMode("additive")
			love.graphics.draw(SmallGlow, v.x-15, v.y-15)
			love.graphics.setBlendMode("alpha")
			love.graphics.draw(Arrow, v.x, v.y) 
		end 
	end
	
	for _, v in ipairs(powerupsOnScreen) do
		love.graphics.setColor(255, 255, 255, v.alpha) 
		
		if v.powerup == "Invincibility" then
			love.graphics.setBlendMode("additive")
			love.graphics.draw(SmallGlow, v.x-15, v.y-15) 
			love.graphics.setBlendMode("alpha")
			love.graphics.draw(Star, v.x+23, v.y+23, v.angle, 1, 1, 25, 25) 
		elseif v.powerup == "Speed" then
			love.graphics.setBlendMode("additive")
			love.graphics.draw(SmallGlow, v.x-15, v.y-15) 
			love.graphics.setBlendMode("alpha")
			love.graphics.draw(SpeedPowerup, v.x, v.y)
		elseif v.powerup == "Black Hole" then
			if options.quality == "medium" or options.quality == "high" then
				love.graphics.setColorMode("modulate")
				love.graphics.setBlendMode("additive")
			end 
			love.graphics.draw(v.ps, 0, 0)  
			love.graphics.setBlendMode("alpha")
		end
	end
	
	for _, v in ipairs(activePowerups) do 
		if v.name == "Invincibility" then
			love.graphics.setColor(255, 255, 255, 100) 
			love.graphics.circle("fill", player.x, player.y, player.width*1) 
		elseif v.name == "Black Hole" then
			if options.quality == "medium" or options.quality == "high" then
				love.graphics.setColorMode("modulate")
				love.graphics.setBlendMode("additive")
			end 
			love.graphics.draw(v.ps, player.x, player.y)  
			love.graphics.setBlendMode("alpha")
		end
	end
end

--Create a new particle explosion
function explode(x, y, r, grow, speed, eType)
table.insert(explosions, {x = x, y = y, radius = r, grow = grow, growSpeed = speed, color = 0, t = 255, eType = eType})
end

--Draw particle explosions
function explosions.draw()
	for _, v in ipairs(explosions) do
		if v.eType == "ability" or v.eType == "Radioactive Wave" then
			love.graphics.setLineWidth(10)
		else
			love.graphics.setLineWidth(1) 
		end
		love.graphics.setColor(v.color, v.color, v.color, v.t)
		
		if v.eType == "MeteorShower" then
			love.graphics.circle("fill", v.x, v.y, v.radius)
		else
			love.graphics.circle("line", v.x, v.y, v.radius)
		end 
	end
end

--Distance between 2 points
function math.dist(x1,y1, x2,y2) 
return ((x2-x1)^2+(y2-y1)^2)^0.5 
end

--Update particles
local t = 0
local d = 1
local t1 = 0
local d1 = 1
function particles.update(dt)
	for _, v in ipairs(explosions) do
		if v.eType == "blob" then
			if v.radius < v.grow then
				v.radius = v.radius + v.growSpeed * dt
				v.color = v.color + 255 * dt
				v.t = v.t - 255 * dt
			else
				table.remove(explosions, _) 
			end 
		elseif v.eType == "ability" then
			if v.radius > v.grow then
				v.radius = v.radius - v.growSpeed * dt
				v.color = 255
				v.x = player.x
				v.y = player.y
			else
				table.remove(explosions, _)
			end
		elseif v.eType == "MeteorShower" then
			if v.radius < v.grow then
				v.radius = v.radius + v.growSpeed * dt
				v.color = 255
				v.t = v.t - v.growSpeed * dt
			else
				table.remove(explosions, _) 
			end 
		elseif v.eType == "Radioactive Wave" then
			if v.radius < v.grow then
				v.radius = v.radius + v.growSpeed * dt
				v.color = 255
				v.t = v.t - 255 * dt
				for i, p in ipairs(particles) do
					if CheckCollision(v.x-v.radius, v.y-v.radius, v.radius*2, v.radius*2, p.x-p.radius, p.y-p.radius, p.radius*2, p.radius*2) then
						p.radius = player.width/3 
					end 
				end
			else
				table.remove(explosions, _)
			end
		end 
	end 
	
	for _, v in ipairs(abilitiesOnScreen) do
		if v.wait < v.delay then
			v.wait = v.wait + 1 * dt
			if v.ability == "Meteor Shower" then
				v.ps:update(dt)
				v.ps:setPosition(v.x+23, v.y+23)
			elseif v.ability == "Radioactive Wave" then
				v.angle = v.angle + math.rad(45) * dt
			elseif v.ability == "Reduce Spawning" then
				if d == 1 then
					if t >= 255 then
						t = 255
						d = -1
					else
						t = t + 255 * dt
					end
				elseif d == -1 then
					if t <= 0 then
						t = 0
						d = 1
					else
						t = t - 255 * dt
					end
				end 
				v.alpha = t
			end
		else
			table.remove(abilitiesOnScreen, _)
		end
	end
	
	for _, v in ipairs(powerupsOnScreen) do
		if v.wait < v.delay then
			v.wait = v.wait + 1 * dt
			if v.powerup == "Invincibility" then
				v.angle = v.angle + math.rad(45) * dt
			elseif v.powerup == "Speed" then
				if d1 == 1 then
					if t1 >= 255 then
						t1 = 255
						d1 = -1
					else
						t1 = t1 + 255 * dt
					end
				elseif d1 == -1 then
					if t1 <= 0 then
						t1 = 0
						d1 = 1
					else
						t1 = t1 - 255 * dt
					end
				end
				v.alpha = t1
			elseif v.powerup == "Black Hole" then
				v.ps:update(dt)
				v.ps:setPosition(v.x+23, v.y+23)
			end
		else
			table.remove(powerupsOnScreen, _)
		end
	end
	
	
	
	for _, v in ipairs(meteorShower) do
		v.ps:update(dt)
		v.ps:setPosition(v.x, v.y)
		if v.y < love.graphics.getHeight()+50 then 
			v.x = v.x - 500 * dt
			v.y = v.y + 500 * dt 
		else
			v.ps:stop()
			playSound(sounds.explosion) 
			explode(v.x, v.y, 1, 500, 500, "MeteorShower")
			table.remove(meteorShower, _) 
		end
		
		for i, p in ipairs(particles) do
			if CheckCollision(v.x-50, v.y-50, 100, 100, p.x-p.radius, p.y-p.radius, p.radius*2, p.radius*2) then
				eatBlob(i, p)
			end 
		end 
	end
	
	for _, v in ipairs(activePowerups) do
		if v.name == "Black Hole" then
			v.ps:update(dt)
			for i, p in ipairs(particles) do
				if p.radius <= player.width/2 then
					local speed = (1000/math.dist(p.x, p.y, player.x, player.y)) * 100 
					local angle = math.atan2((player.y - p.y), (player.x - p.x))
					local x = speed * math.cos(angle)
					local y = speed * math.sin(angle) 
					p.x = p.x + x * dt
					p.y = p.y + y * dt
				end 
			end
		end 
	end
end

--Move particles
function particles.move(dt)
	for _, v in ipairs(particles) do
		if v.collide then
			maxParticles = maxParticles + 1
			spawnSpeed = spawnSpeed + 0.1
			explode(v.x, v.y, v.radius, v.radius*2, v.radius*2, "blob")
			table.remove(particles, _)
			particleNum = particleNum - 1
		end 
		if v.right then
			v.x = v.x + particleSpeed * dt
		else
			v.x = v.x - particleSpeed * dt
		end 
	end 
end 

--Remove particles when they reach boundary
function particles.boundary()
	for i, v in ipairs(particles) do
		if v.right and v.x > love.graphics.getWidth() then
			particleNum = particleNum - 1
			table.remove(particles, i)
		elseif v.right == false and v.x < 0 then
			particleNum = particleNum - 1
			table.remove(particles, i)
		end 
	end 
end 

--Update all particles
function updateParticles(dt)
	if not pause then
		particles.spawn(dt)
		particles.move(dt)
		particles.boundary()
		particles.update(dt)
	end 
end 