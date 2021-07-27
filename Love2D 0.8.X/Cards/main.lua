--By xXxMoNkEyMaNxXx
playerId=1
local cards=require'cards'
local scene=require'scene'
local vec=require'vec'

function love.load()
	game=love.filesystem.load'test.game'(cards,scene)
	--game=love.filesystem.load'test.game'(cards,scene)
end

local getPos=love.mouse.getPosition

function love.draw()
	if game and game.draw then
		game.draw()
	else
		scene.drawScene(cards,playerId)
	end
end

local fps=love.timer.getFPS
local setCaption=love.graphics.setCaption

local lastCard
local lastStack
local lastStackId
function love.update(t)
	local dir=scene.toWorld{getPos()}
	local card=scene.cast(cards,scene.camPos,dir)
	if card~=lastCard then
		local stackId
		if card then
			stackId=card.stackId
		end
		local stack=cards.stacks[stackId]
		if stackId~=lastStackId then
			if lastStack and lastStack.mouseLeave then
				lastStack.mouseLeave(playerId)
			end
			if stack and stack.mouseEnter then
				stack.mouseEnter(playerId)
			end
			lastStack,lastStackId=stack,stackId
		end
		lastCard=card
	end
	local player=cards.players[playerId]
	if player and player.selection then
		local hit,dis=scene.cast(cards,scene.camPos,dir,player.selection)
		player.hit=hit

		local float
		if hit then
			local stack=cards.stacks[hit.stackId]
			if stack then
				player.selection.tQuat=stack.quat
			else
				player.selection.tQuat={1,0,0,0}
			end
			float=vec.add(scene.camPos,vec.mulNum(dir,dis))
		else
			player.selection.tQuat={1,0,0,0}
			float=vec.add(scene.camPos,vec.mulNum(dir,-scene.camPos[2]/dir[2]))
		end
		player.selection.tPos=vec.add(float,{0,0.1,0})
	else
		player.hit=card
	end
	if game and game.update then
		game.update(lastCard,lastStack)
	end
	if scene and scene.update then
		scene.update(cards,t)
	end
	setCaption("CardGame Engine - "..fps().." FPS")
end

function love.mousepressed(x,y,b)
	if b=="l" then
		local card=scene.cast(cards,scene.camPos,scene.toWorld{x,y})
		if card then
			local stack=cards.stacks[card.stackId]
			if stack and stack.mouseDown then
				stack.mouseDown(playerId,card.index)
			end
		end
		if game and game.mouseDown then
			game.mouseDown(playerId,b)
		end
	elseif b=="wu" then
		scene.FOV=scene.FOV/1.01
	elseif b=="wd" then
		scene.FOV=scene.FOV*1.01
	end
end
function love.mousereleased(x,y,b)
	if b=="l" then
		local card=scene.cast(cards,scene.camPos,scene.toWorld{x,y})
		if card then
			local stack=cards.stacks[card.stackId]
			if stack and stack.mouseUp then
				stack.mouseUp(playerId,card.index)
			end
		end
		if game and game.mouseUp then
			game.mouseUp(playerId,b)
		end
	end
end

function love.keypressed(k)
	if k=="escape" then
		love.event.quit()
	elseif game and game.keyDown then
		game.keyDown(playerId,k)
	end
end
