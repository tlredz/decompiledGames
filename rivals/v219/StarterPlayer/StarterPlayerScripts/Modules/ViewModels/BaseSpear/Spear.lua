local Players = game:GetService("Players")
local BaseSpear = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseSpear)
local object = setmetatable({}, BaseSpear)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseSpear.new(...), object)
	self:_Init()
	return self
end

function object:_Setup()
	for i = 1, 1e999 do
		local child = self.ItemModel:WaitForChild("Body"):FindFirstChild("MeshPart" .. i)

		if not child then
			break
		end

		self:_RegisterAmmoVisual(child, 1)
	end
end

function object:_Init()
	self:_Setup()
end

return object