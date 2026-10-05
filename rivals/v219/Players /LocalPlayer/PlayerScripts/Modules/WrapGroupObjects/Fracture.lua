local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._shatter1 = {}
	self._shatter2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = math.sin(workspace:GetServerTimeNow() * 1.5) / 7 + 0.75

	for _, v2 in pairs(self._shatter1) do
		v2.StudsPerTileU = v + 1.574 + Random.new():NextNumber(-0.02, 0.02)
		v2.StudsPerTileV = v + 1.574 + Random.new():NextNumber(-0.02, 0.02)
	end

	for _, v2 in pairs(self._shatter2) do
		v2.StudsPerTileU = v / 1.75 + 2.5 + Random.new():NextNumber(-0.01, 0.01)
		v2.StudsPerTileV = v / 1.75 + 2.5 + Random.new():NextNumber(-0.01, 0.01)
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Shatter" then
			table.insert(self._shatter1, extraObject)
		elseif extraObject.Name == "Shatter2" then
			table.insert(self._shatter2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object