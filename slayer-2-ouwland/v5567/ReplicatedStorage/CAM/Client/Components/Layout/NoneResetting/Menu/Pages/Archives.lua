local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Searchbar = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.Searchbar)
local ClassFilter = require(ReplicatedStorage.CAM.Client.Components.Misc.ClassFilter)
local ItemViewer = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages.Inventory.ItemViewer)
local Categories = require(script.Categories)
local ItemGrid = require(script.ItemGrid)
local data = Utility.GetData(game.Players.LocalPlayer)

local function catalog()
	local result = {}

	for k, item in Items do
		if not (item.PackContents == nil and item.Unobtainable ~= true and item.Icon ~= nil and item.Icon ~= "") then
			continue
		end

		if item.Icon == "rbxassetid://" then
			continue
		end

		table.insert(result, k)
	end

	table.sort(result, function(a: string, b: string)
		local rarity = Items[a].Rarity or 0
		local rarity2 = Items[b].Rarity or 0

		if rarity == rarity2 then
			return a < b
		end

		return rarity < rarity2
	end)
	return result
end

return function(maid, p)
	local v = catalog()

	local function found()
		local result = {}

		for _, v2 in Archives.Get("Items") do
			result[v2] = true
		end

		return result
	end

	local v2 = {}

	for _, v3 in Archives.Get("Items") do
		v2[v3] = true
	end

	local value = maid:Value(v2)
	maid:Add(Archives.Connect("Items", function()
		local v4 = {}

		for _, v5 in Archives.Get("Items") do
			v4[v5] = true
		end

		value:Set(v4)
	end))

	local function held()
		local result = {}

		for _, v3 in Utility.HeldEntries(data) do
			result[v3.Name] = true
		end

		return result
	end

	local v3 = {}

	for _, v4 in Utility.HeldEntries(data) do
		v3[v4.Name] = true
	end

	local value2 = maid:Value(v3)

	local function recheck()
		local v5 = {}

		for _, v6 in Utility.HeldEntries(data) do
			v5[v6.Name] = true
		end

		value2:Set(v5)
	end

	for _, v4 in Utility.ItemBags(data) do
		maid:Connect(v4.ChildAdded, recheck)
		maid:Connect(v4.ChildRemoved, recheck)
	end

	local value3 = maid:Value("")
	local value4 = maid:Value("All")
	local value5 = maid:Value(ClassFilter.ALL)
	local v4 = {}

	for _, v5 in v do
		ClassFilter.Tally(v4, v5)
	end

	local stringValue = Instance.new("StringValue")
	local v5 = {}
	local value6 = maid:Value(v5)

	local function updateShown()
		table.clear(v5)
		local v6 = value4:Get()
		local v7 = value5:Get()
		local value7 = string.lower(stringValue.Value)

		for _, v8 in v do
			if not ((v6 == "All" or (Items[v8].InventoryCategory or "Items") == v6) and (v7 == ClassFilter.ALL or Items[v8].Class == v7)) then
				continue
			end

			if not (value7 == "" or string.sub(string.lower(v8), 1, #value7) == value7) then
				continue
			end

			table.insert(v5, v8)
		end

		local v8 = value:Get()
		table.sort(v5, function(a: string, b: string)
			local v9 = v8[a] == true

			if v9 ~= (v8[b] == true) then
				return v9
			end

			local rarity = Items[a].Rarity or 0
			local rarity2 = Items[b].Rarity or 0

			if rarity == rarity2 then
				return a < b
			end

			return rarity < rarity2
		end)
		value6:Refresh()
		local v9 = value3:Get()

		if v9 ~= "" and table.find(v5, v9) == nil then
			value3:Set("")
		end
	end

	updateShown()
	maid:Connect(value4.Changed, updateShown)
	maid:Connect(value5.Changed, updateShown)
	maid:Connect(stringValue:GetPropertyChangedSignal("Value"), updateShown)
	return maid:Create("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = maid:Animation(UDim2.fromScale(0.8, 0.8), maid.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(0.7200000000000001, 0.7200000000000001)
		}),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		maid:Create("Frame")({
			Name = "SearchbarHolder",
			Size = UDim2.fromScale(0.3, 0.065),
			Position = UDim2.fromScale(0, -0.015),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			(Searchbar(maid, v, stringValue, "Search items"))
		}),
		ClassFilter.Pick(maid, value5, v4, 0.065),
		Categories(maid, p, value4, v, "All"),
		ItemGrid(maid, p, value6, value3, value, value2),
		ItemViewer(maid, p, value3, value, value2)
	})
end