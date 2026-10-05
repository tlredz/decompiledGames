local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._textures1 = {}
	self._textures2 = {}
	self._random = Random.new()
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 4

	for _, v2 in pairs(self._textures1) do
		v2.OffsetStudsV = v % 0.6
		v2.OffsetStudsU = math.sin(v * 10) / 14 + self._random:NextNumber(-0.01, 0.01)
	end

	for _, v2 in pairs(self._textures2) do
		v2.OffsetStudsU = v % 0.7
		v2.OffsetStudsV = v % 0.5
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Souls" then
			table.insert(self._textures1, extraObject)
		elseif extraObject.Name == "Clouds2" then
			table.insert(self._textures2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object