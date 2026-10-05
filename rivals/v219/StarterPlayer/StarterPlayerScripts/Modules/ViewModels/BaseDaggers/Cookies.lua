local Players = game:GetService("Players")
local BaseDaggers = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseDaggers)
local object = setmetatable({}, BaseDaggers)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseDaggers.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	for k, childName in pairs({ "LeftBody", "RightBody" }) do
		for i = 1, 7 do
			self:_RegisterAmmoVisual(self.ItemModel:WaitForChild(childName):WaitForChild("MeshPart" .. i), k)
		end
	end
end

return object