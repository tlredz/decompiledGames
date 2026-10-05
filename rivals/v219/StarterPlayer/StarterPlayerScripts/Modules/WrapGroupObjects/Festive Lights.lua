local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._last_remainder = nil
	self._textures = {
		{},
		{},
		{}
	}
	self:_Init()
	return self
end

function object:Update(_)
	local last_remainder = math.floor(tick() * 1) % #self._textures + 1

	if last_remainder == self._last_remainder then
		return
	end

	self._last_remainder = last_remainder

	for k, _texture in pairs(self._textures) do
		local transparency = k == self._last_remainder and 0 or 1

		for _, v3 in pairs(_texture) do
			v3.Transparency = transparency
		end
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "SolidRed" or extraObject.Name == "RedLightsInner" then
			table.insert(self._textures[1], extraObject)
		elseif extraObject.Name == "SolidYellow" or extraObject.Name == "YellowLightsInner" then
			table.insert(self._textures[2], extraObject)
		elseif extraObject.Name == "SolidGreen" or extraObject.Name == "GreenLightsInner" then
			table.insert(self._textures[3], extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object