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
		scaleUp = { "+",
			function()
				conf.scale = 2 * conf.scale
				setWindowSize()
			end,
			"Double the resolution"
		},
		scaledown = { "-",
			function()
				conf.scale = 0.5 * conf.scale
				setWindowSize()
			end,
			"Halve the resolution"
		},
		change = { "space", 
			function()
				if GS.current == game then
					if game.selected == game.OBJECTS.PLAYER then 
						game.selected = game.OBJECTS.EXTRAPIECE 
					else
						game.selected = game.OBJECTS.PLAYER 
					end
				end
			end,
			"Change between the boy and the tile"
		},
		moveUp = { "up",
			function()
				if GS.current == game then game.handleMove(game.DIRECTIONS.UP) end
			end,
			"Move up in the menu. Move the boy up or push tile up"
		},
		moveDown = { "down",
			function()
				if GS.current == game then game.handleMove(game.DIRECTIONS.DOWN) end
			end,
			"Move down in the menu. Move the boy down or push tile down"
		},
		moveRight = { "right", 
			function()
				if GS.current == game then game.handleMove(game.DIRECTIONS.RIGHT) end
			end,
			"Move the boy right or push tile right"
		},
		moveLeft = { "left",
			function()
				if GS.current == game then game.handleMove(game.DIRECTIONS.LEFT) end
			end,
			"Move the boy left or push tile left"
		},
		movePieceUp = { "w",
			function()
				if GS.current == game then game.handleExtraPieceMove(game.DIRECTIONS.UP) end
			end,
			"Move the extra piece up"
		},
		movePieceDown = { "s",
			function()
				if GS.current == game then game.handleExtraPieceMove(game.DIRECTIONS.DOWN) end
			end,
			"Move the extra piece down"
		},
		movePieceLeft = { "a",
			function()
				if GS.current == game then game.handleExtraPieceMove(game.DIRECTIONS.LEFT) end
			end,
			"Move the extra piece left"
		},
		movePieceRight = { "d",
			function()
  				if GS.current == game then game.handleExtraPieceMove(game.DIRECTIONS.RIGHT) end
			end,
			"Move the extra piece right"
		},
		confirm = { "return",
			function()
				if GS.current == game then 
					GS.switch(victory) 
				elseif GS.current == menu then
					GS.switch(game)
				end
			end,
			"Confirm"
		}
		
	},
	scale = 1
}

function setWindowSize()
	love.window.setMode(conf.scale * (conf.area.w * conf.tile.w + 2 * conf.tile.w), conf.scale * (conf.area.h * conf.tile.h + 2 * conf.tile.h))
end
