local g = love.graphics

local splash = {}
splash.timer = Timer.new()

function splash:init()
	self.text = "storysplash"
end

function splash:entered()
	self.timer:add(1, function() GS.switch(menu) end)
end

function splash:draw()
	preDraw()
	g.print(self.text, 10, 10)
	postDraw()
end

function splash:update(dt)
	self.timer:update(dt)	
end

return splash
