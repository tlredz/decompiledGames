local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._textures1 = {}
	self._textures2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 8
	local transparency = math.clamp(math.sin(v * 24) / 2 + 0.25, 0, 1)
	local transparency2 = math.clamp(math.sin((v + 3.5342917352885173) * 24) / 2 + 0.25, 0, 1)
	local v4 = (math.sin(v) + 4) / 2

	for _, v5 in pairs(self._textures1) do
		v5.StudsPerTileU = v4
		v5.StudsPerTileV = v4
		v5.Transparency = transparency
	end

	for _, v5 in pairs(self._textures2) do
		v5.StudsPerTileU = v4
		v5.StudsPerTileV = v4
		v5.Transparency = transparency2
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "RedStars" or extraObject.Name == "BlueStars2" then
			table.insert(self._textures1, extraObject)
		elseif extraObject.Name == "BlueStars" or extraObject.Name == "RedStars2" then
			table.insert(self._textures2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object