local g = love.graphics

DIRECTIONS = { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3 }
OBJECTS = { PLAYER = 0, EXTRAPIECE_V = 1, EXTRAPIECE_H = 2 }

conf = {
	tile = {
		w = 64,
		h = 64
	},
	area = {
		w = 10,
		h = 6
	},
	keys = {
		change = { "space", 
			function()
				if game.selected == OBJECTS.PLAYER then 
					game.selected = OBJECTS.EXTRAPIECE_H 
				elseif game.selected == OBJECTS.EXTRAPIECE_H then
					if game.extraPiece.x == 0 or game.extraPiece.x == conf.area.w + 1 then
						game.extraPiece.y = 0
						game.extraPiece.x = 1
					elseif game.extraPiece.y == 0 or game.extraPiece.y == conf.area.h + 1 then
						game.extraPiece.x = 0
						game.extraPiece.y = 1
					end
					game.selected = OBJECTS.EXTRAPIECE_V
				else
					game.selected = OBJECTS.PLAYER 
				end
			end
		},
		scaleUp = { "+",
			function()
				conf.scale = 2 * conf.scale
				setWindowSize()
			end
		},
		scaledown = { "-",
			function()
				conf.scale = 0.5 * conf.scale
				setWindowSize()
			end
		},
		moveUp = { "up",
			function()
				handleMove(DIRECTIONS.UP)
			end
		},
		moveDown = { "down",
			function()
				handleMove(DIRECTIONS.DOWN)
			end
		},
		moveRight = { "right", 
			function()
				handleMove(DIRECTIONS.RIGHT)
			end
		},
		moveLeft = { "left",
			function()
				handleMove(DIRECTIONS.LEFT)
			end
		}
	},
	scale = 1
}

game = {
	selected = OBJECTS.PLAYER,
	player = {
		x = 1,
		y = 1,
		s = 1,
		d = -1,
		dir = DIRECTIONS.DOWN,
		draw = function(self)
			g.setColor(255, 255, 255)
			g.rectangle("fill", 12 + (self.x - 1) * conf.tile.w, 12 + (self.y - 1) * conf.tile.h, 40 * self.s, 40 * self.s)
		end,
		move = function(self, direction, tiles)
			local delta = {}
			delta[DIRECTIONS.UP] = { 0, -1 } 
			delta[DIRECTIONS.DOWN] = { 0, 1 }
			delta[DIRECTIONS.RIGHT] = { 1, 0 } 
			delta[DIRECTIONS.LEFT] = { -1, 0 } 
		
			local nX = self.x + delta[direction][1]
			local nY = self.y + delta[direction][2]
			if nX > 0 and nY > 0 and nX <= conf.area.w and nY <= conf.area.h and not tiles[nX][nY][2] then
				self.x = nX
				self.y = nY

				if tiles[nX][nY][3] and not tiles[nX][nY][3].found then 
					tiles[nX][nY][3].found = true 
					for i, j in ipairs(game.treasure) do
						if not j.found then break end
						if i == #game.treasure then
							print("you win")
							love.event.quit()
						end
					end
				end
			end
		end
	},
	enemy = {
		x = 10,
		y = 6,
		dir = DIRECTIONS.UP,
		draw = function(self)
			g.setColor(0, 0, 0)
			g.rectangle("fill", 12 + (self.x - 1) * conf.tile.w, 12 + (self.y - 1) * conf.tile.h, 40, 40)
		end,
		move = function(self, player, tiles)
			-- use A*, same naming as with the wikipedia pseudocode
			local reconstructPath = function(cameFrom, current)
				while cameFrom[current[1] ][current[2] ] do
					if cameFrom[current[1] ][current[2] ][1] == self.x and cameFrom[current[1] ][current[2] ][2] == self.y then break end
					current = cameFrom[current[1] ][current[2] ]
					-- we actually don't need the whole path!
				end
				return current -- just gives us the (second) last one
			end
			local aStar = function()
				local closedSet = {}
				local openSet = { { self.x, self.y } }
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
				gScore[self.x][self.y] = 0
				local fScore = {}
				for x = 1, conf.area.w, 1 do
					fScore[x] = {}
					for y = 1, conf.area.h, 1 do
						fScore[x][y] = math.huge
					end
				end
				fScore[self.x][self.y] = math.abs(self.x - player.x) + math.abs(self.y - player.y)
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
							if math.abs(dx) + math.abs(dy) == 1 and current[1] + dx > 0 and current[1] + dx <= conf.area.w and current[2] + dy > 0 and current[2] + dy <= conf.area.h and not tiles[current[1] + dx][current[2] + dy][2] then
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

			local nextMove = aStar()

			if nextMove then
				self.x = nextMove[1]
				self.y = nextMove[2]
			end

			if self.x == player.x and self.y == player.y then
				print("you lose")
				love.event.quit()
			end
		end
	},
	extraPiece = {
		x = 0,
		y = 3,
		s = 1,
		d = -1,
		tile = nil,
		draw = function(self, direction, tiles, player, enemy)
			g.setColor(self.tile[1], self.tile[1], self.tile[1])
			if self.tile[2] then g.setColor(self.tile[1], self.tile[1], 255) end
			g.rectangle("fill", self.x * conf.tile.w, self.y * conf.tile.h, conf.tile.w * self.s, conf.tile.h * self.s)
		
			if self.tile[3] and not self.tile[3].found then
				g.setColor(self.tile[3].i*50, 0, 0)
				g.rectangle("fill", self.x * conf.tile.w, self.y * conf.tile.h, conf.tile.w * self.s, conf.tile.h * self.s)
			end
		end,
		move = function(self, direction, tiles, player, enemy)
			moveTaken = false -- this whole block needs refactoring :-l
			if self.x == 0 and direction == DIRECTIONS.LEFT then
				self.x = conf.area.w + 1
			elseif self.x == conf.area.w + 1 and direction == DIRECTIONS.RIGHT then
				self.x = 0
			elseif self.y == 0 and direction == DIRECTIONS.UP then
				self.y = conf.area.h + 1
			elseif self.y == conf.area.h + 1 and direction == DIRECTIONS.DOWN then
				self.y = 0	
			elseif self.x == 0 and direction == DIRECTIONS.RIGHT and (player.y ~= self.y or player.x ~= conf.area.w) and (enemy.y ~= self.y or enemy.x ~= conf.area.w) then
				moveTaken = true
				local temp = { tiles[conf.area.w][self.y][1], tiles[conf.area.w][self.y][2], tiles[conf.area.w][self.y][3] }
				for i = conf.area.w, 2, -1 do
					tiles[i][self.y] = tiles[i - 1][self.y]
				end
				tiles[1][self.y] = self.tile
				self.tile = temp
				self.x = conf.area.w + 1
				if player.y == self.y then player.x = player.x + 1 end
				if enemy.y == self.y then enemy.x = enemy.x + 1 end
			elseif self.x == conf.area.w + 1 and direction == DIRECTIONS.LEFT and (player.y ~= self.y or player.x ~= 1) and (enemy.y ~= self.y or enemy.x ~= 1) then
				moveTaken = true
				local temp = { tiles[1][self.y][1], tiles[1][self.y][2], tiles[1][self.y][3] }
				for i = 1, conf.area.w - 1, 1 do
					tiles[i][self.y] = tiles[i + 1][self.y]
				end
				tiles[conf.area.w][self.y] = self.tile
				self.tile = temp
				self.x = 0
				if player.y == self.y then player.x = player.x - 1 end
				if enemy.y == self.y then enemy.x = enemy.x - 1 end
			elseif self.y == 0 and direction == DIRECTIONS.DOWN and (player.x ~= self.x or player.y ~= conf.area.h) and (enemy.x ~= self.x or enemy.y ~= conf.area.h) then
				moveTaken = true
				local temp = { tiles[self.x][conf.area.h][1], tiles[self.x][conf.area.h][2], tiles[self.x][conf.area.h][3] }
				for i = conf.area.h, 2, -1 do
					tiles[self.x][i] = tiles[self.x][i - 1]
				end
				tiles[self.x][1] = self.tile
				self.tile = temp
				self.y = conf.area.h + 1
				if player.x == self.x then player.y = player.y + 1 end
				if enemy.x == self.x then enemy.y = enemy.y + 1 end
			elseif self.y == conf.area.h + 1 and direction == DIRECTIONS.UP and (player.x ~= self.x or player.y ~= 1) and (enemy.x ~= self.x or enemy.y ~= 1) then
				moveTaken = true
				local temp = { tiles[self.x][1][1], tiles[self.x][1][2], tiles[self.x][1][3] }
				for i = 1, conf.area.h - 1, 1 do
					tiles[self.x][i] = tiles[self.x][i + 1]
				end
				tiles[self.x][conf.area.h] = self.tile
				self.tile = temp
				self.y = 0
				if player.x == self.x then player.y = player.y - 1 end
				if enemy.x == self.x then enemy.y = enemy.y - 1 end
			elseif self.x == 0 or self.x == conf.area.w + 1 then
				if direction == DIRECTIONS.UP and self.y > 1 then
					self.y = self.y - 1
				elseif direction == DIRECTIONS.DOWN and self.y < conf.area.h then
					self.y = self.y + 1
				end
			elseif self.y == 0 or self.y == conf.area.h + 1 then
				if direction == DIRECTIONS.LEFT and self.x > 1 then
					self.x = self.x - 1
				elseif direction == DIRECTIONS.RIGHT and self.x < conf.area.w then
					self.x = self.x + 1
				end
			end
			return moveTaken
		end
	},
	area = {
		tiles = {},
		draw = function(self)
			for x = 1, conf.area.w, 1 do
				for y = 1, conf.area.h, 1 do
					local c = self.tiles[x][y][1]
					g.setColor(c, c, c)
					if self.tiles[x][y][2] then g.setColor(c, 255, 255) end
					g.rectangle("fill", (x - 1) * conf.tile.w, (y - 1) * conf.tile.h, conf.tile.w, conf.tile.h)
			
					if self.tiles[x][y][3] and not self.tiles[x][y][3].found then
						g.setColor(self.tiles[x][y][3].i*50, 0, 0)
						g.rectangle("fill", (x - 1) * conf.tile.w, (y - 1) * conf.tile.h, conf.tile.w, conf.tile.h)
					end
				end

			end
		end
	},
	treasure = {
		{}, -- treasures will have position, image and a boolean for found
		{}, -- these are here just to remind me :)
		{},
		{}, 
		uiPos = { { 0, 0 }, { 0, conf.area.h + 1 }, { conf.area.w + 1, 0 }, { conf.area.w + 1, conf.area.h + 1 } },
		draw = function(self)
			for i, j in ipairs(self.uiPos) do
				if not self[i].found then
					g.setColor(i*50, 0, 0)
					g.rectangle("fill", j[1] * conf.tile.w, j[2] * conf.tile.h, conf.tile.w, conf.tile.h)
				end
			end
		end
	}
}

function handleMove(direction)
	success = false

	if game.selected == OBJECTS.PLAYER then
		game.player:move(direction, game.area.tiles)
		success = true
	else
		success = game.extraPiece:move(direction, game.area.tiles, game.player, game.enemy)
	end

	if success then
		game.enemy:move(game.player, game.area.tiles)
	end
end

function setWindowSize()
	love.window.setMode(conf.scale * (conf.area.w * conf.tile.w + 2 * conf.tile.w), conf.scale * (conf.area.h * conf.tile.h + 2 * conf.tile.h))
end

function love.load()
	setWindowSize()

	for x = 1, conf.area.w, 1 do
		game.area.tiles[x] = {}
		for y = 1, conf.area.h, 1 do
			local bool = false
			if math.random() < 0.1 then bool = true end
			game.area.tiles[x][y] = { math.random(100, 150), bool, false }
		end
	end
	for i = 1, 4, 1 do
		local notPlaced = true
		while notPlaced do
			local x = math.random(1, conf.area.w)
			local y = math.random(1, conf.area.h)
			if not game.area.tiles[x][y][2] and (x ~= game.player.x and y ~= game.player.y) and (x ~= game.enemy.x and y ~= game.enemy.y) then
				for j = 1, #game.treasure, 1 do
					if game.treasure[j].x == x and game.treasure[j].y == y then
						break
					elseif j == #game.treasure then
						game.treasure[i] = {
							i = i,
							found = false
						}
						game.area.tiles[x][y][3] = game.treasure[i]
						notPlaced = false
					end
				end
			end
		end
	end
	local bool = false; if math.random() < 0.25 then bool = true end
	game.extraPiece.tile = { math.random(100, 150), bool, false }
end

function updateSize(object, dt)
	object.s = object.s + 0.4 * object.d * dt
	if object.s < 0.75 then
		object.d = -object.d
		object.s = 0.75
	elseif object.s > 1 then
		object.d = -object.d
		object.s = 1
	end
end

function resetSize(object)
	object.s = 1
	object.d = -1
end

function love.update(dt)
	-- only for graphics
	if game.selected == OBJECTS.PLAYER then
		updateSize(game.player, dt)
		resetSize(game.extraPiece)
	else
		resetSize(game.player)
		updateSize(game.extraPiece, dt)
	end
end

function love.keypressed(key, scanCode, isRepeat)
	for i,j in pairs(conf.keys) do
		if key == j[1] then 
			j[2]() 
			break
		end
	end
end

function love.draw()
	g.push()
	g.scale(conf.scale, conf.scale)
	game.treasure:draw()
	game.extraPiece:draw()
	g.translate(conf.tile.w, conf.tile.h)
	game.area:draw()
	game.player:draw()
	game.enemy:draw()
	g.pop()
end
