local menu = {}

local g = love.graphics

function menu:init()
	self.text = "menu"
	self.selected = 0
end

function menu:entered()
end

function menu:draw()
	preDraw()
	g.print(self.text, 10, 10)

	local i = 0
	for _, j in pairs(conf.keys) do
		g.print(j[1] .. " : " .. j[3], 20, 30 + i * 20)
		if i == self.selected then
			g.line(20, 30 + i * 20 + 15, 600, 30 + i * 20 + 15)
		end
		i = i + 1
	end
	postDraw()
end

return menu
