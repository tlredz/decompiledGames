local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
require(packages.Signal)
require(packages.patch)
require(packages.State)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local PlayerController = require(legacyControllers.PlayerController)
local modules = ReplicatedStorage.shared.modules
require(modules.SharedStorage)
local fish = require(modules.library.fish)
require(modules.library.items)
local rarities = require(modules.library.rarities)
local mutations = require(modules.fishing.mutations)
local fishing = require(modules.fishing)
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
local modules2 = ReplicatedStorage.client.modules
local Backpack = require(modules2.ui.Backpack)
local virtualScroller = require(modules2.ui.Backpack.virtualScroller)
require(modules2.ui.Backpack.objectHelper)
require(modules2.ui.Backpack.dragHelper)
local sortHelper = require(modules2.ui.Backpack.sortHelper)
local module = require("@self/itemDisplayInfo")
local module2 = require("@self/objectHelper")
local module3 = require("@self/dragHelper")
local v = {}
local v2 = {}
local v3 = {}
local remoteEvent = Net:RemoteEvent("Storage/RequestInitial")
local remoteEvent2 = Net:RemoteEvent("Storage/RequestRemoveFromStorage")
local remoteEvent3 = Net:RemoteEvent("Storage/RequestedOpenStorageCrate")
local remoteFunction = Net:RemoteFunction("Storage/RequestBulkMove")
local localPlayer = Players.LocalPlayer
local storage = legacyUiLoader.PlayerGui.hud.safezone.storage
local scroll = storage.scroll
local main = storage.Main
local inventory = legacyUiLoader.PlayerGui:WaitForChild("backpack").inventory
local clone = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {
	Fishables = false,
	Items = false
}
local Storage = {
	_hasRequestedInitial = false,
	_dataReceiver = nil,
	refreshStorageScroller = nil,
	updateDisplayedItems = nil
}

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleItemUpdate(p: string)
	if not v5[v2[p]] then
		v7[p] = true
		return
	end

	module2.update(v2[p], p)
	v7[p] = nil
end

local function getItemIdFromObject(p)
	if v5[p] then
		return v5[p]
	end
end

legacyUiLoader.PlayerGui.backpack.inventory:GetPropertyChangedSignal("Visible"):Connect(function()
	if not legacyUiLoader.PlayerGui.backpack.inventory.Visible then
		storage.Visible = false
	end
end)
local personalAquariumCustomize = legacyUiLoader.PlayerGui.hud.safezone:FindFirstChild("personalAquariumCustomize")
local visible = nil
storage:GetPropertyChangedSignal("Visible"):Connect(function()
	PlayerController:ToggleControls(not storage.Visible)

	if not personalAquariumCustomize then
		return
	end

	if storage.Visible then
		if visible == nil then
			visible = personalAquariumCustomize.Visible
		end

		personalAquariumCustomize.Visible = false
	elseif visible ~= nil then
		personalAquariumCustomize.Visible = visible
		visible = nil
	end
end)

function Storage.init()
	storage.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(Storage.updateDisplayedItems)
	remoteEvent3.OnClientEvent:Connect(Storage.open)
	storage.Exit.Exit.Activated:Connect(Storage.close)
	storage.Exit.TakeSearch.Activated:Connect(function()
		Storage.bulkTransfer(clone, true)
	end)
	inventory.Topbar.DepositSearch.Activated:Connect(function()
		Storage.bulkTransfer(Backpack.displayedItems, false)
	end)
	Storage.refreshStorageScroller = virtualScroller({
		maxItems = function()
			return #clone
		end,
		reconcile = Storage._reconcileGrid,
		getItemSize = function()
			return 50
		end,
		getItemPadding = function()
			return 3
		end,
		scrollingFrame = storage.scroll
	})

	local function setToggleEnabled(childName: string, flag: boolean)
		local child = storage.Toggles:FindFirstChild(childName)
		TweenService:Create(child.Toggle.Switch, TweenInfo.new(0.2), {
			Position = UDim2.fromScale(flag and 1 or 0, 0.5)
		}):Play()
		local BG = child.Toggle.BG
		local tweenInfo = TweenInfo.new(0.2)
		local backgroundColor

		if flag then
			backgroundColor = Color3.fromRGB(0, 255, 85)
		else
			backgroundColor = Color3.fromRGB(255, 255, 255)
		end

		TweenService:Create(BG, tweenInfo, {
			BackgroundColor3 = backgroundColor
		}):Play()
		v8[childName] = flag
		Storage.updateDisplayedItems()
	end

	for _, button in storage.Toggles:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v9 = button
		button.Activated:Connect(function()
			setToggleEnabled(v9.Name, not v8[v9.Name])
		end)
	end

	setToggleEnabled("Fishables", true)
	setToggleEnabled("Items", true)

	local function getHoveredItem(p)
		local vector = Vector2.new(p.Position.X, p.Position.Y)

		for _, v9 in legacyUiLoader.PlayerGui:GetGuiObjectsAtPosition(vector.X, vector.Y) do
			local v10

			if v5[v9] then
				v10 = v5[v9]
			end

			if v10 then
				return getItemIdFromObject(v9)
			end
		end
	end

	local v9 = nil
	local v10 = nil
	local position = nil
	UserInputService.InputBegan:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			v9 = nil
		elseif input.UserInputType == Enum.UserInputType.Touch then
			local hoveredItem = getHoveredItem(input)

			if not hoveredItem then
				return
			end

			v10 = hoveredItem
			position = input.Position
		end
	end)
	UserInputService.TouchEnded:Connect(function(otherPart)
		v9 = time()

		if otherPart.UserInputType == Enum.UserInputType.Touch then
			local hoveredItem = getHoveredItem(otherPart)

			if not hoveredItem or hoveredItem ~= v10 or (otherPart.Position - position).Magnitude > 25 then
				return
			end

			Storage._handleInput(hoveredItem, "equip")
		end

		v10 = nil
	end)
	UserInputService.TouchStarted:Connect(function()
		v9 = nil
	end)
end

function Storage.open()
	if not Storage._hasRequestedInitial then
		Storage._startDataReceiver()
	end

	legacyUiLoader.PlayerGui.backpack.inventory.Visible = true
	storage.Visible = true
end

function Storage.close()
	storage.Visible = false
end

local v9 = false

local function hydrateStorageSnapshot(items)
	for _, v10 in v2 do
		v10:Destroy()
	end

	table.clear(v2)
	table.clear(v4)
	table.clear(v5)
	table.clear(v6)
	table.clear(v7)
	table.clear(clone)
	v = items
	module2.setInventory(items)
	module3.setInventory(items)
	v9 = true
	local count = 0

	for k in items do
		if count >= 200 then
			task.wait()
			count = 0
		end

		count += 1
		Storage._createStorageItem(k)
	end

	v9 = false
	Storage.updateDisplayedItems()
end

function Storage._startDataReceiver()
	if Storage._dataReceiver then
		return
	end

	Storage._hasRequestedInitial = true
	Storage._dataReceiver = DataController.StorageReplicator:Listen({ "Storage" }, function(items, p)
		if not next(items) then
			warn("Received empty storage from server!")
		end

		v = items
		module2.setInventory(items)
		module3.setInventory(items)
		local count = 0
		local v10

		if p then
			v10 = p.Storage or items
		else
			v10 = items
		end

		for k, _ in v10 do
			if items[k] then
				if v2[k] then
					scheduleItemUpdate(k) -- equivalent call inferred; original call site unknown
				else
					if count >= 200 then
						task.wait()
						count = 0
					end

					count += 1
					Storage._createStorageItem(k)
				end
			else
				Storage._onItemRemoved(k)
			end
		end
	end)
	local v10 = {}
	DataController.PlayerDataReplicator:Observe({ "PersonalAquarium" }, function(p)
		if not p then
			return
		end

		local v11 = {}

		for _, v12 in p.FishIndex do
			if not v10[v12] then
				scheduleItemUpdate(v12) -- equivalent call inferred; original call site unknown
			end

			v11[v12] = true
		end

		for _, v12 in p.CosmeticFishIndex do
			if not v10[v12] then
				scheduleItemUpdate(v12) -- equivalent call inferred; original call site unknown
			end

			v11[v12] = true
		end

		for k in v10 do
			if v11[k] then
				continue
			end

			scheduleItemUpdate(k) -- equivalent call inferred; original call site unknown
		end

		v10 = v11
	end)
	remoteEvent:FireServer()
	task.spawn(function()
		DataController.StorageReplicator:WaitForLoaded()
		local index = DataController.StorageReplicator:Index({ "Storage" })

		if index then
			hydrateStorageSnapshot(index)
		end
	end)
end

UDim2.fromOffset(0, -10000)

function Storage._reconcileGrid(items, p)
	table.clear(v6)
	local _ = #clone // p
	local Y = scroll.CanvasPosition.Y
	UDim2.fromOffset(50, 50)

	for _, item in items do
		local v10 = clone[item]
		local v11 = v2[v10]

		if not v11 then
			continue
		end

		if not v5[v11] then
			v11.Visible = true
			v11.Parent = main
		end

		v5[v11] = v10
		v6[v11] = true

		if v7[v10] then
			v7[v10] = nil
			module2.update(v11, v10)
		end

		local v12 = item - 1
		local v13 = v12 % p
		local v14 = v12 // p
		v11.Position = UDim2.fromOffset(v13 * 53 + 1, v14 * 53 + 1 - Y)
	end

	for k in v5 do
		if v6[k] then
			continue
		end

		if k.Parent == main then
			k.Parent = script
		end

		v5[k] = nil
	end
end

function Storage._createStorageItem(p: string)
	local component = module2.create(p)
	component.Size = UDim2.fromOffset(50, 50)
	v7[p] = true
	v2[p] = component
	module3.setupUserInput({
		component = component,
		getItemId = function()
			return p
		end,
		canDrag = Storage._canDrag,
		action = Storage._handleInput
	})
	table.insert(v4, p)
	Storage.updateDisplayedItems()
end

function Storage._handleInput(p, p2: string)
	if p2 == "equip" then
		remoteEvent2:FireServer(p)
	end
end

function Storage._canDrag()
	return false
end

function Storage._onItemRemoved(p)
	v7[p] = nil
	local v10 = v2[p]

	if v10 then
		v5[v10] = nil
		v6[v10] = nil
		v10:Destroy()
		v2[p] = nil
	end

	local index = table.find(v4, p)

	if index then
		table.remove(v4, index)
		Storage.updateDisplayedItems()
	end
end

local v10 = false

function Storage.bulkTransfer(list, flag: boolean)
	if #list == 0 or v10 then
		return
	end

	v10 = true
	storage.Exit.TakeSearch.Label.Text = "..."
	inventory.Topbar.DepositSearch.Label.Text = "..."
	remoteFunction:InvokeServer(list, flag)
	v10 = false
	storage.Exit.TakeSearch.Label.Text = "Take Results"
	inventory.Topbar.DepositSearch.Label.Text = "Deposit Results"
end

local function searchCompare(p, value: string, callback)
	local v11, v12 = value:byte(1, 2)
	local v13

	if v11 == 60 or v11 == 62 then
		v13 = callback(value:sub(v12 == 61 and 3 or 2))
	else
		v13 = callback(value)
	end

	if not v13 then
		return false
	end

	local v14 = callback(p)

	if not v14 then
		return false
	end

	if v11 == 60 then
		if v12 == 61 then
			return v14 <= v13
		end

		return v14 < v13
	else
		if v11 ~= 62 then
			return v14 == v13
		end

		if v12 == 61 then
			return v13 <= v14
		end

		return v13 < v14
	end
end

local names = {}

for _, orderedRarity in rarities.OrderedRarities do
	table.insert(names, orderedRarity.Name:lower())
end

local function getRarityIndex(value)
	return value and table.find(names, value:lower())
end

local v11 = false

function Storage.updateDisplayedItems()
	if v11 or v9 or not storage.Visible then
		return
	end

	v11 = true
	task.defer(function()
		v11 = false
		local v12 = nil
		local v13 = nil
		debug.profilebegin("Storage::Sort")
		local _, _ = pcall(function()
			local weight = sortHelper.Weight
			table.sort(v4, function(a, b)
				local v14 = v[a]
				local v15 = v[b]
				v12 = v14
				v13 = v15

				if v12 and v13 then
					return (weight(v12, v13, false))
				end

				local v16 = v3[a]
				local v17 = v3[b]

				if v12 or v13 then
					return v12 == nil
				end

				return v16.Name < v17.Name
			end)
		end)
		debug.profileend()
		debug.profilebegin("Storage::Clone")
		clone = table.clone(v4)
		debug.profileend()
		debug.profilebegin("Storage::SearchAndToggles")
		local text = storage.Search.TextBox.Text
		local joined = text:lower()
		local v14 = {}

		if joined:find(":") then
			local parts = joined:split(" ")
			local parts2 = {}

			for _, part in parts do
				if part:find(":.") then
					local match, v15 = part:match("(.-):(.+)")
					v14[match] = v15
				elseif part ~= "" then
					table.insert(parts2, part)
				end
			end

			joined = table.concat(parts2, " ")
		end

		local count = 0

		for k, v15 in v4 do
			if not v[v15] then
				continue
			end

			local v16 = joined == "" or module2.getItemFullName(v15):lower():gsub("<.->", ""):find(
				joined:lower(),
				1,
				true
			)
			local v17 = module[v[v15].name]

			if v16 and v14.rarity then
				local rarity = v17 and v17.rarity and v17.rarity:lower()
				v16 = searchCompare(rarity, v14.rarity, getRarityIndex) or rarity and rarity:find(v14.rarity, 1, true)
			end

			if v16 and v14.from then
				local v18 = fish[v[v15].name]
				v16 = v18 and (v18.From or "regionless"):lower():gsub("%s", ""):find(v14.from, 1, true)
			end

			if v16 and v14.crate then
				local v18 = v14.crate == "true" or v14.crate == "yes" or v14.crate == "1" or v14.crate == "y"
				local v19 = fish[v[v15].name]
				v16 = (v19 and v19.IsCrate or false) == v18
			end

			if v16 and v14.appraised then
				local v18 = v14.appraised == "true" or v14.appraised == "yes" or v14.appraised == "1" or v14.appraised == "y"
				v16 = v[v15].sub and (v[v15].sub.Appraised or false) == v18
			end

			if v16 and v14.treasureappraised then
				local v18 = v14.treasureappraised == "true" or v14.treasureappraised == "yes" or v14.treasureappraised == "1" or v14.treasureappraised == "y"
				v16 = v[v15].sub and v[v15].sub.DefaultWeight ~= nil == v18
			end

			if v16 and v14.favorited then
				local v18 = v14.favorited == "true" or v14.favorited == "yes" or v14.favorited == "1" or v14.favorited == "y"
				v16 = v[v15].sub and (v[v15].sub.Favourited or false) == v18
			end

			if v16 and v14.weight then
				v16 = searchCompare(v[v15].sub and v[v15].sub.Weight, v14.weight, tonumber)
			end

			if v16 and v14.mutation then
				if v14.mutation == "any" or v14.mutation == "yes" then
					v16 = v[v15].sub.Mutation ~= nil
				elseif v14.mutation == "none" or v14.mutation == "no" then
					v16 = v[v15].sub.Mutation == nil
				else
					local mutation = mutations.Mutations[v[v15].sub.Mutation]
					v16 = mutation and mutation.Display:lower():gsub("%s", ""):find(v14.mutation, 1, true) ~= nil and true or false
				end
			end

			if v16 and v14.stack then
				v16 = searchCompare(not v[v15].sub and 1 or v[v15].sub.Stack or 1, v14.stack, tonumber)
			end

			if v16 and v14.price then
				v16 = fish[v[v15].name] and searchCompare(
					fishing:SellFish(localPlayer, v[v15], true),
					v14.price,
					tonumber
				)
			end

			local type = v17 and v17.type or -1

			if not (not v16 or type == -1 or type == 1 and not v8.Items or type == 2 and not v8.Fishables) then
				continue
			end

			table.remove(clone, k - count)
			count += 1
		end

		local takeSearch = storage.Exit.TakeSearch
		takeSearch.Visible = text ~= "" and #clone > 0
		debug.profileend()
		Storage.refreshStorageScroller(true)
	end)
end

return Storage