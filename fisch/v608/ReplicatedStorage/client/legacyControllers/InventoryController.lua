local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Signal = require(ReplicatedStorage.packages.Signal)
local Trove = require(ReplicatedStorage.packages.Trove)
local module = require("./DataController")
local inventoryReplicator = module.InventoryReplicator
local InventoryController = {}
local v = Trove.new()
InventoryController.EquippedTool = nil
InventoryController.EquippedItem = nil
InventoryController.EquippedItemId = nil
InventoryController.ToolEquipped = Signal.new()
InventoryController.ToolUnequipped = Signal.new()
InventoryController.EquippedToolChanged = Signal.new()

function InventoryController:GetItemFromLink(instance)
	local link = instance:FindFirstChild("link")

	if link and link:IsA("StringValue") then
		inventoryReplicator:WaitForLoaded()
		return inventoryReplicator:TryIndex({ "Inventory", link.Value }), link.Value
	else
		return nil, nil
	end
end

function InventoryController:CheckItem(p, value, items)
	if not p then
		return false
	end

	if value then
		if typeof(value) == "string" then
			if p.name ~= value then
				return false
			end
		elseif typeof(value) == "table" and not table.find(value, p.name) then
			return false
		end
	end

	if not items then
		return true
	end

	if not p.sub then
		return false
	end

	for k, item in items do
		if typeof(item) == "table" then
			if not table.find(item, p.sub[k]) then
				return false
			end
		elseif p.sub[k] ~= item then
			return false
		end
	end

	return true
end

function InventoryController.CheckHeldItem(_, p, p2)
	return InventoryController:CheckItem(InventoryController.EquippedItem, p, p2)
end

function InventoryController._OnChildAdd(tool)
	if not tool:IsA("Tool") then
		return
	end

	local equippedTool = InventoryController.EquippedTool
	local equippedItem = InventoryController.EquippedItem

	if tool == equippedTool then
		return
	end

	local itemFromLink, equippedItemId = InventoryController:GetItemFromLink(tool)
	InventoryController.EquippedTool = tool
	InventoryController.EquippedItem = itemFromLink
	InventoryController.EquippedItemId = equippedItemId

	if equippedTool then
		InventoryController.ToolUnequipped:Fire(equippedTool, equippedItem)
	end

	InventoryController.ToolEquipped:Fire(tool, itemFromLink)
	InventoryController.EquippedToolChanged:Fire(tool, itemFromLink)
end

function InventoryController._OnChildRemove(tool)
	if not tool:IsA("Tool") then
		return
	end

	local equippedTool = InventoryController.EquippedTool
	local equippedItem = InventoryController.EquippedItem

	if tool ~= equippedTool then
		return
	end

	InventoryController.EquippedTool = nil
	InventoryController.EquippedItem = nil
	InventoryController.EquippedItemId = nil
	InventoryController.ToolUnequipped:Fire(tool, equippedItem)
	InventoryController.EquippedToolChanged:Fire(nil, nil)
end

function InventoryController._OnCharacter(instance)
	if not instance then
		return
	end

	v:Clean()
	local equippedTool = InventoryController.EquippedTool
	local equippedItem = InventoryController.EquippedItem

	if equippedTool then
		InventoryController.EquippedTool = nil
		InventoryController.EquippedItem = nil
		InventoryController.EquippedItemId = nil
		InventoryController.ToolUnequipped:Fire(equippedTool, equippedItem)
		InventoryController.EquippedToolChanged:Fire(nil, nil)
	end

	v:Connect(instance.ChildAdded, InventoryController._OnChildAdd)
	v:Connect(instance.ChildRemoved, InventoryController._OnChildRemove)

	for _, child in instance:GetChildren() do
		InventoryController._OnChildAdd(child)
	end
end

function InventoryController.Start(_)
	localPlayer.CharacterAdded:Connect(InventoryController._OnCharacter)
	InventoryController._OnCharacter(localPlayer.Character)
end

return InventoryController