local menu = {}

local g = love.graphics
menu.font = g.newFont(16)
menu.titlefont = g.newFont(20)

function menu:init()
	self.text = "LD37 - Dreadroom - MENU"
	self.keycount = 0
	for i, j in pairs(conf.keys) do self.keycount = self.keycount + 1 end
	self.selected = self.keycount + 1
	self.lineLength = 0
	self.wait = 1
end

function menu:entered()
end

function menu:handleUp()
	if self.waitForNewKey then return end
	love.audio.play(game.change)
	self.selected = self.selected - 1
	if self.selected == 0 then self.selected = self.keycount + 1 end
end

function menu:handleDown()
	if self.waitForNewKey then return end
	love.audio.play(game.change)
	self.selected = self.selected + 1
	if self.selected == self.keycount + 2 then self.selected = 1 end
end

function menu:handleConfirm()
	if self.waitForNewKey then return end
	if self.selected == self.keycount + 1 then 
		for i, j in pairs(conf.keys) do
			if j[1] == "<unbound>" then
				love.audio.play(game.cantpush)
				return
			end
		end
		love.audio.play(game.pickup)
		GS.switch(game) 
	else
		love.audio.play(game.pickup)
		self.wait = 1
		self.waitForNewKey = true
		local index = 1
		for i, j in pairs(conf.keys) do
			if index == self.selected then
				j[1] = "<press key>"
				break
			end
			index = index + 1
		end
	end
end

function menu:keypressed(key, scanCode, isRepeat)
	if self.waitForNewKey and self.wait <= 0 then
		self.waitForNewKey = false
		local index = 1
		for i, j in pairs(conf.keys) do 
			if j[1] == key then j[1] = "<unbound>" end
			if index == self.selected then
				j[1] = key
			end
			index = index + 1
		end
	end
end

function menu:draw()
	preDraw()
	g.setFont(self.titlefont)
	g.print(self.text, 10, 10)

	local i = 1
	local canStart = true
	g.setFont(self.font)
	for _, j in pairs(conf.keys) do
		g.print(j[1] .. " : " .. j[3], 20, 25 + i * 25)
		if j[1] == "<unbound>" then canStart = false end
		if i == self.selected then
			g.line(20, 45 + i * 25, 20 + self.lineLength, 45 + i * 25)
		end
		i = i + 1
	end
	g.setFont(self.titlefont)
	if self.selected == self.keycount + 1 then g.line(20, 90 + self.keycount * 25, 20 + self.lineLength, 90 + self.keycount * 25) end
	local sLine = "Start"
	if not canStart then sLine = sLine .. " (Cannot start: Unbound key!)" end
	g.print(sLine, 20, 70 + self.keycount * 25)
	postDraw()
end

function menu:update(dt)
	self.wait = self.wait - 1
	self.lineLength = (self.lineLength + 600 * dt)%600
end

return menu
