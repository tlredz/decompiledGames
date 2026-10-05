local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._moving_textures = {}
	self:_Init()
	return self
end

function object:Update(_)
	for k, _moving_texture in pairs(self._moving_textures) do
		k.OffsetStudsU = tick() * _moving_texture.Speed * _moving_texture.Direction.X % k.StudsPerTileU
		k.OffsetStudsV = tick() * _moving_texture.Speed * _moving_texture.Direction.Y % k.StudsPerTileV
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		local speed = extraObject:GetAttribute("Speed")
		local direction = extraObject:GetAttribute("Direction")

		if speed and direction then
			self._moving_textures[extraObject] = {
				Speed = speed,
				Direction = direction
			}
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object