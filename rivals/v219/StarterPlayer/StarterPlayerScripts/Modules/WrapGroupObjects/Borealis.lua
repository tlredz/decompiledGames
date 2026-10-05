local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._gradient1 = {}
	self._gradient2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 4

	for _, v2 in pairs(self._gradient1) do
		local offsetStudsU = v / 2.5 % v2.StudsPerTileU

		if v2.Face == Enum.NormalId.Top or v2.Face == Enum.NormalId.Front then
			offsetStudsU = -offsetStudsU
		end

		v2.OffsetStudsU = offsetStudsU
		v2.OffsetStudsV = math.sin(v * 4) / 14
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Gradient" then
			table.insert(self._gradient1, extraObject)
		elseif extraObject.Name == "Gradient2" then
			table.insert(self._gradient2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object