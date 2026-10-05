local Players = game:GetService("Players")
local Charm = require(Players.LocalPlayer.PlayerScripts.Modules.Charm)
local v = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 176, 0), Color3.fromRGB(0, 255, 0) }
local object = setmetatable({}, Charm)
object.__index = object

function object.new(...)
	local self = setmetatable(Charm.new(...), object)
	self._light_color_index = 0
	self._light_part = self.Model:WaitForChild("Extra"):WaitForChild("Light")
	self:_Init()
	return self
end

function object:Update(p)
	Charm.Update(self, p)
	local light_color_index = math.floor(tick() * 1) % #v

	if light_color_index == self._light_color_index then
		return
	end

	self._light_color_index = light_color_index
	self._light_part.Color = v[self._light_color_index + 1]
end

function object:_Init() end

return object