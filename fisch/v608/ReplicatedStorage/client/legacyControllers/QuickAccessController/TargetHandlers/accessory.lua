local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage.packages.Net)
local items = require(ReplicatedStorage.shared.modules.library.items)
local accessorydata = require(ReplicatedStorage.shared.modules.library.items.accessorydata)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
require(ReplicatedStorage.client.modules.ui.Backpack)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local anno_localthought = ReplicatedStorage.events.anno_localthought
local remoteFunction = Net:RemoteFunction("AccessoryService/ToggleAccessory")
legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("rod")
local Accessory = {}

function Accessory.GetOptions()
	DataController.InventoryReplicator:WaitForLoaded()
	local v = {}
	local names = {}

	for _, v2 in assert(DataController.InventoryReplicator.Data).Inventory do
		if not accessorydata[v2.name] or v[v2.name] then
			continue
		end

		table.insert(names, v2.name)
		v[v2.name] = true
	end

	table.sort(names)
	return names
end

function Accessory.Select(p: string)
	local v = accessorydata[p]

	if v.ReplaceEquipButtonCallbackClient and not v.ReplaceEquipButtonCallbackClient(p) then
		return
	end

	local _, v2 = remoteFunction:InvokeServer(p)

	if v2 then
		anno_localthought:Fire(v2)
	end
end

function Accessory.GetDisplay(p: string)
	local item = items.Items[p]

	if item and item.Icon and item.Icon ~= "" then
		return "Icon", item.Icon
	end

	return "Text", p
end

function Accessory.GetDescription(p: string)
	local v = accessorydata[p]

	if v.ReplaceEquipButtonText then
		return (`{v.ReplaceEquipButtonText} {p}`)
	end

	if DataController.PlayerDataReplicator:Index({ "EquippedAccessories", p }) ~= nil then
		return (`Equip {p}`)
	end

	return (`Unequip {p}`)
end

return Accessory