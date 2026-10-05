local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._clouds1 = {}
	self._clouds2 = {}
	self._snow1 = {}
	self._snow2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v in pairs(self._clouds1) do
		v.OffsetStudsU = v.StudsPerTileU - serverTimeNow / 2 % v.StudsPerTileU
		v.OffsetStudsV = v.StudsPerTileV - serverTimeNow % v.StudsPerTileV
	end

	for _, v in pairs(self._clouds2) do
		v.OffsetStudsU = serverTimeNow / 2 % v.StudsPerTileU
		v.OffsetStudsV = v.StudsPerTileV - serverTimeNow % v.StudsPerTileV
	end

	for _, v in pairs(self._snow1) do
		v.OffsetStudsU = v.StudsPerTileU - serverTimeNow % v.StudsPerTileU
		v.OffsetStudsV = v.StudsPerTileV - serverTimeNow / 2 % v.StudsPerTileV
	end

	for _, v in pairs(self._snow2) do
		v.OffsetStudsU = serverTimeNow % v.StudsPerTileU
		v.OffsetStudsV = v.StudsPerTileV - serverTimeNow / 2 % v.StudsPerTileV
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Clouds1" then
			table.insert(self._clouds1, extraObject)
		elseif extraObject.Name == "Clouds2" then
			table.insert(self._clouds2, extraObject)
		elseif extraObject.Name == "Snow1" then
			table.insert(self._snow1, extraObject)
		elseif extraObject.Name == "Snow2" then
			table.insert(self._snow2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object