local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._sparkles1 = {}
	self._sparkles2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 4
	local transparency = math.clamp(math.sin(v * 24) / 3 + 0.5, 0, 1)
	local transparency2 = math.clamp(math.sin((v + 3.5342917352885173) * 24) / 3 + 0.5, 0, 1)

	for _, v4 in pairs(self._sparkles1) do
		v4.OffsetStudsV = v % v4.StudsPerTileV
		v4.Transparency = transparency
	end

	for _, v4 in pairs(self._sparkles2) do
		v4.OffsetStudsV = v % v4.StudsPerTileV
		v4.Transparency = transparency2
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Sparkles" then
			table.insert(self._sparkles1, extraObject)
		elseif extraObject.Name == "Sparkles2" then
			table.insert(self._sparkles2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object