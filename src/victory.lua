local victory = {}
victory.timer = Timer.new()

local g = love.graphics

function victory:entering()
	self.text = "Nights survived: " .. level
	local temp = MAXLEVEL - level
	if temp == 1 then 
		self.text2 = temp .. " night remains..!"
	else
		self.text2 = temp .. " nights remain..."
	end
	level = level + 1
end

function victory:entered()
	self.timer:add(3, function() GS.switch(game) end)
end

function victory:draw()
	preDraw()
	g.print(self.text, 0, 0)
	g.print(self.text2, 0, 20)
	postDraw()
end

function victory:update(dt)
	self.timer:update(dt)	
end

return victory
