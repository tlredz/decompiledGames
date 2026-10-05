local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._hearts1 = {}
	self._hearts2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 4

	for _, v2 in pairs(self._hearts1) do
		v2.OffsetStudsV = v % v2.StudsPerTileV
		v2.OffsetStudsU = v / 3 % v2.StudsPerTileU
	end

	for _, v2 in pairs(self._hearts2) do
		v2.OffsetStudsV = v / 2.5 % v2.StudsPerTileV
		v2.OffsetStudsU = v / 7 % v2.StudsPerTileU
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Hearts" then
			table.insert(self._hearts1, extraObject)
		elseif extraObject.Name == "Hearts2" then
			table.insert(self._hearts2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object