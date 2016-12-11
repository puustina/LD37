local won = {}
local g = love.graphics

won.bg = g.newImage("assets/won.png")
won.font = g.newFont(20)

function won:init()
	self.text = "The nightmare is finally over!"
	self.text2 = "Thanks for playing. Time to rate & comment."
end

function won:entering()
	g.setFont(self.font)
end

function won:draw()
	preDraw()
	g.draw(self.bg, 0, 0)
	g.setColor(0, 0, 0)
	local h = select(2, g.getDimensions())
	g.rectangle("fill", 0, h - 60, select(1, g.getDimensions()), h)
	g.setColor(255, 255, 255)
	g.print(self.text, 250, h - 50)
	g.print(self.text2, 150, h - 30)
	postDraw()
end

return won
