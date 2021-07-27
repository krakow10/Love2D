--By xXxMoNkEyMaNxXx
local type=type

local random=math.random

local remove=table.remove

local decks,packs,stacks,players={},{},{},{}
local game={decks=decks,packs=packs,stacks=stacks,players=players}

local function getCard(stack,index)
	index=index and #stack>0 and (index-1)%#stack+1 or #stack
	local i=stack[index]
	if i then
		return decks[i[1]][i[2]]
	end
end

local function moveCard(card,stack1,index,faceUp)--Moves card to stack <stackId> at index <index> or <#stacks[stackId]+1>
	local stack0=stacks[card.stackId]
	local index0,index1=card.index,#stack1==0 and 1 or type(index)=="number" and (index-1)%(#stack1+1)+1 or #stack1+1
	if type(index)=="boolean" and faceUp==nil then
		faceUp=index
	end
	if stack0 and index0 and stack1 and index1 then
		local location=stack0[index0]
		for i=index0,#stack0 do
			local s0i=stack0[i+1]
			if s0i then
				decks[s0i[1]][s0i[2]].index=i
			end
			stack0[i]=s0i
		end
		for i=#stack1,index1,-1 do
			local s1i=stack1[i]
			if s1i then
				decks[s1i[1]][s1i[2]].index=i+1
			end
			stack1[i+1]=s1i
		end
		stack1[index1]=location
		card.stackId=stack1.stackId
		card.index=index1
		if type(faceUp)=="boolean" then
			card.up=faceUp
		end
		return true
	else
		print'Could not move card.'
		return false
	end
end

local function shuffle(stack)
	local length=#stack
	if length>1 then
		local contents={}
		for i=1,length do
			contents[i]=stack[i]
		end
		for i=1,length do
			local location=remove(contents,random(#contents))
			decks[location[1]][location[2]].index=i
			stack[i]=location
		end
	end
end

local suits={"Spades","Hearts","Clubs","Diamonds"}
local suitColours={"Black","Red"}
local initials={"A","2","3","4","5","6","7","8","9","10","J","Q","K"}
--A deck is a ordered list of the cards that is referred to by everything else.
function game.newDeck(stack,packId)
	local stackId=stack and stack.stackId or #stacks+1
	local stack=stacks[stackId] or game.newStack()
	local lastCard=#stack
	local deckId=#decks+1
	local deck={deckId=deckId,packId=packId or game.loadTexturePack("DefaultFaces.png","DefaultBacks.png").packId}
	for id=1,52 do
		local card={
			cardId=id,
			value=(id-1)%13+1,
			initial=initials[(id-1)%13+1],
			suit=suits[math.ceil(id/13)],
			suitColour=suitColours[math.ceil(id/13-1)%2+1],
			deckId=deckId,
			stackId=stackId,
			index=lastCard+id,
			up=false,--Face down

			rot={{-1,0,0},{0,-1,0},{0,0,1}},
			quat={0,0,0,1},
			pos={0,0,0},

			tQuat={0,0,0,1},
			tPos={0,0,0},
			fixed=true,--The card's location is set by the renderer

			move=moveCard,
		}
		deck[id]=card
		stack[lastCard+id]={deckId,id}
	end
	decks[deckId]=deck
	return deck
end

--Stacks represent a location where cards could be.
function game.newStack()
	local stackId=#stacks+1
	local stack={
		stackId=stackId,
		layout="Pile",--Pile,Fan,Horizontal,Vertical
		owner=0,--0 is table, playerId otherwise, -1 for off the table
		alignment=0,
		visible=0,--0 is visible to the table, playerId if greater, use -1 for visible to no one, use a table for visibility to select players.
	--[[
		mouseEnter(playerId)
		Called when a player hovers their mouse over the stack

		mouseLeave(playerId)
		Called when a player's mouse moves elsewhere after hovering over the stack

		mouseDown(playerId,index)
		Called when a player clicks on a card in the stack

		mouseUp(playerId,index)
		Called when a player lets go on a card in the stack
	--]]

		rot={{1,0,0},{0,1,0},{0,0,1}},
		quat={1,0,0,0},
		pos={0,0,0},

		tQuat={1,0,0,0},
		tPos={0,0,0},
		fixed=true,--The stack's location is set by the renderer

		getCard=getCard,
		shuffle=shuffle,
	}
	stacks[stackId]=stack
	return stack
end

function game.loadTexturePack(faces,backs)
	local packId=#packs+1
	local pack={
		faces=love.graphics.newImage(faces),
		backs=love.graphics.newImage(backs),
		packId=packId,
	}
	packs[packId]=pack
	return pack
end

function game.newPlayer(name)
	local playerId=#players+1
	local player={
		name=name or "Player"..playerId,
		playerId=playerId,
		hand=nil,--Which stack the player is holding (stackId)
	}
	players[playerId]=player
	return player
end

return game
