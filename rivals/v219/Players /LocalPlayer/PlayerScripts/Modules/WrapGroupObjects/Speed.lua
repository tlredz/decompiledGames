local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._moving_textures = {}
	self._shift = 0
	self:_Init()
	return self
end

function object:Update(p)
	local v = math.sin(tick() * 1) ^ 20 * 0.75 + 0.25
	self._shift = (self._shift + p * v) % 0.2

	for k, _moving_texture in pairs(self._moving_textures) do
		k.OffsetStudsU = self._shift * _moving_texture
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		self._moving_textures[extraObject] = extraObject.Name == "Left" and 1 or -1
	end
end

function object:_Init()
	self:_Setup()
end

return object