local won = {}
local g = love.graphics

function won:init()
	self.text = "The nightmare is finally over!"
	self.text2 = "Thanks for playing. Time to rate & comment."
end

function won:draw()
	preDraw()
	g.print(self.text, 0, 0)
	g.print(self.text2, 0, 20)
	postDraw()
end

return won
