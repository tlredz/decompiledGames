local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._fire1 = {}
	self._fire2 = {}
	self._beams = {}
	self._sparks = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 4
	local transparency = math.clamp(math.sin(v * 12) / 3 + 0.5, 0, 1)
	local transparency2 = math.clamp(math.sin((v + 3.5342917352885173) * 12) / 3 + 0.5, 0, 1)

	for _, v4 in pairs(self._fire1) do
		v4.Transparency = transparency
	end

	for _, v4 in pairs(self._fire2) do
		v4.Transparency = transparency2
	end

	for _, _beam in pairs(self._beams) do
		_beam.Transparency = math.sin(v * 6) / 10 + 0.8
	end

	for _, _spark in pairs(self._sparks) do
		_spark.OffsetStudsU = v / 4 % _spark.StudsPerTileU + math.sin(v * 9) / 64
		_spark.OffsetStudsV = v / 2 % _spark.StudsPerTileV
		_spark.Transparency = math.sin(v * 8) / 10 + 0.2
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Fire1" then
			table.insert(self._fire1, extraObject)
		elseif extraObject.Name == "Fire2" then
			table.insert(self._fire1, extraObject)
		elseif extraObject.Name == "Beam" then
			table.insert(self._beams, extraObject)
		elseif extraObject.Name == "Sparks1" then
			table.insert(self._sparks, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object