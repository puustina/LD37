local gameover = {}
gameover.timer = Timer.new()

local g = love.graphics

function gameover:init()
	self.text = "There there, it was just a nightmare, now go back to sleep, will you?"
end

function gameover:entered()
	self.timer:add(2, function() GS.switch(game) end)
end

function gameover:draw()
	preDraw()
	g.print(self.text, 0, 0)
	postDraw()
end

function gameover:update(dt)
	self.timer:update(dt)	
end

return gameover
