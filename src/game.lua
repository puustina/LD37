local g = love.graphics

local game = {}
game.timer = Timer.new()
game.pmove = love.audio.newSource("assets/pmove.wav", "static")
game.emove = love.audio.newSource("assets/emove.wav", "static")
game.pickup = love.audio.newSource("assets/pickup.wav", "static")
game.eaten = love.audio.newSource("assets/eaten.wav", "static")
game.change = love.audio.newSource("assets/change.wav", "static")
game.pushtile = love.audio.newSource("assets/pushtiles.wav", "static")
game.cantpush = love.audio.newSource("assets/cantpush.wav", "static")

game.DIRECTIONS = { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3 }
game.OBJECTS = { PLAYER = 0, EXTRAPIECE = 1 }

game.tilemap = g.newImage("assets/tilemap.png")
game.pQuad = g.newQuad(0, 0, conf.tile.w, conf.tile.h, game.tilemap:getDimensions())
game.eQuad = g.newQuad(conf.tile.w, 0, conf.tile.w, conf.tile.h, game.tilemap:getDimensions())
game.pSpawnQuad = g.newQuad(2 * conf.tile.w, 0, conf.tile.w, conf.tile.h, game.tilemap:getDimensions())
game.eSpawnQuad = g.newQuad(3 * conf.tile.w, 0, conf.tile.w, conf.tile.h, game.tilemap:getDimensions())
game.floorQuads = {}
game.FLOORQUADCOUNT = 5
for i = 1, game.FLOORQUADCOUNT, 1 do
	game.floorQuads[i] = g.newQuad((i - 1) * conf.tile.w, conf.tile.h, conf.tile.w, conf.tile.h, game.tilemap:getDimensions())
end
game.obstacleQuads = {}
game.OBSTACLEQUADCOUNT = 6
for i = 1, game.OBSTACLEQUADCOUNT, 1 do
	game.obstacleQuads[i] = g.newQuad((i - 1) * conf.tile.w, 2 * conf.tile.h, conf.tile.w, conf.tile.h, game.tilemap:getDimensions())
end
game.treasureQuads = {}
game.TREASUREQUADCOUNT = 4
for i = 1, game.TREASUREQUADCOUNT, 1 do
	game.treasureQuads[i] = g.newQuad((i - 1) * conf.tile.w, 3 * conf.tile.h, conf.tile.w, conf.tile.h, game.tilemap:getDimensions())
end
game.bg = g.newImage("assets/bg.png")

game.drawTile = function(x, y, scale, tile)
	g.setColor(255, 255, 255)
	g.draw(game.tilemap, tile.quad, conf.tile.w/2 + x * conf.tile.w, conf.tile.h/2 + y * conf.tile.h, 0, scale, scale, conf.tile.w/2, conf.tile.h/2)

	if tile.block then
		g.draw(game.tilemap, tile.block, conf.tile.w/2 + x * conf.tile.w, conf.tile.h/2 + y * conf.tile.h, 0, scale, scale, conf.tile.w/2, conf.tile.h/2)
	elseif tile.treasure and not tile.treasure.found then
		g.draw(game.tilemap, tile.treasure.quad, conf.tile.w/2 + x * conf.tile.w, conf.tile.h/2 + y * conf.tile.h, 0, scale, scale, conf.tile.w/2, conf.tile.h/2)
	end
end

game.handleMove = function(direction)
	local success = false

	if game.selected == game.OBJECTS.PLAYER then
		game.player:move(direction, game.area.tiles)
		success = true
	else
		success = game.extraPiece:move(direction, game.area.tiles, game.player, game.enemies)
	end

	if success then
		game.enemies:move(game.player, game.area.tiles)
	end
end

game.handleExtraPieceMove = function(direction)
	if game.selected == game.OBJECTS.EXTRAPIECE then
		if direction == game.DIRECTIONS.UP then
			game.extraPiece.x = conf.area.w/2
			game.extraPiece.y = 0
		elseif direction == game.DIRECTIONS.DOWN then
			game.extraPiece.x = conf.area.w/2
			game.extraPiece.y = conf.area.h + 1
		elseif direction == game.DIRECTIONS.LEFT then
			game.extraPiece.x = 0
			game.extraPiece.y = conf.area.h/2
		elseif direction == game.DIRECTIONS.RIGHT then
			game.extraPiece.x = conf.area.w + 1
			game.extraPiece.y = conf.area.h/2
		end
	end
end

game.newTile = function()
	local block = nil
	if math.random() < 0.1 then block = game.obstacleQuads[math.random(1, game.OBSTACLEQUADCOUNT)]  end
	return { quad = game.floorQuads[math.random(1, game.FLOORQUADCOUNT)], block = block, treasure = nil }
end

game.selected = game.OBJECTS.PLAYER
game.player = {
	x = 1,
	y = 1,
	s = 1,
	d = -1,
	dir = game.DIRECTIONS.DOWN,
	draw = function(self)	
		g.setColor(255, 255, 255)
		g.draw(game.tilemap, game.pQuad, conf.tile.w/2 + (self.x - 1) * conf.tile.w, conf.tile.h/2 + (self.y - 1) * conf.tile.h, 0, self.s, self.s, conf.tile.w/2, conf.tile.h/2)
	end,
	move = function(self, direction, tiles)
		local delta = {}
		delta[game.DIRECTIONS.UP] = { 0, -1 } 
		delta[game.DIRECTIONS.DOWN] = { 0, 1 }
		delta[game.DIRECTIONS.RIGHT] = { 1, 0 } 
		delta[game.DIRECTIONS.LEFT] = { -1, 0 } 
		
		local nX = self.x + delta[direction][1]
		local nY = self.y + delta[direction][2]
		if nX > 0 and nY > 0 and nX <= conf.area.w and nY <= conf.area.h and not tiles[nX][nY].block then
			love.audio.play(game.pmove)
			self.x = nX
			self.y = nY

			if tiles[nX][nY].treasure and not tiles[nX][nY].treasure.found then 
				love.audio.play(game.pickup)
				tiles[nX][nY].treasure.found = true 
				for i, j in ipairs(game.treasure) do
					if not j.found then break end
					if i == #game.treasure then
						game.levelOver = true
						GS.switch(victory)
					end
				end
			end
		end
	end
}
game.enemies = {
	draw = function(self)
		g.setColor(255, 255, 255)
		for i, j in ipairs(self) do
			g.draw(game.tilemap, game.eQuad, (j.x - 1) * conf.tile.w, (j.y - 1) * conf.tile.h)
		end
	end,
	move = function(self, player, tiles)
		-- use A*, same naming as with the wikipedia pseudocode
		local noEnemyInTile = function(index, x, y)
			for i = 1, index - 1, 1 do
				if game.enemies[i].x == x and game.enemies[i].y == y then return false end
			end
			return true
		end
		local reconstructPath = function(cameFrom, current)
			local path = { current }
			while cameFrom[current[1] ][current[2] ] do
				current = cameFrom[current[1] ][current[2] ]
				path[#path + 1] = current
			end
			return path -- just gives us the (second) last one
		end
		local aStar = function(enemy, index)
			local closedSet = {}
			local openSet = { { enemy.x, enemy.y } }
			local cameFrom = {}
			for x = 1, conf.area.w, 1 do
				cameFrom[x] = {}
			end
			local gScore = {}
			for x = 1, conf.area.w, 1 do
				gScore[x] = {}
				for y = 1, conf.area.h, 1 do
					gScore[x][y] = math.huge
				end
			end
			gScore[enemy.x][enemy.y] = 0
			local fScore = {}
			for x = 1, conf.area.w, 1 do
				fScore[x] = {}
				for y = 1, conf.area.h, 1 do
					fScore[x][y] = math.huge
				end
			end
			fScore[enemy.x][enemy.y] = math.abs(enemy.x - player.x) + math.abs(enemy.y - player.y)
			while #openSet > 0 do
				local lowestNmbr = math.huge
				local lowest = {}
				local lowestIndx
				for i, j in ipairs(openSet) do
					if fScore[j[1] ][j[2] ] <= lowestNmbr then
						lowestNmbr = fScore[j[1] ][j[2] ]
						lowest = j
						lowestIndx = i
					end
				end
				current = { lowest[1], lowest[2] }
				if current[1] == player.x and current[2] == player.y then
					return reconstructPath(cameFrom, current)
				end
				table.remove(openSet, lowestIndx)
				closedSet[#closedSet + 1] = current
				for dx = -1, 1, 1 do
					for dy = -1, 1, 1 do
						if math.abs(dx) + math.abs(dy) == 1 and current[1] + dx > 0 and current[1] + dx <= conf.area.w and current[2] + dy > 0 and current[2] + dy <= conf.area.h and not tiles[current[1] + dx][current[2] + dy].block and noEnemyInTile(index, current[1] + dx, current[2] + dy) then
							-- neighbours
							local skip = false
							for i, j in ipairs(closedSet) do
								if j[1] == current[1] + dx and j[2] == current[2] + dy then
									skip = true
									break
								end
							end
							if not skip then
								local tentativeGScore = gScore[current[1] ][current[2] ] + 1
								local found = false
								local index = nil
								for i, j in ipairs(openSet) do
									if j[1] == current[1] + dx and j[2] == current[2] + dy then
										found = true
										index = i
										break
									end
								end
								local skip2 = false
								if not found then
									openSet[#openSet + 1] = { current[1] + dx, current[2] + dy }
								elseif tentativeGScore >= gScore[current[1] + dx][current[2] + dy] then
									skip2 = true
								end
								if not skip2 then
									cameFrom[current[1] + dx][current[2] + dy] = { current[1], current[2] }
									gScore[current[1] + dx][current[2] + dy] = tentativeGScore
									fScore[current[1] + dx][current[2] + dy] = gScore[current[1] + dx][current[2] + dy] + math.abs(player.x - (current[1] + dx)) + math.abs(player.y - (current[2] + dy))
								end
							end
						end
					end
				end
			end
			return false
		end

		for _, enemy in ipairs(self) do
			local nextMove = aStar(enemy, _)

			if nextMove then
				if #nextMove > 2 then 
					nextMove = nextMove[#nextMove - 2] 
				else
					nextMove = nextMove[#nextMove - 1]
				end
				if nextMove then
					love.audio.play(game.emove)
					enemy.x = nextMove[1]
					enemy.y = nextMove[2]
				end
			end

			if enemy.x == player.x and enemy.y == player.y then
				if not game.levelOver then
					love.audio.play(game.eaten)
					game.levelOver = true
					GS.switch(gameover) 
				end
			end
		end
	end
}
game.extraPiece = {
	x = 0,
	y = conf.area.h/2,
	s = 1,
	d = -1,
	tile = nil,
	draw = function(self, direction, tiles)
		game.drawTile(self.x, self.y, self.s, self.tile)
	end,
	move = function(self, direction, tiles, player, enemies)
		moveTaken = false -- this whole block needs refactoring :-l
		local enemyOrPlayerBlocking = function(x, y, direction, player, enemies)
			local potentialBlockers = {}
			if direction == game.DIRECTIONS.LEFT or direction == game.DIRECTIONS.RIGHT then
				if player.y == y then potentialBlockers[#potentialBlockers + 1] = player end
				for i, j in ipairs(enemies) do
					if j.y == y then potentialBlockers[#potentialBlockers + 1] = j end
				end
				for i, j in ipairs(potentialBlockers) do
					if direction == game.DIRECTIONS.LEFT then
						if j.x == 1 then 
							love.audio.play(game.cantpush)	
							return true 
						end
					else
						if j.x == conf.area.w then 
							love.audio.play(game.cantpush)
							return true 
						end
					end
				end
				love.audio.play(game.pushtile)
				return false
			else
				if player.x == x then potentialBlockers[#potentialBlockers + 1] = player end
				for i, j in ipairs(enemies) do
					if j.x == x then potentialBlockers[#potentialBlockers + 1] = j end
				end
				for i, j in ipairs(potentialBlockers) do
					if direction == game.DIRECTIONS.UP then
						if j.y == 1 then 
							love.audio.play(game.cantpush)
							return true 
						end
					else
						if j.y == conf.area.h then 
							love.audio.play(game.cantpush)
							return true 
						end
					end
				end
				love.audio.play(game.pushtile)
				return false
			end
		end
		local movePlayerAndEnemies = function(x, y, direction, player, enemies)
			local toMove = {}
			if direction == game.DIRECTIONS.LEFT or direction == game.DIRECTIONS.RIGHT then
				if player.y == y then toMove[#toMove + 1] = player end
				for i, j in ipairs(enemies) do
					if j.y == y then toMove[#toMove + 1] = j end
				end
				for i, j in ipairs(toMove) do
					if direction == game.DIRECTIONS.LEFT then
						j.x = j.x - 1
					else
						j.x = j.x + 1
					end
				end
			end
			if direction == game.DIRECTIONS.UP or direction == game.DIRECTIONS.DOWN then
				if player.x == x then toMove[#toMove + 1] = player end
				for i, j in ipairs(enemies) do
					if j.x == x then toMove[#toMove + 1] = j end
				end
				for i, j in ipairs(toMove) do
					if direction == game.DIRECTIONS.UP then
						j.y = j.y - 1
					else
						j.y = j.y + 1
					end
				end
			end
		end
		if self.x == 0 and direction == game.DIRECTIONS.LEFT then
			self.x = conf.area.w + 1
		elseif self.x == conf.area.w + 1 and direction == game.DIRECTIONS.RIGHT then
			self.x = 0
		elseif self.y == 0 and direction == game.DIRECTIONS.UP then
			self.y = conf.area.h + 1
		elseif self.y == conf.area.h + 1 and direction == game.DIRECTIONS.DOWN then
			self.y = 0	
		elseif self.x == 0 and direction == game.DIRECTIONS.RIGHT then
			if enemyOrPlayerBlocking(self.x, self.y, direction, player, enemies) then
			else
				moveTaken = true	
				local tT = tiles[conf.area.w][self.y]
				local temp = { quad = tT.quad, block = tT.block, treasure = tT.treasure }
				for i = conf.area.w, 2, -1 do
					tiles[i][self.y] = tiles[i - 1][self.y]
				end
				tiles[1][self.y] = self.tile
				self.tile = temp
				self.x = conf.area.w + 1
				movePlayerAndEnemies(self.x, self.y, direction, player, enemies)
			end
		elseif self.x == conf.area.w + 1 and direction == game.DIRECTIONS.LEFT then	
			if enemyOrPlayerBlocking(self.x, self.y, direction, player, enemies) then
			else
				moveTaken = true
				local tT = tiles[1][self.y]
				local temp = { quad = tT.quad, block = tT.block, treasure = tT.treasure }
				for i = 1, conf.area.w - 1, 1 do
					tiles[i][self.y] = tiles[i + 1][self.y]
				end
				tiles[conf.area.w][self.y] = self.tile
				self.tile = temp
				self.x = 0
				movePlayerAndEnemies(self.x, self.y, direction, player, enemies)
			end
		elseif self.y == 0 and direction == game.DIRECTIONS.DOWN then
			if enemyOrPlayerBlocking(self.x, self.y, direction, player, enemies) then
			else
				moveTaken = true
				local tT = tiles[self.x][conf.area.h]
				local temp = { quad = tT.quad, block = tT.block, treasure = tT.treasure }
				for i = conf.area.h, 2, -1 do
					tiles[self.x][i] = tiles[self.x][i - 1]
				end
				tiles[self.x][1] = self.tile
				self.tile = temp
				self.y = conf.area.h + 1	
				movePlayerAndEnemies(self.x, self.y, direction, player, enemies)
			end
		elseif self.y == conf.area.h + 1 and direction == game.DIRECTIONS.UP  then
			if enemyOrPlayerBlocking(self.x, self.y, direction, player, enemies) then
			else
				moveTaken = true
				local tT = tiles[self.x][1]
				local temp = { quad = tT.quad, block = tT.block, treasure = tT.treasure }
				for i = 1, conf.area.h - 1, 1 do
					tiles[self.x][i] = tiles[self.x][i + 1]
				end
				tiles[self.x][conf.area.h] = self.tile
				self.tile = temp
				self.y = 0
				movePlayerAndEnemies(self.x, self.y, direction, player, enemies)
			end
		elseif self.x == 0 or self.x == conf.area.w + 1 then
			if direction == game.DIRECTIONS.UP and self.y > 1 then
				self.y = self.y - 1
			elseif direction == game.DIRECTIONS.DOWN and self.y < conf.area.h then
				self.y = self.y + 1
			end
		elseif self.y == 0 or self.y == conf.area.h + 1 then
			if direction == game.DIRECTIONS.LEFT and self.x > 1 then
				self.x = self.x - 1
			elseif direction == game.DIRECTIONS.RIGHT and self.x < conf.area.w then
				self.x = self.x + 1
			end
		end
		return moveTaken
	end
}
game.area = {
	tiles = {},
	draw = function(self)
		for x = 1, conf.area.w, 1 do
			for y = 1, conf.area.h, 1 do
				game.drawTile(x - 1, y - 1, 1, self.tiles[x][y])
			end
		end
	end
}
game.treasure = {
	uiPos = { { 0, 0 }, { 0, conf.area.h + 1 }, { conf.area.w + 1, 0 }, { conf.area.w + 1, conf.area.h + 1 } },
	draw = function(self)
		for i, j in ipairs(self.uiPos) do
			local alpha = 255
			if self[i].found then alpha = 75 end
			g.setColor(255, 255, 255, alpha)
			g.draw(game.tilemap, game.treasureQuads[i], self.uiPos[i][1] * conf.tile.w, self.uiPos[i][2] * conf.tile.h)
		end
	end
}

function game:entering()
	self.levelOver = false
	math.randomseed(level)
	for x = 1, conf.area.w, 1 do
		self.area.tiles[x] = {}
		for y = 1, conf.area.h, 1 do
			self.area.tiles[x][y] = self.newTile()
		end
	end
	self.area.tiles[1][3].block = self.pSpawnQuad
	self.area.tiles[1][4].block = nil
	self.player.x = 1
	self.player.y = 4
	self.area.tiles[conf.area.w][4].block = self.eSpawnQuad
	local spawns = { 3, 5, 2, 6, 1 }
	for i = 1, level, 1 do
		self.area.tiles[conf.area.w][spawns[i] ].block = nil
		self.enemies[i] = { 
			x = conf.area.w,
			y = spawns[i]
		}
	end
	local block = nil
	self.extraPiece.tile = self.newTile()
	self.extraPiece.x = 0
	self.extraPiece.y = conf.area.h/2
	for i = 1, 4, 1 do
		local notPlaced = true
		self.treasure[i] = {}
		while notPlaced do
			local x = math.random(1, conf.area.w)
			local y = math.random(1, conf.area.h)
			if not self.area.tiles[x][y].block and (x ~= self.player.x and y ~= self.player.y) then
				local found = false
				for j = 1, #self.treasure, 1 do
					if self.treasure[j].x == x and self.treasure[j].y == y then
						found = true
						break
					end
				end

				if not found then
					self.treasure[i] = {
						x = x,
						y = y, -- only for spawning
						quad = self.treasureQuads[i],
						found = false
					}
					self.area.tiles[x][y].treasure = self.treasure[i]
					notPlaced = false
				end
			end
		end
	end
end

local function updateSize(object, dt)
	object.s = object.s + 0.4 * object.d * dt
	if object.s < 0.85 then
		object.d = -object.d
		object.s = 0.85
	elseif object.s > 1.15 then
		object.d = -object.d
		object.s = 1.15
	end
end

local function resetSize(object)
	object.s = 1
	object.d = -1
end

function game:update(dt)
	self.timer:update(dt)
	-- only for graphics
	if self.selected == self.OBJECTS.PLAYER then
		updateSize(self.player, dt)
		resetSize(self.extraPiece)
	else
		resetSize(self.player)
		updateSize(self.extraPiece, dt)
	end
end

function game:draw()
	preDraw()
	g.setBackgroundColor(100, 100, 100)
	g.setColor(255, 255, 255)
	g.draw(self.bg, 0, 0)
	game.treasure:draw()
	game.extraPiece:draw()
	g.translate(conf.tile.w, conf.tile.h)
	game.area:draw()
	game.player:draw()
	game.enemies:draw()
	postDraw()
end

return game
