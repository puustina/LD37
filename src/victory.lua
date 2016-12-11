local victory = {}
victory.timer = Timer.new()

local g = love.graphics

victory.bg = g.newImage("assets/victory.png")
victory.font = g.newFont(20)

function victory:entering()
	g.setFont(self.font)
	self.text = "Nightmares survived: " .. level
	local temp = MAXLEVEL - level
	if temp == 1 then 
		self.text2 = temp .. " nightmare remains..!"
	else
		self.text2 = temp .. " nightmares remain..."
	end
	level = level + 1
end

function victory:entered()
	self.timer:add(2, function() if level == MAXLEVEL + 1 then GS.switch(won) else GS.switch(game) end end)
end

function victory:draw()
	preDraw()
	g.draw(self.bg, 0, 0)
	g.print(self.text, 20, 0)
	g.print(self.text2, 20, 30)
	postDraw()
end

function victory:update(dt)
	self.timer:update(dt)	
end

return victory
