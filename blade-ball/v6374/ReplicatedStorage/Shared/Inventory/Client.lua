local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local parent = script.Parent
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return nil
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(parent.InventoryTypes)
local v2 = require3(parent.Shared)
local Inventory = {
	None = v.None,
	InventoryTypes = v2.InventoryTypes,
	GetInventoryVersion = function(self)
		return v2:GetInventoryVersion(nil)
	end,
	GetRaw = function(self, p, p2)
		return v2:GetRaw(nil, p2, p)
	end,
	Get = function(self, p)
		return v2:Get(nil, p)
	end,
	GetInventoryRaw = function(self, p)
		return v2:GetInventoryRaw(nil, p)
	end,
	GetInventory = function(self)
		return v2:GetInventory(nil)
	end,
	OwnsItem = function(self, p, p2)
		return v2:OwnsItem(nil, p, p2)
	end,
	GetItem = function(self, p, p2)
		return v2:GetItem(nil, p, p2)
	end,
	FindItemsRaw = function(self, p, p2, p3, p4)
		return v2:FindItemsRaw(nil, p, p2, p3, p4)
	end,
	FindItems = function(self, p, p2, p3)
		return v2:FindItems(nil, p, p2, p3)
	end,
	FindItemsWithKey = function(self, p, p2)
		return v2:FindItemsWithKey(nil, p, p2)
	end,
	GetEquipped = function(self, p)
		return v2:GetEquipped(nil, p)
	end,
	GetEquippedList = function(self, p)
		return v2:GetEquippedList(nil, p)
	end,
	OnChange = function(self, p, p2)
		return v2:OnChange(nil, p, p2)
	end,
	OnInventoryChange = function(self, p, p2)
		return v2:OnInventoryChange(nil, p, p2)
	end,
	OnItemChange = function(self, p, p2, p3)
		return v2:OnItemChange(nil, p, p2, p3)
	end,
	OnEquip = function(self, p, p2)
		return v2:OnEquip(nil, p, p2)
	end,
	UUIDToString = function(self, p, p2, p3, p4)
		return v2:UUIDToString(nil, p, p2, p3, p4)
	end
}
Inventory.UUIDToKey = Inventory.UUIDToString

function Inventory:ItemToString(p, p2, p3, p4)
	return v2:ItemToString(p, p2, p3, p4)
end

Inventory.ItemToKey = Inventory.ItemToString

function Inventory:StringToItem(p)
	return v2:StringToItem(nil, p)
end

Inventory.KeyToItem = Inventory.StringToItem

function Inventory:SafeGetLegacyInventoryPath(p)
	return v2:SafeGetLegacyInventoryPath(p)
end

function Inventory:GetLegacyInventoryPath(p)
	return v2:GetLegacyInventoryPath(p)
end

function Inventory:CreateFakeReplion(p)
	return v2:CreateFakeReplion(p)
end

function Inventory:GetInventorySize(p, p2)
	return v2:GetInventorySize(p, p2)
end

function Inventory:GetInventoryLimit(p)
	return v2:GetInventoryLimit(p)
end

return Inventory