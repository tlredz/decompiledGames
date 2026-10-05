local Blueprint = {}
Blueprint.__index = Blueprint
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
game:GetService("RunService")
game:GetService("ContextActionService")

function Blueprint.new(model, realModel)
	local self = setmetatable({}, Blueprint)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	return self
end

function Blueprint:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

local v = {}

function Blueprint.Activate(data)
	local realModel = data.RealModel

	if not realModel or v[realModel] then
		return
	end

	v[realModel] = true
	task.spawn(function()
		wait(1.6)
		v[realModel] = false
	end)
	local attemptPlaceItem = Client.StructurePlacementClient.AttemptPlaceItem(data.RealModel)

	if attemptPlaceItem and attemptPlaceItem.Success then
		if realModel:GetAttribute("Charges") and realModel:GetAttribute("Charges") > 1 then
			if data.Equipped then
				task.spawn(function()
					local child = game.ReplicatedStorage.Assets.StructureTemplates:WaitForChild(data.StructureName)

					if not data.Equipped then
						return
					end

					Client.StructurePlacementClient.StartPlacingItem(child)
				end)
			end
		else
			realModel.Parent = game.ReplicatedStorage.TempStorage
			task.delay(2, function()
				if realModel.Parent then
					realModel.Parent = localPlayer.Inventory
				end
			end)
		end
	end

	return Enum.ContextActionResult.Sink
end

function Blueprint.Deactivate(_) end

function Blueprint:OnEquip()
	self.Equipped = true
	task.spawn(function()
		local child = game.ReplicatedStorage.Assets.StructureTemplates:WaitForChild(self.StructureName)
		task.spawn(function()
			Client.StructureInterfaceClient.OpenMenu(self.RealModel, child)
		end)

		if not self.Equipped then
			return
		end

		Client.StructurePlacementClient.StartPlacingItem(child)
		Client.GuiButtonHandler.ShowButton("Place")
	end)
end

function Blueprint:OnUnequip()
	if self.ChargesEvent then
		self.ChargesEvent:Disconnect()
		self.ChargesEvent = nil
	end

	Client.GuiButtonHandler.HideButton("Place")
	self.Equipped = false
	Client.Interface.TrapCharges.Visible = false
	Client.StructurePlacementClient.StopPlacingItem()
	Client.StructureInterfaceClient.CloseMenu()
end

return Blueprint