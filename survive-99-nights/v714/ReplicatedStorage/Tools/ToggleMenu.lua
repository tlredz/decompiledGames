local ToggleMenu = {}
ToggleMenu.__index = ToggleMenu
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()

function ToggleMenu.new(model, realModel)
	local self = setmetatable({}, ToggleMenu)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	return self
end

function ToggleMenu:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function ToggleMenu.Activate(p)
	local menuName = p.MenuName
	Client.Events["Open" .. menuName]:Fire()
	Client.InventoryHandler.ClearItemFromInventory(p.RealModel)
	Client.Events.ActivateMenuTool:FireServer(p.RealModel)
	return Enum.ContextActionResult.Sink
end

function ToggleMenu.Deactivate(_) end

function ToggleMenu:OnEquip()
	self.Equipped = true
end

function ToggleMenu:OnUnequip()
	self.Equipped = false
end

return ToggleMenu