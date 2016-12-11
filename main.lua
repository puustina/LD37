level = 1
MAXLEVEL = 5

Timer = require "lib.timer"
GS = require "lib.venus"

local g = love.graphics

require "src.gameconf"
setWindowSize()
local splash = require "src.splash"
menu = require "src.menu"
game = require "src.game"
gameover = require "src.gameover"
victory = require "src.victory"
won = require "src.won"

function love.load()
	love.audio.setVolume(0.5)
	GS.timer = Timer
	GS.effect = "fade"
	GS.duration = 1
	GS.registerEvents()
	GS.switch(splash)
end

function love.update(dt)
	Timer.update(dt)
end

function love.keypressed(key, scanCode, isRepeat)
	for i,j in pairs(conf.keys) do
		if key == j[1] then 
			j[2]() 
			break
		end
	end
end

function preDraw()
	g.push()
	g.scale(conf.scale, conf.scale)
end

function postDraw()
	g.pop()
end
