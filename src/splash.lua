local g = love.graphics

local splash = {}

function splash:init()
	self.delays = { 4, 2, 2, 3, 3, 7}
	self.images = {}
	self.currImage = 1
	for i = 1, #self.delays, 1 do
		self.images[i] = g.newImage("assets/intro" .. i .. ".png")
	end
end

function splash:entered()
	self.timer = 0
end

function splash:draw()
	preDraw()
	g.draw(self.images[self.currImage], 0, 0)
	postDraw()
end

function splash:update(dt)
	self.timer = self.timer + dt
	if self.timer >= self.delays[self.currImage] then
		if self.currImage < #self.delays then
			self.currImage = self.currImage + 1
		else
			GS.switch(menu)
		end
		self.timer = 0
	end
end

return splash
