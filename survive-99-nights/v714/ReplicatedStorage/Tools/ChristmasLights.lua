local ChristmasLights = {}
ChristmasLights.__index = ChristmasLights
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
game:GetService("RunService")
game:GetService("ContextActionService")

function ChristmasLights.new(model, realModel)
	local self = setmetatable({}, ChristmasLights)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	return self
end

function ChristmasLights:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function ChristmasLights.Activate(_)
	return Enum.ContextActionResult.Sink
end

function ChristmasLights.Deactivate(_) end

function ChristmasLights:OnEquip()
	self.Equipped = true
end

function ChristmasLights:OnUnequip()
	self.Equipped = false
end

return ChristmasLights