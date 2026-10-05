local createVector = vector.create
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local InputController = require(ReplicatedStorage.client.legacyControllers.InputController)
local marketplace = require(ReplicatedStorage.shared.utils.marketplace)
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local CurrencyController = require(ReplicatedStorage.client.legacyControllers.CurrencyController)
local library = require(ReplicatedStorage.shared.modules.library)
require(ReplicatedStorage.shared.modules.fx.animatedgradient)
local patch = require(ReplicatedStorage.packages.patch)
local Net = require(ReplicatedStorage.packages.Net)
local objectHelper = require(script.objectHelper)
local virtualScroller = require(script.virtualScroller)
local itemDisplayInfo = require(script.itemDisplayInfo)
local dragHelper = require(script.dragHelper)
local sortHelper = require(script.sortHelper)
local confirmation = require(script.confirmation)
local evalColorSequenceEqual = require(ReplicatedStorage.shared.utils.evalColorSequenceEqual)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local NumberUtils = require(ReplicatedStorage.shared.modules.NumberUtils)
local fishing = require(ReplicatedStorage.shared.modules.fishing)
local gliderdata = require(ReplicatedStorage.shared.modules.library.items.gliderdata)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local JumpProtectController = require(ReplicatedStorage.client.legacyControllers.Gamepad.JumpProtectController)
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
local playerDataReplicator = DataController.PlayerDataReplicator
local inventoryReplicator = DataController.InventoryReplicator
local v = RunService:IsStudio() and 1361372384 or 1359918468
local localPlayer = Players.LocalPlayer
local backpack = legacyUiLoader.PlayerGui.backpack
local currentServerBoosts = legacyUiLoader.PlayerGui.CurrentServerBoosts
local inventory = backpack.inventory
local hotbar = backpack.hotbar
local storage = legacyUiLoader.PlayerGui:WaitForChild("hud").safezone.storage
local backpack2 = ReplicatedStorage:WaitForChild("client"):WaitForChild("inputs"):WaitForChild("Backpack")
local v2 = {
	legacyUiLoader.PlayerGui.hud.safezone.menu2,
	legacyUiLoader.PlayerGui.hud.safezone.crafting,
	legacyUiLoader.PlayerGui.hud.safezone.shop,
	legacyUiLoader.PlayerGui.hud.safezone.shipwright,
	legacyUiLoader.PlayerGui.Gifting.Main,
	legacyUiLoader.PlayerGui.hud.safezone.Challenges,
	legacyUiLoader.PlayerGui.hud.safezone.Dealer,
	legacyUiLoader.PlayerGui.FischersJournal
}
local v3 = 60
local v4 = v3
local remoteEvent = Net:RemoteEvent("Backpack/Favourite")
local remoteEvent2 = Net:RemoteEvent("Backpack/Equip")
local remoteEvent3 = Net:RemoteEvent("Backpack/SetHotbar")
local remoteEvent4 = Net:RemoteEvent("Storage/RequestAddToStorage")
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local rod = nil
local spear = nil
local clone = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = {
	Fishables = false,
	Items = false,
	Favourites = false
}
local v18 = 0
local v19 = nil
local v20 = false
local v21 = false
local v22 = nil
local v23 = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine
}
local Backpack = {
	displayedItems = clone
}

local function handleEquip(itemIdFromHotbarKey: string)
	localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
	local enabled = backpack.Enabled or not localPlayer.PlayerGui:GetAttribute("UiEnabled")

	if enabled then
		if humanoid then
			if humanoid.WalkSpeed > 0.1 and humanoid.Health > 0 then
				enabled = ((not localPlayer.Character:GetAttribute("ToolsDisabled") or library.rods[itemIdFromHotbarKey] or itemIdFromHotbarKey == "Equipment Bag") and true or false) and not localPlayer.PlayerGui:FindFirstChild("reel") and not (localPlayer.PlayerGui:FindFirstChild("stab") or localPlayer.PlayerGui:FindFirstChild("harpoonMinigame"))
			else
				enabled = false
			end
		else
			enabled = humanoid
		end
	end

	if not enabled then
		return
	end

	local humanoid2 = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid2 then
		return
	end

	local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
	local v24 = v6[itemIdFromHotbarKey]
	local v25

	if tool == nil then
		v25 = false
	else
		v25 = v24 == tool
	end

	if v24 and v24:IsDescendantOf(game) and not v25 then
		humanoid2:EquipTool(v24)
	elseif itemIdFromHotbarKey and not v25 then
		remoteEvent2:FireServer(itemIdFromHotbarKey)
	else
		humanoid2:UnequipTools()
	end
end

function Backpack.getHotbarKey(p: string)
	if library.rods[p] then
		return "rod"
	end

	if library.spears[p] then
		return "spear"
	end

	if library.harpoonGuns[p] then
		return "harpoonGun"
	end

	return p
end

function Backpack.getItemIdFromHotbarKey(p: string)
	if p == "rod" then
		return SharedDataHelper.readLegacyPathValue(localPlayer, { "Stats", "rod" })
	elseif p == "spear" then
		return SharedDataHelper.readLegacyPathValue(localPlayer, { "Stats", "spear" })
	elseif p == "harpoonGun" then
		return SharedDataHelper.indexNewFormat(localPlayer, { "HarpoonGuns", "Equipped" })
	end

	return p
end

local function scheduleItemUpdate(p: string)
	local hotbarKey = Backpack.getHotbarKey(p)

	for _, v24 in v7 do
		if v24 ~= hotbarKey then
			continue
		end

		Backpack.updateHotbarItems()
		break
	end

	if not v11[v9[p]] then
		v13[p] = true
		return
	end

	objectHelper.update(v9[p], p)
	v13[p] = nil
end

local function canDrag()
	return not v21 and inventory.Visible
end

function Backpack.getHotbarSize()
	return v18
end

function Backpack._getTools()
	return v6
end

function isOnHotbar(p)
	local hotbarKey = Backpack.getHotbarKey(p)

	for i = 1, v18 do
		if v7[tostring(i)] == hotbarKey then
			return true
		end
	end

	return false
end

function Backpack.handleInput(p: string, p2: string, ...)
	local itemIdFromHotbarKey = Backpack.getItemIdFromHotbarKey(p)

	if p2 == "dragStarted" then
		dragHelper.startDrag(itemIdFromHotbarKey, ...)
	elseif p2 == "favourite" then
		local favourited = ...
		v5[itemIdFromHotbarKey].sub.Favourited = favourited
		scheduleItemUpdate(itemIdFromHotbarKey)
		Backpack.updateDisplayedItems()
		remoteEvent:FireServer(itemIdFromHotbarKey, favourited)
	elseif p2 ~= "equip" then
		error((`invalid action {p2}`))
	elseif (backpack.Enabled or not localPlayer.PlayerGui:GetAttribute("UiEnabled")) and not v21 then
		handleEquip(itemIdFromHotbarKey)
	end
end

function Backpack.toggleInventory()
	if not (backpack.Enabled and hotbar.Visible) then
		return
	end

	inventory.Visible = not inventory.Visible

	if inventory.Visible then
		GamepadService:EnableGamepadCursor(inventory.scroll)
	end
end

function Backpack.updateHotbarItems()
	local uDim = UDim2.fromOffset(v3, v3)

	for i = 1, 9 do
		local v24 = v15 == i
		local v25 = v7[tostring(i)]
		local itemIdFromHotbarKey = Backpack.getItemIdFromHotbarKey(v25)
		local v26

		if i <= v18 then
			v26 = itemIdFromHotbarKey ~= nil or inventory.Visible
		else
			v26 = false
		end

		local v27 = v8[i]

		if v8[i] then
			if v27.Size ~= uDim then
				v27.Size = uDim
			end

			if v26 then
				if v14 == itemIdFromHotbarKey then
					objectHelper.setComponentItem(v27, nil)
					objectHelper.update(v27, nil)
				else
					objectHelper.setComponentItem(v27, itemIdFromHotbarKey)
					objectHelper.update(v27, itemIdFromHotbarKey)
				end

				if v24 then
					objectHelper.setComponentTransparency(v27, GamepadService.GamepadCursorEnabled and 0.9 or 0.65)
				else
					objectHelper.setComponentTransparency(v27, 0)
				end

				v27.Visible = true
			else
				v27.Visible = false
			end
		else
			local v28 = objectHelper.create(itemIdFromHotbarKey)
			v28.Parent = hotbar
			dragHelper.setupDragTarget(v28, i)
			local v29 = i
			dragHelper.setupUserInput({
				component = v28,
				getItemId = function()
					return Backpack.getItemIdFromHotbarKey(v7[tostring(v29)])
				end,
				canDrag = canDrag,
				action = Backpack.handleInput
			})
			local textLabel = Instance.new("TextLabel")
			textLabel.TextSize = 14
			textLabel.Text = i
			textLabel.Size = UDim2.fromOffset(14, 14)
			textLabel.Position = UDim2.fromOffset(0, 0)
			textLabel.TextWrapped = false
			textLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
			textLabel.Font = Enum.Font.SourceSansSemibold
			textLabel.BackgroundTransparency = 1
			textLabel.Parent = v28
			v8[i] = v28
		end
	end
end

local absoluteSize = legacyUiLoader.PlayerGui.hud.AbsoluteSize
legacyUiLoader.PlayerGui.hud:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	absoluteSize = legacyUiLoader.PlayerGui.hud.AbsoluteSize
end)
local currentCamera = workspace.CurrentCamera

function Backpack.getUIScale()
	return (math.clamp(math.min(currentCamera.ViewportSize.X, currentCamera.ViewportSize.Y) / 540 * 0.9, 0.9, 1.1))
end

function Backpack.updateUIScaling()
	local Y = absoluteSize.Y
	local v24 = absoluteSize.X <= 760

	if legacyUiLoader.PlayerGui:FindFirstChild("TouchGui") then
		local _ = absoluteSize.X * 0.6
	else
		local _ = absoluteSize.X * 0.75
	end

	v18 = v24 and 7 or 9
	v3 = v4 * Backpack.getUIScale()
	Backpack.updateHotbarItems()
	local v25

	if Y < 500 then
		v25 = (Y - 150) * 0.7
	else
		v25 = math.min(Y * 0.45, v3 * 5)
	end

	if storage.Visible and Y < 500 then
		v25 = math.min(v25, Y / 2 - 48)
	end

	inventory.TopButtons.Visible = not storage.Visible
	local depositSearch = inventory.Topbar.DepositSearch
	local visible = storage.Visible

	if visible then
		if #clone > 0 then
			visible = inventory.Topbar.Search.TextBox.Text ~= ""
		else
			visible = false
		end
	end

	depositSearch.Visible = visible
	local v26 = (v3 + 3) * v18 - 3
	local v27 = inventory.scroll.ScrollBarThickness + 4

	if UserInputService.TouchEnabled and not (UserInputService.GamepadEnabled or UserInputService.KeyboardEnabled) then
		v27 += 12
	end

	inventory.scroll.Position = UDim2.new(0.5, v27 / 2, 1, 0)
	inventory.scroll.Size = UDim2.new(0, v26 + v27, 0.85, 0)
	inventory.itemContainer.Size = inventory.scroll.Size
	inventory.itemContainer.Position = inventory.scroll.Position
	inventory.Size = UDim2.fromOffset(v26 + v27 * 2, v25)
	inventory.Confirmation.Cancel.Size = UDim2.fromScale(v18 <= 6 and 0.4 or 0.2, 0.12)
	inventory.Confirmation.Confirm.Size = UDim2.fromScale(v18 <= 6 and 0.4 or 0.2, 0.12)
	local uDim = UDim2.fromOffset(v3, v3)

	for _, v28 in v9 do
		v28.Size = uDim
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setItemHotbarSlot(p: string, p2: number?)
	for k, v24 in v7 do
		if v24 == p then
			v7[k] = nil
		end
	end

	if p2 then
		v7[tostring(p2)] = p
	end

	Backpack.updateHotbarItems()
	Backpack.updateDisplayedItems()
	remoteEvent3:FireServer(v7)
end

function Backpack.isRodHotbarSlot(p: number)
	return v7[tostring(p)] == "rod"
end

function Backpack.forceItemIntoHotbar(p: string, value: number)
	local hotbarKey = Backpack.getHotbarKey(p)

	if hotbarKey == "rod" then
		return false
	end

	for _, v24 in v7 do
		if v24 == hotbarKey then
			return false
		end
	end

	if v18 < 1 then
		return false
	end

	local v24 = math.clamp(value, 1, v18)

	if Backpack.isRodHotbarSlot(v24) then
		return false
	end

	setItemHotbarSlot(hotbarKey, v24)
	return true
end

UDim2.fromOffset(0, -10000)

function Backpack.reconcileGrid(items, p)
	table.clear(v12)
	local _ = #clone // p
	local Y = inventory.scroll.CanvasPosition.Y
	UDim2.fromOffset(v3, v3)

	for _, item in items do
		local v24 = clone[item]
		local v25 = v9[v24]

		if not v25 then
			continue
		end

		if not v11[v25] then
			v25.Visible = true
			v25.Parent = inventory.itemContainer
		end

		v11[v25] = v24
		v12[v25] = true

		if v13[v24] then
			v13[v24] = nil
			objectHelper.update(v25, v24)
		end

		local v26 = item - 1
		local v27 = v3
		local v28 = v26 % p
		local v29 = v26 // p
		v25.Position = UDim2.fromOffset(v28 * (v27 + 3) + 1, v29 * (v27 + 3) + 1 - Y)
		local active = not v21
		v25.Interactable = not v21
		v25.Active = active
	end

	for k in v11 do
		if v12[k] then
			continue
		end

		if k.Parent == inventory.itemContainer then
			k.Parent = script
		end

		v11[k] = nil
	end

	Backpack.gamepad.setItemGrid(v7, v5, v11)
end

function Backpack.getEquippedItemId()
	if not localPlayer.Character then
		return
	end

	local tool = localPlayer.Character:FindFirstChildOfClass("Tool")

	if not tool then
		return
	end

	local link = tool:FindFirstChild("link")

	if link then
		return link.Value
	end

	return tool.Name
end

local function searchCompare(p, value: string, callback)
	local v24, v25 = value:byte(1, 2)
	local v26

	if v24 == 60 or v24 == 62 then
		v26 = callback(value:sub(v25 == 61 and 3 or 2))
	else
		v26 = callback(value)
	end

	if not v26 then
		return false
	end

	local v27 = callback(p)

	if not v27 then
		return false
	end

	if v24 == 60 then
		if v25 == 61 then
			return v27 <= v26
		end

		return v27 < v26
	else
		if v24 ~= 62 then
			return v27 == v26
		end

		if v25 == 61 then
			return v26 <= v27
		end

		return v26 < v27
	end
end

local names = {}

for _, orderedRarity in library.rarities.OrderedRarities do
	table.insert(names, orderedRarity.Name:lower())
end

local function getRarityIndex(value)
	return value and table.find(names, value:lower())
end

local flag = false

function Backpack.updateDisplayedItems()
	if localPlayer:GetAttribute("SellingFish") or flag then
		return
	end

	flag = true
	local count = 0
	local total = 0
	task.defer(function()
		flag = false
		local v24 = nil
		local v25 = nil
		debug.profilebegin("Backpack::Sort")
		local success, result = pcall(function()
			local v26 = sortHelper[v19 or "Weight"]
			table.sort(v10, function(a, b)
				local v27 = v5[a]
				local v28 = v5[b]
				v24 = v27
				v25 = v28

				if v24 and v25 then
					if itemDisplayInfo[v24.name] and itemDisplayInfo[v25.name] then
						local v29 = v26(v24, v25, v20)

						if v20 and v19 ~= "Weight" and v19 ~= "Favorite" then
							return not v29
						end

						return v29
					elseif v20 then
						return b < a
					else
						return a < b
					end
				else
					local v29 = v6[a]
					local v30 = v6[b]

					if v24 or v25 then
						return v24 == nil
					end

					return v29.Name < v30.Name
				end
			end)
		end)

		if not success then
			warn("Sort error:", result)
		end

		debug.profileend()
		debug.profilebegin("Backpack::Clone")
		clone = table.clone(v10)
		Backpack.displayedItems = clone
		debug.profileend()
		debug.profilebegin("Backpack::FilterTogglesAndSearch")
		local text = inventory.Topbar.Search.TextBox.Text
		local joined = text:lower()
		local v26 = {}

		if joined:find(":") then
			local parts = joined:split(" ")
			local parts2 = {}

			for _, part in parts do
				if part:find(":.") then
					local match, v27 = part:match("(.-):(.+)")
					v26[match] = v27
				elseif part ~= "" then
					table.insert(parts2, part)
				end
			end

			joined = table.concat(parts2, " ")
		end

		local count2 = 0

		for k, v27 in v10 do
			local v28 = true

			if v5[v27] then
				if joined ~= "" then
					v28 = objectHelper.getItemFullName(v27):lower():gsub("<.->", ""):find(joined, 1, true)
				end

				local v29 = itemDisplayInfo[v5[v27].name]

				if v28 and v26.rarity then
					local rarity = v29 and v29.rarity and v29.rarity:lower()
					v28 = searchCompare(rarity, v26.rarity, getRarityIndex) or rarity and rarity:find(
						v26.rarity,
						1,
						true
					)
				end

				if v28 and v26.from then
					local v30 = library.fish[v5[v27].name]
					v28 = v30 and (v30.From or "regionless"):lower():gsub("%s", ""):find(v26.from, 1, true)
				end

				if v28 and v26.crate then
					local v30 = v26.crate == "true" or v26.crate == "yes" or v26.crate == "1" or v26.crate == "y"
					local v31 = library.fish[v5[v27].name]
					v28 = (v31 and v31.IsCrate or false) == v30
				end

				if v28 and v26.appraised then
					local v30 = v26.appraised == "true" or v26.appraised == "yes" or v26.appraised == "1" or v26.appraised == "y"
					v28 = v5[v27].sub and (v5[v27].sub.Appraised or false) == v30
				end

				if v28 and v26.treasureappraised then
					local v30 = v26.treasureappraised == "true" or v26.treasureappraised == "yes" or v26.treasureappraised == "1" or v26.treasureappraised == "y"
					v28 = v5[v27].sub and v5[v27].sub.DefaultWeight ~= nil == v30
				end

				if v28 and v26.favorited then
					local v30 = v26.favorited == "true" or v26.favorited == "yes" or v26.favorited == "1" or v26.favorited == "y"
					v28 = v5[v27].sub and (v5[v27].sub.Favourited or false) == v30
				end

				if v28 and v26.weight then
					v28 = searchCompare(v5[v27].sub and v5[v27].sub.Weight, v26.weight, tonumber)
				end

				if v28 and v26.mutation then
					if v26.mutation == "any" or v26.mutation == "yes" then
						v28 = v5[v27].sub.Mutation ~= nil
					elseif v26.mutation == "none" or v26.mutation == "no" then
						v28 = v5[v27].sub.Mutation == nil
					else
						local mutation = library.mutations[v5[v27].sub.Mutation]
						v28 = mutation and mutation.Display:lower():gsub("%s", ""):find(v26.mutation, 1, true) ~= nil and true or false
					end
				end

				if v28 and v26.stack then
					v28 = searchCompare(not v5[v27].sub and 1 or v5[v27].sub.Stack or 1, v26.stack, tonumber)
				end

				if v28 and v26.price then
					v28 = library.fish[v5[v27].name] and searchCompare(
						fishing:SellFish(localPlayer, v5[v27], true),
						v26.price,
						tonumber
					)
				end

				local type2 = v29 and v29.type or -1

				if v28 then
					v28 = (type2 ~= 1 or not not v17.Items) and (type2 ~= 2 or not not v17.Fishables) and not (v5[v27].sub.Favourited and not v17.Favourites)
				end
			elseif next(v26) then
				v28 = false
			elseif joined ~= "" then
				v28 = v27:lower():find(joined, 1, true)
			end

			if v28 then
				count += 1

				if v5[v27] and v5[v27].sub.Stack then
					total += v5[v27].sub.Stack
				else
					count += 1
				end
			else
				table.remove(clone, k - count2)
				count2 += 1
			end
		end

		local depositSearch = inventory.Topbar.DepositSearch
		local visible = storage.Visible

		if visible then
			if #clone > 0 then
				visible = text ~= ""
			else
				visible = false
			end
		end

		depositSearch.Visible = visible
		debug.profileend()
		debug.profilebegin("Backpack:FilterHotbar")

		for k, v27 in v7 do
			local itemIdFromHotbarKey = Backpack.getItemIdFromHotbarKey(v27)
			local index = table.find(clone, itemIdFromHotbarKey)

			if index and tonumber(k) <= v18 then
				table.remove(clone, index)
			end
		end

		debug.profileend()
		debug.profilebegin("Backpack::RefreshScroller")
		Backpack.refreshInventoryScroller(true)
		debug.profileend()
		inventory.Topbar.Label.Text = `{NumberUtils:Comma(total)} Items • {NumberUtils:Comma(count)} Stacks`
	end)
end

function Backpack.onItemRemoved(p: string, flag2: boolean?)
	v13[p] = nil

	if not flag2 then
		setItemHotbarSlot(p) -- equivalent call inferred; original call site unknown
	end

	local v24 = v9[p]

	if v24 then
		v24:Destroy()
		v9[p] = nil
	end

	local index = table.find(v10, p)

	if index then
		table.remove(v10, index)
		Backpack.updateDisplayedItems()
	end
end

function Backpack.createInventoryItem(p: string)
	local component = objectHelper.create(p)
	component.Size = UDim2.fromOffset(v3, v3)
	v13[p] = true
	v9[p] = component
	dragHelper.setupUserInput({
		component = component,
		getItemId = function()
			return p
		end,
		canDrag = canDrag,
		action = Backpack.handleInput
	})
	table.insert(v10, p)
	Backpack.updateDisplayedItems()
end

function Backpack.getItemIdFromObject(p)
	if v11[p] then
		return v11[p]
	end

	local index = table.find(v8, p)

	if index then
		return v7[tostring(index)]
	end
end

function Backpack._awaitToolData(instance, p: string)
	local thread = coroutine.running()
	local destroyingConnection = instance.Destroying:Once(function()
		task.defer(thread, 2)
	end)
	local v24 = DataController.InventoryReplicator:Observe({ "Inventory", p }, function(p2)
		if p2 then
			task.defer(thread, 1)
		end
	end)
	local v25 = coroutine.yield()
	destroyingConnection:Disconnect()
	v24()
	return v25
end

function Backpack.onCharacterAdded(instance)
	local backpack3 = localPlayer:FindFirstChild("Backpack")

	if not backpack3 then
		return
	end

	local v24 = {}
	local v25 = {}

	for k in library.keyItems do
		v24[k] = true
	end

	for k in library.rods do
		v24[k] = true
	end

	for k in library.spears do
		v24[k] = true
	end

	for k in library.harpoonGuns do
		v24[k] = true
	end

	local function childAdded(tool)
		if tool:HasTag("FishTool") then
			v22 = tool
			return
		end

		if not tool:IsA("Tool") or v25[tool] then
			return
		end

		task.wait()

		if not tool.Parent or v25[tool] then
			return
		end

		v25[tool] = true
		tool.Destroying:Once(function()
			v25[tool] = nil
		end)
		local link = tool:FindFirstChild("link")
		local value = link and link.Value or tool.Name

		if link and not v5[value] and Backpack._awaitToolData(tool, value) == 2 then
			return
		end

		local forceHotbar = tool:GetAttribute("ForceHotbar")
		local hotbarKey = Backpack.getHotbarKey(value)
		local v26 = false

		for _, v28 in v7 do
			if v28 ~= hotbarKey then
				continue
			end

			v26 = true
			break
		end

		if not v26 then
			local v28 = false

			for i = 1, v18 do
				if v7[tostring(i)] then
					continue
				end

				setItemHotbarSlot(hotbarKey, i)
				v28 = true
				break
			end

			if forceHotbar and not v28 then
				setItemHotbarSlot(hotbarKey, v18)
			end
		end

		if forceHotbar then
			tool:SetAttribute("ForceHotbar", nil)
		end

		local function parentChanged()
			local v28 = v6
			local v30

			if tool.Parent then
				v30 = tool
			end

			v28[value] = v30

			if not tool.Parent and v9[value] and not link then
				Backpack.onItemRemoved(
					value,
					itemDisplayInfo[value].type == 0 or value == "rod" or value == "spear" or value == "harpoonGun"
				)
			elseif tool.Parent and not v9[value] and (v24[value] or tool:HasTag("ExternalGear")) then
				if tool:HasTag("ExternalGear") then
					itemDisplayInfo[value] = {
						rarity = "Error",
						tooltip = v6[value]:GetAttribute("DisplayName") or value,
						displayName = tool:GetAttribute("DisplayName") or value,
						color = Color3.fromRGB(255, 0, 255),
						icon = "rbxassetid://109908396333853"
					}
				end

				Backpack.createInventoryItem(value)
			elseif tool.Parent and v9[value] then
				scheduleItemUpdate(value)
			end
		end

		parentChanged()
		tool:GetPropertyChangedSignal("Parent"):Connect(parentChanged)
	end

	backpack3.ChildAdded:Connect(childAdded)
	instance.ChildAdded:Connect(childAdded)
	local v26 = 0

	for _, child in backpack3:GetChildren() do
		task.spawn(childAdded, child)

		if not (v26 >= 200) then
			continue
		end

		task.wait()
		v26 = 0
	end
end

function Backpack.equipRod()
	for k, v24 in v6 do
		if itemDisplayInfo[v24.Name].type ~= 3 then
			continue
		end

		Backpack.handleInput(k, "equip")
		return v24
	end

	return nil
end

function Backpack.equipSpear()
	for k, v24 in v6 do
		if itemDisplayInfo[v24.Name].type ~= 5 then
			continue
		end

		Backpack.handleInput(k, "equip")
		return v24
	end

	return nil
end

function Backpack.equipHarpoonGun()
	for k, v24 in v6 do
		if itemDisplayInfo[v24.Name].type ~= 7 then
			continue
		end

		Backpack.handleInput(k, "equip")
		return v24
	end

	return nil
end

function Backpack.equipItemByName(p: string)
	for k, v24 in v6 do
		if v24.Name ~= p then
			continue
		end

		Backpack.handleInput(k, "equip")
		return true, v24
	end

	local _, _, v24 = DataController.HasItem(p, nil, true)

	if not v24 then
		return false, nil
	end

	Backpack.handleInput(v24, "equip")
	return true, nil
end

function Backpack.init()
	DataController.PlayerDataReplicator:WaitForLoaded()
	DataController.InventoryReplicator:WaitForLoaded()

	for k, v24 in playerDataReplicator:Index({ "Hotbar" }) do
		if v24 == "rod" or v24 == "spear" or v24 == "harpoonGun" then
			v7[k] = v24
		elseif inventoryReplicator:TryIndex({ "Inventory", v24 }) or itemDisplayInfo[v24] and itemDisplayInfo[v24].type == 0 and not library.keyItems[v24].Removed then
			v7[k] = v24
		end
	end

	local gamepadCompat = script.gamepadCompat
	Backpack.gamepad = require(gamepadCompat)
	Backpack.gamepad.init(v8)

	if localPlayer.Character then
		task.spawn(Backpack.onCharacterAdded, localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(Backpack.onCharacterAdded)
	Backpack.refreshInventoryScroller = virtualScroller({
		maxItems = function()
			return #clone
		end,
		reconcile = Backpack.reconcileGrid,
		getItemSize = function()
			return v3
		end,
		getItemPadding = function()
			return 3
		end,
		scrollingFrame = inventory.scroll
	})
	task.spawn(function()
		local v25 = nil

		while not v25 do
			v25 = pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end)
			task.wait(0.1)
		end
	end)
	task.spawn(function()
		Backpack.updateHotbarItems()
		local fetched = legacyLocalPlayerData.fetch()
		rod = fetched:WaitForChild("Stats"):WaitForChild("rod")
		spear = fetched:WaitForChild("Stats"):WaitForChild("spear")
		Backpack.updateHotbarItems()
		local v25 = {
			rod = {
				DisplayType = 3,
				GetPath = function(p: string)
					return { "Rods", p }
				end
			},
			spear = {
				DisplayType = 5,
				GetPath = function(p: string)
					return { "Spears", p }
				end
			},
			harpoonGun = {
				DisplayType = 7,
				GetPath = function(p: string)
					return { "HarpoonGuns", "Owned", p }
				end
			}
		}
		local v26 = {}

		local function updateToolItem(displayType: number)
			for k, v27 in v6 do
				local v28 = itemDisplayInfo[v27.Name]

				if not (v28 and v28.type == displayType) then
					continue
				end

				scheduleItemUpdate(k)
				break
			end
		end

		local function listenEnchantUpdates(p: string, p2: string?)
			local v27 = v26[p]

			if v27 then
				v27()
				v26[p] = nil
			end

			if not p2 or p2 == "" then
				return
			end

			local v28 = v25[p]
			local path = v28.GetPath(p2)
			local v29 = playerDataReplicator:TryIndex(path)

			if not v29 then
				return
			end

			local enchant = v29.enchant
			local secondaryEnchant = v29.secondaryEnchant
			v26[p] = playerDataReplicator:Observe(path, function(p3)
				if not p3 or p3.enchant == enchant and p3.secondaryEnchant == secondaryEnchant then
					return
				end

				enchant = p3.enchant
				secondaryEnchant = p3.secondaryEnchant
				updateToolItem(v28.DisplayType)
			end)
		end

		listenEnchantUpdates("rod", rod.Value)
		rod.Changed:Connect(function()
			listenEnchantUpdates("rod", rod.Value)
		end)

		if spear then
			local v27 = spear
			listenEnchantUpdates("spear", v27.Value)
			v27.Changed:Connect(function()
				listenEnchantUpdates("spear", v27.Value)
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function relistenHarpoonEnchants()
			listenEnchantUpdates("harpoonGun", playerDataReplicator:TryIndex({ "HarpoonGuns", "Equipped" }))
		end

		relistenHarpoonEnchants() -- equivalent call inferred; original call site unknown
		playerDataReplicator:Listen({ "HarpoonGuns", "Equipped" }, relistenHarpoonEnchants)
	end)

	local function _updateInventory(p, p2)
		v5 = p
		objectHelper.setInventory(v5)
		dragHelper.setInventory(v5)
		local lastTime = os.clock()
		local v25

		if p2 then
			v25 = p2.Inventory or p
		else
			v25 = p
		end

		for k, v26 in v25 do
			if os.clock() - lastTime > 0.5 then
				task.wait()
				lastTime = os.clock()
			end

			if p[k] and not patch.isNone(v26) then
				if v9[k] then
					scheduleItemUpdate(k)
				else
					Backpack.createInventoryItem(k)
				end
			else
				Backpack.onItemRemoved(k)
			end
		end
	end

	DataController.InventoryReplicator:Listen({ "Inventory" }, _updateInventory)
	task.spawn(function()
		DataController.InventoryReplicator:WaitForLoaded()
		_updateInventory(DataController.InventoryReplicator:Index({ "Inventory" }))
	end)
	local v25 = {}
	DataController.PlayerDataReplicator:Observe({ "PersonalAquarium" }, function(p)
		if not p then
			return
		end

		local v26 = {}

		for _, v27 in p.FishIndex do
			if not v25[v27] then
				task.defer(scheduleItemUpdate, v27)
			end

			v26[v27] = true
		end

		for _, v27 in p.CosmeticFishIndex do
			if not v25[v27] then
				task.defer(scheduleItemUpdate, v27)
			end

			v26[v27] = true
		end

		for k in v25 do
			if not v26[k] then
				task.defer(scheduleItemUpdate, k)
			end
		end

		v25 = v26
	end)

	local function setToggleEnabled(childName: string, flag2: boolean)
		local child = inventory.Toggles:FindFirstChild(childName)
		TweenService:Create(child.Toggle.Switch, TweenInfo.new(0.2), {
			Position = UDim2.fromScale(flag2 and 1 or 0, 0.5)
		}):Play()
		local BG = child.Toggle.BG
		local tweenInfo = TweenInfo.new(0.2)
		local backgroundColor

		if flag2 then
			backgroundColor = Color3.fromRGB(0, 255, 85)
		else
			backgroundColor = Color3.fromRGB(255, 255, 255)
		end

		TweenService:Create(BG, tweenInfo, {
			BackgroundColor3 = backgroundColor
		}):Play()
		v17[childName] = flag2
		Backpack.updateDisplayedItems()
	end

	for _, button in inventory.Toggles:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v26 = button
		button.Activated:Connect(function()
			setToggleEnabled(v26.Name, not v17[v26.Name])
		end)
	end

	setToggleEnabled("Favourites", true)
	setToggleEnabled("Fishables", true)
	setToggleEnabled("Items", true)

	local function setSort(p: string?, flag2: boolean?)
		if p == nil then
			flag2 = false
			p = "Weight"
		end

		v20 = flag2
		v19 = p

		for _, button in inventory.SortOptions:GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			if button.Name == p then
				TweenService:Create(button.arrow, TweenInfo.new(0.2), {
					ImageTransparency = 0,
					Rotation = flag2 and 270 or 90
				}):Play()
			else
				TweenService:Create(button.arrow, TweenInfo.new(0.2), {
					ImageTransparency = 0.75,
					Rotation = 90
				}):Play()
			end
		end

		Backpack.updateDisplayedItems()
	end

	setSort(nil, nil)

	for _, button in inventory.SortOptions:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		button.arrow.ImageTransparency = 0.75
		local v26 = button
		button.Activated:Connect(function()
			if v19 ~= v26.Name then
				setSort(v26.Name, false)
			elseif v20 == true then
				setSort(nil, nil)
			else
				setSort(v26.Name, true)
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateInteractivity()
		inventory.scroll.Interactable = not (v21 or v14)
		inventory.scroll.Selectable = not (v21 or v14)
		inventory.scroll.Active = not (v21 or v14)
		inventory.TopButtons.Visible = not (v21 or storage.Visible)
		Backpack.refreshInventoryScroller(true)
	end

	confirmation.changed(function(p)
		v21 = p
		updateInteractivity() -- equivalent call inferred; original call site unknown
	end)
	local clone2 = ReplicatedStorage.resources.ui.backpack.tooltip:Clone()
	clone2.Position = UDim2.fromOffset(0, -10000, 0)
	clone2.Visible = true
	clone2.Parent = backpack
	local clone3 = ReplicatedStorage.resources.ui.hover:Clone()
	clone3.ZIndex = 100
	clone3.Visible = true
	clone3.Position = UDim2.fromOffset(0, -10000, 0)
	clone3.Parent = backpack
	local v26 = {
		Secret = {
			length = 2,
			colors = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0) }
		},
		["Divine Secret"] = {
			length = 2,
			colors = { Color3.fromRGB(117, 117, 255), Color3.fromRGB(224, 188, 255) }
		},
		Unique = {
			length = 1,
			colors = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 0) }
		},
		Mirror = {
			length = 1,
			colors = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(183, 214, 255) }
		},
		Whistle = {
			length = 1,
			colors = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(230, 230, 230) }
		},
		Exotic = {
			length = 3,
			colors = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(255, 128, 0),
				Color3.fromRGB(255, 247, 0),
				Color3.fromRGB(77, 255, 0),
				Color3.fromRGB(0, 255, 234),
				Color3.fromRGB(0, 115, 255),
				Color3.fromRGB(204, 0, 255)
			}
		},
		Special = {
			length = 6,
			colors = { Color3.fromRGB(255, 171, 255), Color3.fromRGB(147, 125, 255), Color3.fromRGB(255, 214, 117) }
		},
		Cataclysmic = {
			length = 6,
			colors = { Color3.fromRGB(141, 27, 31), Color3.fromRGB(139, 74, 0), Color3.fromRGB(54, 20, 20) }
		},
		Nuclear = {
			length = 2,
			colors = { Color3.fromRGB(26, 141, 0), Color3.fromRGB(214, 196, 0), Color3.fromRGB(26, 141, 0) }
		},
		Error = {
			length = 2,
			colors = { Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 0, 0) }
		}
	}

	local function updateGradient(p, p2)
		if not v5[p2] then
			return
		end

		local v27 = itemDisplayInfo[v5[p2].name]
		local color = v27 and v27.color

		if color then
			p.Rarity.UIGradient.Rotation = 0
			p.Rarity.UIGradient.Color = ColorSequence.new(color)
		else
			local rarity = v27 and v27.rarity

			if rarity and v26[rarity] then
				p.Rarity.UIGradient.Rotation = 0
				p.Rarity.UIGradient.Color = v26[rarity].eval
			end
		end
	end

	local v27 = nil
	UserInputService.InputBegan:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			v27 = nil
		elseif input.UserInputType == Enum.UserInputType.Touch then
			local function getHoveredItem()
				local vector2 = Vector2.new(input.Position.X, input.Position.Y)

				for _, v28 in legacyUiLoader.PlayerGui:GetGuiObjectsAtPosition(vector2.X, vector2.Y) do
					if Backpack.getItemIdFromObject(v28) then
						return Backpack.getItemIdFromObject(v28)
					end
				end
			end

			local hoveredItem = getHoveredItem()

			if not hoveredItem then
				return
			end

			local changedConnection = nil
			changedConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					changedConnection:Disconnect()

					if getHoveredItem() == hoveredItem then
						Backpack.handleInput(hoveredItem, "equip")
					end
				end
			end)
		end
	end)
	UserInputService.TouchEnded:Connect(function(_)
		v27 = time()
	end)
	UserInputService.TouchStarted:Connect(function()
		v27 = nil
	end)
	local absolutePosition = inventory.itemContainer.AbsolutePosition
	inventory.itemContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		absolutePosition = inventory.itemContainer.AbsolutePosition
	end)
	inventory.Topbar.DepositSearch:GetPropertyChangedSignal("Visible"):Connect(function()
		local visible = inventory.Topbar.DepositSearch.Visible
		inventory.Topbar.Search.Size = UDim2.fromScale(visible and 0.35 or 0.5, 1)
	end)

	function Backpack.updateGradient(p, p2)
		local color = itemDisplayInfo[p2.name].color

		if color then
			p.Rarity.UIGradient.Rotation = 0
			p.Rarity.UIGradient.Color = ColorSequence.new(color)
		else
			local rarity = itemDisplayInfo[p2.name].rarity

			if rarity and v26[rarity] then
				p.Rarity.UIGradient.Rotation = 0
				p.Rarity.UIGradient.Color = v26[rarity].eval
			end
		end
	end

	RunService.Heartbeat:Connect(function()
		local selectedObject = GuiService.SelectedObject

		if not selectedObject then
			local v28 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()

			for _, v30 in legacyUiLoader.PlayerGui:GetGuiObjectsAtPosition(v28.X, v28.Y) do
				if not Backpack.getItemIdFromObject(v30) then
					continue
				end

				selectedObject = v30
				break
			end
		end

		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
		local v28 = humanoid and humanoid.MoveDirection ~= createVector(0, 0, 0)

		if v14 or UserInputService.PreferredInput == Enum.PreferredInput.Touch and v28 then
			selectedObject = nil
		end

		local itemIdFromHotbarKey = Backpack.getItemIdFromHotbarKey(Backpack.getItemIdFromObject(selectedObject))

		if selectedObject and itemIdFromHotbarKey and not v21 then
			local position = selectedObject:GetAttribute("position")
			local absolutePosition2

			if position then
				absolutePosition2 = absolutePosition + Vector2.new(position.X.Offset, position.Y.Offset)
			else
				absolutePosition2 = selectedObject.AbsolutePosition
			end

			local v29 = absolutePosition2 + Vector2.new(v3 / 2, -8) + GuiService:GetGuiInset()
			clone2.Position = UDim2.fromOffset(v29.X, v29.Y)
			local name

			if v5[itemIdFromHotbarKey] then
				name = v5[itemIdFromHotbarKey].name or itemIdFromHotbarKey
			else
				name = itemIdFromHotbarKey
			end

			if not (v5[itemIdFromHotbarKey] or itemDisplayInfo[name]) then
				if v6[itemIdFromHotbarKey] and v6[itemIdFromHotbarKey]:HasTag("ExternalGear") then
					itemDisplayInfo[name] = {
						rarity = "Error",
						tooltip = v6[itemIdFromHotbarKey]:GetAttribute("DisplayName") or itemIdFromHotbarKey,
						displayName = v6[itemIdFromHotbarKey]:GetAttribute("DisplayName") or itemIdFromHotbarKey,
						color = Color3.fromRGB(255, 0, 255),
						icon = "rbxassetid://109908396333853"
					}
				else
					warn((`invalid item id {itemIdFromHotbarKey} spax fix this!`))
				end
			end

			local v30 = itemDisplayInfo[name]
			local rarity = v30.rarity
			local tooltip

			if v30.tooltip then
				tooltip = v30.tooltip
			else
				if rarity == "" then
					tooltip = v30.displayName
				else
					tooltip = rarity
				end

				if library.fish[name] then
					if v5[itemIdFromHotbarKey] and v5[itemIdFromHotbarKey].sub and typeof(v5[itemIdFromHotbarKey].sub.Weight) == "number" then
						tooltip ..= "\nWeight: " .. `{math.floor(v5[itemIdFromHotbarKey].sub.Weight * 10) / 10}kg`
					else
						LogService:Warn("bro dis fish {itemKey} got no weight 😭😭😭😭😭", {
							itemKey = name,
							itemData = v5[itemIdFromHotbarKey]
						})
					end

					local sellFish = fishing:SellFish(localPlayer, v5[itemIdFromHotbarKey], true)
					tooltip ..= `\nPrice: {NumberUtils:Comma((math.ceil(sellFish)))} C$`

					if v5[itemIdFromHotbarKey].sub and v5[itemIdFromHotbarKey].sub.Serial then
						tooltip ..= "\n☆Serial: " .. `#{v5[itemIdFromHotbarKey].sub.Serial}`
					end
				end
			end

			clone2.Text = tooltip
			local _ = -math.floor(math.abs(math.sin(time() * 2.5) * 4) / 2) * 2
			local v31 = absolutePosition2 + Vector2.new(v3 / 2, v3 / 2) + GuiService:GetGuiInset()
			clone3.Position = UDim2.fromOffset(v31.X, v31.Y)
			clone3.Size = UDim2.fromOffset(v3, v3)
			clone3.Visible = true
			local color = library.rarities.StaticColors[rarity] or Color3.fromRGB(175, 175, 175)

			if v26[rarity] then
				local length = v26[rarity].length
				color = evalColorSequenceEqual(v26[rarity].colors, time() % length / length)
			end

			if itemDisplayInfo[name].type == 3 then
				color = library.rods[itemIdFromHotbarKey].Color
			elseif itemDisplayInfo[name].type == 5 then
				color = library.spears[itemIdFromHotbarKey].Color
			elseif itemDisplayInfo[name].type == 7 then
				color = library.harpoonGuns[itemIdFromHotbarKey].Color
			end

			clone3.ImageColor3 = color
			clone3.UIStroke.Color = clone3.ImageColor3

			if v27 and time() - v27 > 0.5 then
				local v32 = (time() - v27 - 0.5) / 0.2
				clone2.BackgroundTransparency = v32
				clone2.UIStroke.Transparency = math.clamp(v32, 0, 1)
				clone2.TextTransparency = v32
				clone3.ImageTransparency = v32
			else
				clone2.BackgroundTransparency = 0
				clone2.UIStroke.Transparency = 0
				clone2.TextTransparency = 0
				clone3.ImageTransparency = 0
			end
		else
			clone2.Position = UDim2.fromOffset(0, -10000)
			clone3.Position = UDim2.fromOffset(0, -10000)
		end

		for _, v29 in v26 do
			local length = v29.length
			local colors = v29.colors
			local v30 = time() % length / length
			local colorSequenceKeypoints = {}
			local v31 = false

			for i = 1, #colors + 1 do
				local v32 = colors[i] or colors[i - #colors]
				local v33 = v30 + (i - 1) / #colors

				if v33 > 1 then
					v33 -= 1
				end

				v31 = v33 == 0 or v33 == 1 or v31
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v33, v32))
			end

			if not v31 then
				local v32 = (1 - v30) / (1 / #colors) + 1
				local lerped = colors[math.floor(v32)]:Lerp(colors[math.ceil(v32)] or colors[1], v32 % 1)
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(0, lerped))
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, lerped))
			end

			table.sort(colorSequenceKeypoints, function(a, b)
				return a.Time < b.Time
			end)
			v29.eval = ColorSequence.new(colorSequenceKeypoints)
		end

		for k, v29 in v11 do
			updateGradient(k, v29)
		end

		for k, v29 in v8 do
			updateGradient(v29, Backpack.getItemIdFromHotbarKey(v7[tostring(k)]))
		end

		if v16 and v14 then
			updateGradient(v16, v14)
		end
	end)
	Backpack.updateUIScaling()
	task.delay(3, Backpack.updateUIScaling)
	hotbar:GetPropertyChangedSignal("AbsoluteSize"):Connect(Backpack.updateUIScaling)
	storage:GetPropertyChangedSignal("Visible"):Connect(Backpack.updateUIScaling)
	dragHelper.setupDragTarget(inventory.scroll, "Inventory")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setDragging(p: string?)
		if v14 and v9[v14] then
			v9[v14].Visible = true
		end

		v14 = p

		if v14 and v9[v14] then
			v9[v14].Visible = false
		end
	end

	function dragHelper.onDragStart(p: string, parent)
		setDragging(p) -- equivalent call inferred; original call site unknown
		updateInteractivity() -- equivalent call inferred; original call site unknown
		Backpack.updateHotbarItems()

		if v16 then
			v16:Destroy()
		end

		parent.BackgroundTransparency = 1
		v16 = objectHelper.create(p)
		v16.Active = false
		v16.AutoButtonColor = false
		v16.Interactable = false
		v16.AnchorPoint = Vector2.new(0.5, 0.5)
		v16.Parent = parent
		objectHelper.update(v16, p)
	end

	function dragHelper.onDragEnd(p: string, value: string)
		local function isAttemptedStorageDeposit()
			local storage2 = legacyUiLoader.PlayerGui.hud.safezone.storage

			if p or value or not v14 then
				return false
			end

			if storage2.Visible then
				return true
			end

			return false
		end

		local storage2 = legacyUiLoader.PlayerGui.hud.safezone.storage
		local v28

		if p or value or not v14 then
			v28 = false
		else
			v28 = storage2.Visible and true or false
		end

		if v28 then
			remoteEvent4:FireServer(v14)
		end

		v15 = nil
		setDragging(nil) -- equivalent call inferred; original call site unknown
		updateInteractivity() -- equivalent call inferred; original call site unknown
		local hotbarKey = Backpack.getHotbarKey(p)

		if type(value) == "number" then
			local v29 = nil

			for k, v31 in v7 do
				if v31 ~= hotbarKey then
					continue
				end

				v29 = tonumber(k)
				break
			end

			local v31 = v7[tostring(value)]

			if v31 and v29 then
				setItemHotbarSlot(Backpack.getHotbarKey(v31), v29)
			end

			setItemHotbarSlot(hotbarKey, value)
		elseif value == "Inventory" then
			for _, v29 in v7 do
				if v29 ~= hotbarKey then
					continue
				end

				setItemHotbarSlot(hotbarKey) -- equivalent call inferred; original call site unknown
				return
			end

			Backpack.handleInput(Backpack.getItemIdFromHotbarKey(p), "equip")
		else
			if p then
				Backpack.handleInput(Backpack.getItemIdFromHotbarKey(p), "equip")
				return
			end

			Backpack.updateHotbarItems()
			Backpack.updateDisplayedItems()
		end
	end

	function dragHelper.onDragHoveredTarget(_: string, value: string?)
		if type(value) ~= "number" then
			value = false
		end

		v15 = value
		Backpack.updateHotbarItems()
	end

	inventory.Visible = false
	local absoluteSize2 = backpack.AbsoluteSize

	local function refreshHotbarVisiblity()
		local visible = true

		for _, screenGui in v2 do
			local v30

			if screenGui:IsA("ScreenGui") then
				v30 = screenGui
			else
				v30 = screenGui:FindFirstAncestorOfClass("ScreenGui")
			end

			if not ((screenGui:IsA("ScreenGui") or screenGui.Visible) and v30.Enabled) then
				continue
			end

			visible = false
			break
		end

		if backpack.AbsoluteSize.Y < 400 then
			hotbar.Visible = visible
		else
			hotbar.Visible = true
		end
	end

	for _, screenGui in v2 do
		if screenGui:IsA("ScreenGui") then
			screenGui:GetPropertyChangedSignal("Enabled"):Connect(refreshHotbarVisiblity)
		else
			screenGui:FindFirstAncestorOfClass("ScreenGui"):GetPropertyChangedSignal("Enabled"):Connect(refreshHotbarVisiblity)
			screenGui:GetPropertyChangedSignal("Visible"):Connect(refreshHotbarVisiblity)
		end
	end

	backpack:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		absoluteSize2 = backpack.AbsoluteSize
		refreshHotbarVisiblity()
	end)
	backpack:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not backpack.Enabled then
			inventory.Visible = false
		end

		backpack2.Enabled = backpack.Enabled
	end)
	workspace:GetAttributeChangedSignal("ClientCutsceneRunning"):Connect(function()
		if workspace:GetAttribute("ClientCutsceneRunning") then
			backpack.Enabled = false
		elseif localPlayer.PlayerGui:GetAttribute("UiEnabled") then
			backpack.Enabled = true
		end
	end)
	inventory:GetPropertyChangedSignal("Visible"):Connect(function()
		if inventory.Visible then
			GuiService.GuiNavigationEnabled = false
			legacyUiLoader.PlayerGui.hud.deviceinset.Enabled = false
		else
			GuiService.GuiNavigationEnabled = true
			legacyUiLoader.PlayerGui.hud.deviceinset.Enabled = true
		end

		(localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")):SetStateEnabled(
			Enum.HumanoidStateType.Jumping,
			not inventory.Visible
		)
		Backpack.updateHotbarItems()
		currentServerBoosts.Enabled = not inventory.Visible
		hotbar.Folder.Frame.Open.Visible = not inventory.Visible
	end)
	inventory.TopButtons.Close.Activated:Connect(function()
		inventory.Visible = false
	end)
	inventory.TopButtons.Appraise.Activated:Connect(function()
		if not marketplace.userHasGamepassAsync(localPlayer, 986882975) then
			MarketplaceService:PromptGamePassPurchase(localPlayer, 986882975)
			return
		end

		local v28 = Backpack.getEquippedItemId() and Net:RemoteFunction("AppraiseAnywhere/GetCost"):InvokeServer()

		if v28 then
			confirmation.prompt({
				text = ("Appraise for %s" .. CurrencyController:GetDisplay()):format(v28),
				no = function() end,
				yes = function()
					local _, text = Net:RemoteFunction("AppraiseAnywhere/Fire"):InvokeServer()

					if text then
						confirmation.prompt({
							text = text,
							yes = function() end
						})
					end
				end
			})
		else
			confirmation.prompt({
				text = "Equip a fish!",
				yes = function() end
			})
		end
	end)
	local flag2 = false
	inventory.TopButtons.Sell.Activated:Connect(function()
		if flag2 then
			return
		end

		if not marketplace.userHasGamepassAsync(localPlayer, 901839344) then
			MarketplaceService:PromptGamePassPurchase(localPlayer, 901839344)
			return
		end

		flag2 = true
		local prompt = confirmation.prompt({
			text = "Sell every fish not favourited in your inventory?",
			no = function() end,
			yes = function()
				if not ReplicatedStorage.events.selleverything:InvokeServer() then
					confirmation.prompt({
						text = "You have no sellable fish!",
						yes = function() end
					})
				end
			end
		})
		local v28 = ReplicatedStorage.events.PreviewSellAll:InvokeServer(false)
		prompt.Text ..= ` [<font color='#e4e596'><b>{NumberUtils:Comma(v28)} C$</b></font>]`
		flag2 = false
	end)
	inventory.TopButtons.Enchant.Activated:Connect(function()
		if marketplace.userHasGamepassAsync(localPlayer, v) then
			confirmation.prompt({
				text = "Enchant your Rod? (Must be holding a Relic)",
				no = function() end,
				yes = function()
					local InventoryController = require(ReplicatedStorage.client.legacyControllers.InventoryController)

					if InventoryController.EquippedItem and InventoryController.EquippedItem.name == "Sovereign Relic" and #workspace:QueryDescendants(".EnchantAltar") == 0 then
						confirmation.prompt({
							text = "You're too far away from the Enchant Altar to use a Sovereign Relic...",
							yes = function() end
						})
						return
					end

					local text = ReplicatedStorage.events.enchantrod:InvokeServer()

					if text == true then
						ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("enchantRemote"):Play()
					else
						confirmation.prompt({
							text = text,
							yes = function() end
						})
					end
				end
			})
		else
			MarketplaceService:PromptGamePassPurchase(localPlayer, v)
		end
	end)
	backpack.hotbar.Folder.Frame.Open.Activated:Connect(function()
		Backpack.toggleInventory()
	end)
	inventory.Topbar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(Backpack.updateDisplayedItems)
	localPlayer:GetAttributeChangedSignal("SellingFish"):Connect(Backpack.updateDisplayedItems)
	InputController.Observe(function(p)
		if p == "MouseKeyboard" then
			backpack.hotbar.Folder.Frame.Open.Text = "Press (G) To Open"
		elseif p == "Touch" then
			backpack.hotbar.Folder.Frame.Open.Text = "Touch To Open"
		elseif p == "Gamepad" then
			backpack.hotbar.Folder.Frame.Open.Text = "Press (RIGHT) to Open"
		end
	end)
	backpack2.OpenInventory.Pressed:Connect(function()
		Backpack.toggleInventory()
	end)
	ContextActionService:BindAction("BackpackEquip", function(_, p, p2)
		if p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		local index = table.find(v23, p2.KeyCode)
		local v28 = v7[tostring(index)]

		if v28 then
			Backpack.handleInput(v28, "equip")
			return Enum.ContextActionResult.Sink
		end

		return Enum.ContextActionResult.Pass
	end, false, unpack(v23))
	backpack2.EquipRod.Pressed:Connect(function()
		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and (not SettingsController:GetSettingValue("consoleHotkeys") or localPlayer:GetAttribute("FlyingLocal")) then
			return
		end

		Backpack.equipRod()
	end)
	backpack2.OpenQuestBook.Pressed:Connect(function()
		Backpack.equipItemByName("Quest Book")
	end)
	backpack2.OpenBestiary.Pressed:Connect(function()
		Backpack.equipItemByName("Bestiary")
	end)
	backpack2.OpenEquipmentBag.Pressed:Connect(function()
		Backpack.equipItemByName("Equipment Bag")
	end)
	backpack2.OpenCompanionSatchel.Pressed:Connect(function()
		Backpack.equipItemByName("Companion Satchel")
	end)
	backpack2.Enabled = backpack.Enabled
	local v28 = 0

	local function onJumpRequest()
		local settingValue = SettingsController:GetSettingValue("gliderDeployMode")

		if settingValue == "disabled" then
			return
		end

		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")

		if not humanoid or humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
			return
		end

		local v29 = time()
		local v30 = v29 - v28
		v28 = v29

		if v30 <= 0.3 then
			return
		end

		local v31 = {}
		local v32 = 0
		local v33 = nil

		for k, v34 in v5 do
			if not gliderdata[v34.name] then
				continue
			end

			local priority = gliderdata[v34.name].Priority

			if settingValue == "hotbar" then
				if not isOnHotbar(k) then
					continue
				end
			elseif (settingValue == "favorited" or settingValue == "randomFavorited") and v34.sub and v34.sub.Favourited then
				if settingValue == "randomFavorited" then
					table.insert(v31, k)
				else
					priority += 1000
				end
			end

			if not (v32 < priority) then
				continue
			end

			v33 = k
			v32 = priority
		end

		if settingValue == "randomFavorited" and #v31 > 0 then
			v33 = v31[math.random(1, #v31)]
		end

		if v33 then
			Backpack.handleInput(v33, "equip")
		end
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.Space and not gameProcessed or input.KeyCode == Enum.KeyCode.ButtonA and not UserInputService:GetFocusedTextBox() and JumpProtectController:CanJump() then
			onJumpRequest()
		end
	end)
	task.spawn(function()
		local touchGui = legacyUiLoader.PlayerGui:WaitForChild("TouchGui", 1e999)
		local touchControlFrame = touchGui and touchGui:WaitForChild("TouchControlFrame", 1e999)
		local jumpButton = touchControlFrame and touchControlFrame:WaitForChild("JumpButton", 1e999)

		if jumpButton then
			jumpButton.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == Enum.UserInputType.Touch then
					onJumpRequest()
				end
			end)
		end
	end)
	playerDataReplicator:Listen({ "HarpoonGuns", "Equipped" }, function()
		Backpack.updateHotbarItems()
		Backpack.updateDisplayedItems()
	end)
end

return Backpack