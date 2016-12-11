local gameover = {}
gameover.timer = Timer.new()

local g = love.graphics
gameover.bg = g.newImage("assets/gameover.png")
gameover.font = g.newFont(20)

function gameover:init()
	self.text = "There there, it was just a nightmare. Now get back to bed will you?"
end

function gameover:entering()
	g.setFont(self.font)
end

function gameover:entered()
	self.timer:add(2, function() GS.switch(game) end)
end

function gameover:draw()
	preDraw()
	g.draw(self.bg, 0, 0)
	g.setColor(0, 0, 0)
	g.rectangle("fill", 0, select(2, g.getDimensions()) - 30, select(1, g.getDimensions()), select(2, g.getDimensions()))
	g.setColor(255, 255, 255)
	g.print(self.text, 70, select(2, g.getDimensions()) - 30)
	postDraw()
end

function gameover:update(dt)
	self.timer:update(dt)	
end

return gameover
