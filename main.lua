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
					local temp = game.extraPiece.x
					game.extraPiece.x = math.min(game.extraPiece.y, conf.area.w - 1)
					game.extraPiece.y = math.min(temp, conf.area.h - 1)
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
			self.x = self.x - 1
		end
	},
	extraPiece = {
		x = 0,
		y = 3,
		s = 1,
		d = -1,
		image = nil,
		draw = function(self, direction, tiles, player, enemy)
			g.setColor(self.image, self.image, self.image)
			g.rectangle("fill", self.x * conf.tile.w, self.y * conf.tile.h, conf.tile.w * self.s, conf.tile.h * self.s)
		end,
		move = function(self, direction, tiles, player, enemy)
			if self.x == 0 and direction == DIRECTIONS.LEFT then
				self.x = conf.area.w + 1
			elseif self.x == conf.area.w + 1 and direction == DIRECTIONS.RIGHT then
				self.x = 0
			elseif self.y == 0 and direction == DIRECTIONS.UP then
				self.y = conf.area.h + 1
			elseif self.y == conf.area.h + 1 and direction == DIRECTIONS.DOWN then
				self.y = 0
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
		end
	},
	area = {
		tiles = {},
		draw = function(self)
			for x = 1, conf.area.w, 1 do
				for y = 1, conf.area.h, 1 do
					local c = self.tiles[x][y][1]
					g.setColor(c, c, c)
					if self.tiles[x][y][2] then g.setColor(c, c, 255) end
					g.rectangle("fill", (x - 1) * conf.tile.w, (y - 1) * conf.tile.h, conf.tile.w, conf.tile.h)
				end

			end
		end
	},
	treasure = {
		{}, -- treasures will have position, image and a boolean for found
		{},
		{},
		{}, 
		uiPos = { { 0, 0 }, { 0, conf.area.h + 1 }, { conf.area.w + 1, 0 }, { conf.area.w + 1, conf.area.h + 1 } },
		draw = function(self)
			for i, j in ipairs(self.uiPos) do
				g.setColor(i*50, 0, 0)
				g.rectangle("fill", j[1] * conf.tile.w, j[2] * conf.tile.h, conf.tile.w, conf.tile.h)
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
			bool = false
			if math.random() < 0.25 then bool = true end
			game.area.tiles[x][y] = { math.random(100, 150), bool }
		end
	end	
	game.extraPiece.image = math.random(100, 150)
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
