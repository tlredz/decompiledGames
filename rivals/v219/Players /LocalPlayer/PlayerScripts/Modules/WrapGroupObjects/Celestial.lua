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
		local v = (tick() * 0.01 + _moving_texture) % 1
		local transparency = math.sin(3.141592653589793 * v - 1.5707963267948966) ^ 20 * 0.75 + 0.25
		local v3 = 0.05 + 1.075 * v ^ 2
		k.Transparency = transparency
		k.StudsPerTileU = v3
		k.StudsPerTileV = v3
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		self._moving_textures[extraObject] = extraObject.Name == "Big" and 0.5 or 0
	end
end

function object:_Init()
	self:_Setup()
end

return object