local InventoryService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage3:WaitForChild("Remotes")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local clientServices = ReplicatedStorage4:WaitForChild("ClientServices")
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage5:WaitForChild("Modules"):WaitForChild("WindowService"))
local ItemService = require(clientServices:WaitForChild("ItemService"))
local baseItemFrame = ItemService.BaseItemFrame

local function ApplyFilter(data, p: string)
	local search = data.Filters.Search or ""
	local _ = data.Filters.ClassFilter or nil
	local frame = data.Frames[p].Frame
	local v

	if search == "" then
		v = false
	else
		v = search ~= nil
	end

	local v2

	if v then
		local v3 = Sync[data.ItemType][p]
		local name = string.lower(v3.Name or v3.DisplayName or v3.ItemName)
		v2 = string.find(name, search) ~= nil
	else
		v2 = false
	end

	local visible

	if data.Frames[p].ItemClass == data.Filters.ClassFilter or data.Filters.ClassFilter == nil then
		visible = not v or v and v2
	else
		visible = v and v2
	end

	frame.Visible = visible
end

function InventoryService:CreateItemFrame(itemType, p2: string, p3: number)
	local clone = baseItemFrame:Clone()
	local itemInfo = ItemService:GetItemInfo(itemType, p2)

	if not itemInfo then
		warn("InventoryService: No info found for item:" .. tostring(p2) .. ", " .. tostring(itemType))
		return nil
	end

	ItemService:ApplyItemToFrame(clone, itemInfo, p3)
	ItemService:ApplyTags(clone, itemInfo)
	clone.LayoutOrder = ItemService:GetLayoutOrder(itemType, p2)
	local itemClass

	if itemType == "Weapons" then
		itemClass = itemInfo.Event ~= nil and "Event" or itemInfo.Season == nil and "Classic" or "Current"
	end

	return {
		ItemType = itemType,
		Frame = clone,
		ItemClass = itemClass
	}
end

function InventoryService:AddItem(data, p: string, p2: number)
	local itemFrame = InventoryService:CreateItemFrame(data.ItemType, p, p2)

	if not itemFrame then
		return itemFrame
	end

	table.insert(data.SortedIDs, p)
	data.Frames[p] = itemFrame
	ApplyFilter(data, p)

	if data.ListFrame then
		itemFrame.Frame.Parent = data.ListFrame
	end

	return itemFrame
end

function InventoryService.GenerateInventoryInfo(_, itemType, items, listFrame)
	local v = {
		ItemType = itemType,
		Frames = {},
		Filters = {
			ClassFilter = nil,
			Search = ""
		},
		SortedIDs = {},
		ListFrame = listFrame
	}

	for k, item in items do
		local v2

		if tonumber(k) then
			v2 = 1
		else
			v2 = item
			item = k
		end

		InventoryService:AddItem(v, item, v2)
	end

	return v
end

function InventoryService:UpdateFilter(p)
	for k, _ in p.Frames do
		ApplyFilter(p, k)
	end
end

function InventoryService.ForEachFrame(_, p, callback)
	for k, frame in p.Frames do
		callback(k, frame.Frame)
	end
end

function InventoryService:ApplyChangesToInventoryInfo(p, p2: string, p3: number)
	if p3 == nil or not (p3 > 0) then
		InventoryService:RemoveItem(p, p2)
	elseif p.Frames[p2] then
		p.Frames[p2].Frame.Container.Amount.Text = ItemService:GetAmountText(p3)
	else
		InventoryService:AddItem(p, p2, p3)
	end
end

function InventoryService.ConnectSearchBox(_, p, instance)
	instance:GetPropertyChangedSignal("Text"):Connect(function()
		p.Filters.Search = string.lower(instance.Text)
		InventoryService:UpdateFilter(p)
	end)
end

function InventoryService.AutoUpdate(_, p)
	p.UpdateConnection = remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event:Connect(function(p2: string, p3: string, p4: number)
		if p2 ~= p.ItemType then
			return
		end

		InventoryService:ApplyChangesToInventoryInfo(p, p3, p4)
	end)
end

function InventoryService:RemoveItem(p, p2: string)
	p.Frames[p2].Frame:Destroy()
	p.Frames[p2] = nil
	table.remove(p.SortedIDs, table.find(p.SortedIDs, p2))
end

function InventoryService.ClearInventory(_, state)
	for _, frame in state.Frames do
		frame.Frame:Destroy()
	end

	state.Frames = {}

	if state.UpdateConnection then
		state.UpdateConnection:Disconnect()
	end
end

return InventoryService