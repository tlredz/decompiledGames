local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._shake_these = {}
	self:_Init()
	return self
end

function object:Update(_)
	for _, v in pairs(self._shake_these) do
		v.OffsetStudsU = (math.random() - 0.5) * 0.01
		v.OffsetStudsV = (math.random() - 0.5) * 0.01
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Wireframe" then
			table.insert(self._shake_these, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object