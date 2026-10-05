local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("UserInputService")
local Net = require(ReplicatedStorage.packages.Net)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
require(ReplicatedStorage.shared.modules.library)
local fishing = require(ReplicatedStorage.shared.modules.fishing)
local itemHelper = require(script.itemHelper)
require(ReplicatedStorage.client.modules.ui.Backpack.sortHelper)
local objectHelper = require(ReplicatedStorage.client.modules.ui.Backpack.objectHelper)
local itemDisplayInfo = require(ReplicatedStorage.client.modules.ui.Backpack.itemDisplayInfo)
local environment = require(ReplicatedStorage.shared.environment)
local repr = require(ReplicatedStorage.shared.utils.repr)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local library = require(ReplicatedStorage.shared.modules.library)
local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local gliderdata = require(ReplicatedStorage.shared.modules.library.items.gliderdata)
local items = require(ReplicatedStorage.shared.modules.library.items)
local halos = require(ReplicatedStorage.shared.modules.library.halos)
local lanterns = require(ReplicatedStorage.shared.modules.library.lanterns)
local SalesBooth = require(ReplicatedStorage.shared.modules.SalesBooth)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local localPlayer = Players.LocalPlayer
local v = 0
local remoteEvent = Net:RemoteEvent("Trade/UpdateOfferedItems")
local remoteEvent2 = Net:RemoteEvent("Trade/AddItem")
local remoteEvent3 = Net:RemoteEvent("Trade/RemoveItem")
local remoteEvent4 = Net:RemoteEvent("Trade/TradeStarted")
local remoteEvent5 = Net:RemoteEvent("Trade/TradeEnded")
local remoteEvent6 = Net:RemoteEvent("Trade/CancelTrade")
local remoteEvent7 = Net:RemoteEvent("Trade/SetReady")
local trade = legacyUiLoader.PlayerGui.hud.safezone.Trade
local otherOffer = trade.OtherOffer
local playerOffer = trade.PlayerOffer
local v2 = true
local v3 = nil
local Trade = {}
local v4 = {}

local function getTypeAndId(value)
	local parts = value:split("\254\254")
	return parts[1], parts[2]
end

function Trade.clearPlayerOfferableItems()
	for _, v5 in v4 do
		v5:Destroy()
	end

	table.clear(v4)
end

function Trade.updatePlayerOfferableItems()
	if not v2 then
		return
	end

	local fetched = legacyLocalPlayerData.fetch()
	v2 = false

	for _, v5 in v4 do
		v5[2]:Destroy()
	end

	table.clear(v4)
	local currency = itemHelper.create({
		type = "Currency",
		data = 0
	}, true)
	currency.Name = "CurrencyInput"
	currency:SetAttribute("tab", "")
	currency.InputBox.FocusLost:Connect(function(p)
		local text = tonumber(currency.InputBox.Text)

		if p and text then
			if text > 0 then
				remoteEvent2:FireServer("Currency", "Currency", text)
			else
				remoteEvent3:FireServer("Currency", "Currency")
			end
		end
	end)
	v4.Currency = currency
	DataController.InventoryReplicator:WaitForLoaded()
	local index = DataController.InventoryReplicator:Index({ "Inventory" })

	for k, v6 in index do
		if not library.fish[v6.name] or (library.fish[v6.name].IsCrate or library.fish[v6.name].Untradeable) then
			continue
		end

		if not (not v6.sub.CanTradeIn or not (v6.sub.CanTradeIn > workspace:GetServerTimeNow()) and v6.sub.CanTradeIn ~= -1) then
			continue
		end

		if not (v6.name ~= "Forbidden Plesiosaur" or v6.sub.Serial and not (v6.sub.Serial >= 1185 and v6.sub.Serial <= 1276)) then
			continue
		end

		if v6.sub.Mutation and library.mutations[v6.sub.Mutation] and library.mutations[v6.sub.Mutation].Untradeable then
			continue
		end

		local v7 = itemHelper.create({
			type = "Item",
			data = v6
		}, true)
		v7.Name = v6.name
		v7:SetAttribute("itemId", k)
		v7:SetAttribute("tab", "Fish")
		local v8 = k
		v7.Activated:Connect(function()
			local v9 = v3 and v3.offer[localPlayer.Name][("Item\254\254%*"):format(v8)]
			remoteEvent2:FireServer("Item", v8, not v9 and 1 or v9.stack + 1)
		end)
		v7.LayoutOrder = 50000 + (v6.sub and v6.sub.Weight or 0)
		v4[("Item\254\254%*"):format(k)] = v7
	end

	DataController.PlayerDataReplicator:WaitForLoaded()
	local index2 = DataController.PlayerDataReplicator:Index({ "RodSkins" })

	for k, _ in index2 do
		if not RodSkins.Skins[k] or RodSkins.Skins[k].Untradeable then
			continue
		end

		local v6 = itemHelper.create({
			type = "RodSkin",
			data = k
		}, true)
		v6.Name = k
		v6:SetAttribute("tab", "RodSkin")
		local v7 = k
		v6.Activated:Connect(function()
			local v8 = v3 and v3.offer[localPlayer.Name][("RodSkin\254\254%*"):format(v7)]
			remoteEvent2:FireServer("RodSkin", v7, not v8 and 1 or v8.stack + 1)
		end)
		v6.LayoutOrder = 10000
		v4[("RodSkin\254\254%*"):format(k)] = v6
	end

	local bobber = fetched:FindFirstChild("Stats") and fetched.Stats:FindFirstChild("bobber")

	if bobber then
		for _, child in bobber:GetChildren() do
			if not bobbers.Bobbers[child.Name] or bobbers.Bobbers[child.Name].Untradeable or child.Name == "Stock" then
				continue
			end

			local v6 = itemHelper.create({
				type = "Bobber",
				data = child.Name
			}, true)
			v6.Name = child.Name
			v6:SetAttribute("tab", "Bobber")
			local v7 = child
			v6.Activated:Connect(function()
				local v8 = v3 and v3.offer[localPlayer.Name][("Bobber\254\254%*"):format(v7.Name)]
				local v9 = not v8 and 1 or v8.stack + 1
				remoteEvent2:FireServer("Bobber", v7.Name, v9)
			end)
			v6.LayoutOrder = 20000
			v4[("Bobber\254\254%*"):format(child.Name)] = v6
		end
	end

	local boats = fetched:FindFirstChild("Boats")

	if boats then
		for _, child in boats:GetChildren() do
			if not vessels.library[child.Name] or vessels.library[child.Name].Untradeable then
				continue
			end

			local v6 = itemHelper.create({
				type = "Boat",
				data = child.Name
			}, true)
			v6.Name = child.Name
			v6:SetAttribute("tab", "Vessel")
			local v7 = child
			v6.Activated:Connect(function()
				local v8 = v3 and v3.offer[localPlayer.Name][("Boat\254\254%*"):format(v7.Name)]
				local v9 = not v8 and 1 or v8.stack + 1
				remoteEvent2:FireServer("Boat", v7.Name, v9)
			end)
			v6.LayoutOrder = 30000
			v4[("Boat\254\254%*"):format(child.Name)] = v6
		end
	end

	local index3 = DataController.PlayerDataReplicator:Index({ "Halos" })

	if index3 and index3.Owned then
		for k, v6 in pairs(index3.Owned) do
			if not v6 or not v6.stack or v6.stack <= 0 or not halos[k] then
				continue
			end

			if halos[k].Untradeable then
				continue
			end

			local v7 = itemHelper.create({
				type = "Halo",
				data = k
			}, true)
			v7.Name = k
			v7:SetAttribute("tab", "Halo")
			local v8 = k
			v7.Activated:Connect(function()
				local v9 = v3 and v3.offer[localPlayer.Name][("Halo\254\254%*"):format(v8)]
				remoteEvent2:FireServer("Halo", v8, not v9 and 1 or v9.stack + 1)
			end)
			v7.LayoutOrder = 40000
			v4[("Halo\254\254%*"):format(k)] = v7
		end
	end

	local lanterns2 = fetched:FindFirstChild("Lanterns")

	if lanterns2 then
		for _, child in lanterns2:GetChildren() do
			if not lanterns[child.Name] or (lanterns[child.Name].Untradeable or (tonumber(child.Value) or 0) <= 0) then
				continue
			end

			local v6 = itemHelper.create({
				type = "Lantern",
				data = child.Name
			}, true)
			v6.Name = child.Name
			v6:SetAttribute("tab", "Lantern")
			local v7 = child
			v6.Activated:Connect(function()
				local v8 = v3 and v3.offer[localPlayer.Name][("Lantern\254\254%*"):format(v7.Name)]
				local v9 = not v8 and 1 or v8.stack + 1
				remoteEvent2:FireServer("Lantern", v7.Name, v9)
			end)
			v6.LayoutOrder = 45000
			v4[("Lantern\254\254%*"):format(child.Name)] = v6
		end
	end

	local index4 = DataController.PlayerDataReplicator:Index({ "SalesBooth" })

	if index4 and index4.Skins then
		for k, skin in index4.Skins do
			local v6 = 0
			local v7

			if typeof(skin) == "table" then
				v7 = skin.stack or 0
			else
				v7 = skin == true and 1 or v6
			end

			if v7 <= 0 then
				continue
			end

			local item = SalesBooth.Items[k]

			if not item or item.Untradeable or k == "Default" then
				continue
			end

			local v8 = itemHelper.create({
				type = "BoothSkin",
				data = k
			}, true)
			v8.Name = k
			v8:SetAttribute("tab", "BoothSkin")
			local v9 = k
			v8.Activated:Connect(function()
				local v10 = v3 and v3.offer[localPlayer.Name][("BoothSkin\254\254%*"):format(v9)]
				remoteEvent2:FireServer("BoothSkin", v9, not v10 and 1 or v10.stack + 1)
			end)
			v8.LayoutOrder = 50000
			v4[("BoothSkin\254\254%*"):format(k)] = v8
		end
	end

	DataController.InventoryReplicator:WaitForLoaded()

	for k, v6 in DataController.InventoryReplicator:Index({ "Inventory" }) do
		if not gliderdata[v6.name] or items.Items[v6.name] and items.Items[v6.name].Untradeable then
			continue
		end

		if not (not v6.sub.CanTradeIn or not (v6.sub.CanTradeIn > workspace:GetServerTimeNow()) and v6.sub.CanTradeIn ~= -1) then
			continue
		end

		if not (v6.name ~= "Forbidden Plesiosaur" or v6.sub.Serial and not (v6.sub.Serial >= 1185 and v6.sub.Serial <= 1276)) then
			continue
		end

		local v7 = itemHelper.create({
			type = "Glider",
			data = v6
		}, true)
		v7.Name = v6.name
		v7:SetAttribute("itemId", k)
		v7:SetAttribute("tab", "Glider")
		local v8 = k
		v7.Activated:Connect(function()
			local v9 = v3 and v3.offer[localPlayer.Name][("Glider\254\254%*"):format(v8)]
			remoteEvent2:FireServer("Glider", v8, not v9 and 1 or v9.stack + 1)
		end)
		v7.LayoutOrder = 55000
		v4[("Glider\254\254%*"):format(k)] = v7
	end

	local index5 = DataController.PlayerDataReplicator:Index({ "Companions" })

	if index5 and index5.Skins then
		for k, skin in index5.Skins do
			if (typeof(skin) ~= "table" and 0 or skin.stack or 0) <= 0 then
				continue
			end

			local skin2 = skins.Skins[k]

			if not skin2 or skin2.Untradeable then
				continue
			end

			local v6 = itemHelper.create({
				type = "CompanionSkin",
				data = k
			}, true)
			v6.Name = k
			v6:SetAttribute("tab", "CompanionSkin")
			local v7 = k
			v6.Activated:Connect(function()
				local v8 = v3 and v3.offer[localPlayer.Name][("CompanionSkin\254\254%*"):format(v7)]
				remoteEvent2:FireServer("CompanionSkin", v7, not v8 and 1 or v8.stack + 1)
			end)
			v6.LayoutOrder = 52000
			v4[("CompanionSkin\254\254%*"):format(k)] = v6
		end
	end

	Trade.updateSearch()

	for _, v6 in v4 do
		v6.Parent = playerOffer.List.Offerables
	end
end

function Trade.tradeStarted(p)
	trade.Visible = true
	Trade.setViewingOfferables(false)
	playerOffer.Header.Label.Text = "@" .. localPlayer.Name
	playerOffer.Header.Icon.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=180&h=180`
	otherOffer.Header.Label.Text = "@" .. p.Name
	otherOffer.Header.Icon.Image = `rbxthumb://type=AvatarHeadShot&id={p.UserId}&w=180&h=180`
	v2 = true
	Trade.updatePlayerOfferableItems()
end

function Trade.updateConfirmationState(p)
	if p then
		local function refresh()
			if v3 ~= p then
				return
			end

			Trade.updateConfirmationState(p)
		end

		local v5 = p.player1 == localPlayer and "player1" or "player2"
		local v6 = v5 == "player1" and "player2" or "player1"
		local otherOffer2 = otherOffer
		playerOffer.Header.Confirmed.Visible = p[`{v5}Confirmed`]
		otherOffer2.Header.Confirmed.Visible = p[`{v6}Confirmed`]

		if p.acceptTimer == 0 then
			if p[`{v5}Confirmed`] then
				trade.Options.Ready.Waiting.Text = "Waiting for other player..."
			else
				trade.Options.Ready.Waiting.Text = ""
			end

			local v8 = v - workspace:GetServerTimeNow()

			if v8 > 0 then
				trade.Options.Ready.Label.Text = `Ready ({math.ceil(v8)})`
				task.delay(0.5, refresh)
			elseif p[`{v5}Confirmed`] then
				trade.Options.Ready.Label.Text = "Unready"
			else
				trade.Options.Ready.Label.Text = "Ready"
			end
		else
			trade.Options.Ready.Label.Text = "Unready"
			trade.Options.Ready.Waiting.Text = `Accepting in {math.ceil((math.max(0, p.acceptTimer - workspace:GetServerTimeNow())))}s`
			task.delay(0.5, refresh)
		end
	else
		trade.Options.Ready.Label.Text = "Ready"
		trade.Options.Ready.Waiting.Text = ""
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisiblity(instance)
	instance.Visible = instance:GetAttribute("searched") and instance:GetAttribute("stackedVisible")
end

local v5 = {}

function Trade.updateOfferedItems(p)
	for _, v6 in v5 do
		v6:Destroy()
	end

	table.clear(v5)
	local fetched = legacyLocalPlayerData.fetch()
	local bobber = fetched:WaitForChild("Stats"):WaitForChild("bobber")
	local boats = fetched:WaitForChild("Boats")

	for k, v6 in v4 do
		if k == "Currency" then
			continue
		end

		local parts = k:split("\254\254")
		local part = parts[1]
		local part2 = parts[2]

		if part == "Item" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			local stack = DataController.getItem(part2).sub.Stack or 1
			local stack2 = v6:FindFirstChild("Stack")

			if stack <= v8 then
				v6:SetAttribute("stackedVisible", false)
			else
				v6:SetAttribute("stackedVisible", true)

				if stack2 then
					if stack - v8 == 1 then
						stack2.Text = ""
					else
						stack2.Text = `x{stack - v8}`
					end
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "RodSkin" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			DataController.PlayerDataReplicator:WaitForLoaded()
			local v9 = DataController.PlayerDataReplicator:TryIndex({ "RodSkins", part2, "stack" }) or 1
			local stack = v6:FindFirstChild("Stack")

			if stack then
				if v9 <= v8 then
					v6:SetAttribute("stackedVisible", false)
				else
					v6:SetAttribute("stackedVisible", true)
					stack.Text = `x{v9 - v8}`
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "Bobber" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			local value = tonumber(bobber:FindFirstChild(part2).Value) or 1
			local stack = v6:FindFirstChild("Stack")

			if stack then
				if value <= v8 then
					v6:SetAttribute("stackedVisible", false)
				else
					v6:SetAttribute("stackedVisible", true)
					stack.Text = `x{value - v8}`
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "Boat" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			local value = tonumber(boats:FindFirstChild(part2).Value) or 1
			local stack = v6:FindFirstChild("Stack")

			if stack then
				if value <= v8 then
					v6:SetAttribute("stackedVisible", false)
				else
					v6:SetAttribute("stackedVisible", true)
					stack.Text = `x{value - v8}`
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "Halo" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			DataController.PlayerDataReplicator:WaitForLoaded()
			local v9 = DataController.PlayerDataReplicator:TryIndex({
				"Halos",
				"Owned",
				part2,
				"stack"
			}) or 0
			local stack = v6:FindFirstChild("Stack")

			if stack then
				if v9 <= v8 then
					v6:SetAttribute("stackedVisible", false)
				else
					v6:SetAttribute("stackedVisible", true)
					stack.Text = `x{v9 - v8}`
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "Lantern" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			local child = fetched:FindFirstChild("Lanterns") and fetched.Lanterns:FindFirstChild(part2)
			local v9 = not child and 0 or tonumber(child.Value) or 1
			local stack = v6:FindFirstChild("Stack")

			if stack then
				if v9 <= v8 then
					v6:SetAttribute("stackedVisible", false)
				else
					v6:SetAttribute("stackedVisible", true)
					stack.Text = `x{v9 - v8}`
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "BoothSkin" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			DataController.PlayerDataReplicator:WaitForLoaded()
			local v9 = DataController.PlayerDataReplicator:TryIndex({ "SalesBooth", "Skins", part2 })
			local v10 = 0
			local stack

			if typeof(v9) == "table" then
				stack = v9.stack or 0
			else
				stack = v9 == true and 1 or v10
			end

			local stack2 = v6:FindFirstChild("Stack")

			if stack2 then
				if stack <= v8 then
					v6:SetAttribute("stackedVisible", false)
				else
					v6:SetAttribute("stackedVisible", true)
					stack2.Text = `x{stack - v8}`
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "Glider" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			local item = DataController.getItem(part2)
			local v9 = not item and 0 or item.sub.Stack or 1
			local stack = v6:FindFirstChild("Stack")

			if v9 <= v8 then
				v6:SetAttribute("stackedVisible", false)
			else
				v6:SetAttribute("stackedVisible", true)

				if stack then
					if v9 - v8 == 1 then
						stack.Text = ""
					else
						stack.Text = `x{v9 - v8}`
					end
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		elseif part == "CompanionSkin" then
			local v7 = p.offer[localPlayer.Name][k]
			local v8 = not v7 and 0 or v7.stack or 1
			DataController.PlayerDataReplicator:WaitForLoaded()
			local v9 = DataController.PlayerDataReplicator:TryIndex({ "Companions", "Skins", part2 })
			local v10 = typeof(v9) ~= "table" and 0 or v9.stack or 0
			local stack = v6:FindFirstChild("Stack")

			if stack then
				if v10 <= v8 then
					v6:SetAttribute("stackedVisible", false)
				else
					v6:SetAttribute("stackedVisible", true)
					stack.Text = `x{v10 - v8}`
				end
			end

			updateVisiblity(v6) -- equivalent call inferred; original call site unknown
		end
	end

	for k, v6 in p.offer do
		local v7

		if k == localPlayer.Name then
			v7 = playerOffer
		else
			v7 = otherOffer
		end

		for k2, v8 in v6 do
			local v9 = itemHelper.create(v8)
			v9.Visible = true
			v9.Parent = v7.List.ScrollingFrame

			if k == localPlayer.Name then
				local v10 = k2
				v9.Activated:Connect(function()
					remoteEvent3:FireServer(v10)
				end)
			end

			if type(v8.data) == "table" and v8.data.sub and v8.data.sub.Weight then
				v9.LayoutOrder = v8.data.sub.Weight * 100
			else
				v9.LayoutOrder = 0
			end

			table.insert(v5, v9)
		end
	end
end

function Trade.tradeEnded(_, _)
	trade.Visible = false
	Trade.clearPlayerOfferableItems()

	for _, v6 in v5 do
		v6:Destroy()
	end

	table.clear(v5)
end

function Trade.setViewingOfferables(flag: boolean)
	if flag then
		playerOffer.List.ScrollingFrame.Visible = false
		playerOffer.List.Offerables.Visible = true
		trade.Tabs.Visible = true
	else
		playerOffer.List.ScrollingFrame.Visible = true
		playerOffer.List.Offerables.Visible = false
		trade.Tabs.Visible = false
	end
end

local function searchCompare(p, value: string, callback)
	local v6, v7 = value:byte(1, 2)
	local v8

	if v6 == 60 or v6 == 62 then
		v8 = callback(value:sub(v7 == 61 and 3 or 2))
	else
		v8 = callback(value)
	end

	if not v8 then
		return false
	end

	local v9 = callback(p)

	if not v9 then
		return false
	end

	if v6 == 60 then
		if v7 == 61 then
			return v9 <= v8
		end

		return v9 < v8
	else
		if v6 ~= 62 then
			return v9 == v8
		end

		if v7 == 61 then
			return v8 <= v9
		end

		return v8 < v9
	end
end

local names = {}

for _, orderedRarity in library.rarities.OrderedRarities do
	table.insert(names, orderedRarity.Name:lower())
end

local function getRarityIndex(value)
	return value and table.find(names, value:lower())
end

local name = "Fish"

function Trade.updateSearch()
	local text = trade.Search.TextBox.Text:lower()
	DataController.InventoryReplicator:WaitForLoaded()
	local v6 = name ~= "Fish" and {} or DataController.InventoryReplicator:Index({ "Inventory" }) or {}
	local v7 = {}

	if text:find(":") then
		local parts = text:split(" ")
		local parts2 = {}

		for _, part in parts do
			if part:find(":.") then
				local match, v8 = part:match("(.-):(.+)")
				v7[match] = v8
			elseif part ~= "" then
				table.insert(parts2, part)
			end
		end

		text = table.concat(parts2, " ")
	end

	for _, v8 in v4 do
		local itemId = v8:GetAttribute("itemId")
		local v9

		if itemId and v6[itemId] then
			v9 = text == "" or objectHelper.getItemFullName(itemId):lower():gsub("<.->", ""):find(text, 1, true)
			local v10 = itemDisplayInfo[v6[itemId].name]

			if v9 and v7.rarity then
				local rarity = v10.rarity and v10.rarity:lower()
				v9 = searchCompare(rarity, v7.rarity, getRarityIndex) or rarity and rarity:find(v7.rarity, 1, true)
			end

			if v9 and v7.from then
				local v11 = library.fish[v6[itemId].name]
				v9 = v11 and (v11.From or "regionless"):lower():gsub("%s", ""):find(v7.from, 1, true)
			end

			if v9 and v7.appraised then
				local v11 = v7.appraised == "true" or v7.appraised == "yes" or v7.appraised == "1" or v7.appraised == "y"
				v9 = v6[itemId].sub and (v6[itemId].sub.Appraised or false) == v11
			end

			if v9 and v7.treasureappraised then
				local v11 = v7.treasureappraised == "true" or v7.treasureappraised == "yes" or v7.treasureappraised == "1" or v7.treasureappraised == "y"
				v9 = v6[itemId].sub and v6[itemId].sub.DefaultWeight ~= nil == v11
			end

			if v9 and v7.favorited then
				local v11 = v7.favorited == "true" or v7.favorited == "yes" or v7.favorited == "1" or v7.favorited == "y"
				v9 = v6[itemId].sub and (v6[itemId].sub.Favourited or false) == v11
			end

			if v9 and v7.weight then
				v9 = searchCompare(v6[itemId].sub and v6[itemId].sub.Weight, v7.weight, tonumber)
			end

			if v9 and v7.mutation then
				if v7.mutation == "any" or v7.mutation == "yes" then
					v9 = v6[itemId].sub.Mutation ~= nil
				elseif v7.mutation == "none" or v7.mutation == "no" then
					v9 = v6[itemId].sub.Mutation == nil
				else
					local mutation = library.mutations[v6[itemId].sub.Mutation]
					v9 = mutation and mutation.Display:lower():gsub("%s", ""):find(v7.mutation, 1, true) ~= nil and true or false
				end
			end

			if v9 and v7.stack then
				v9 = searchCompare(not v6[itemId].sub and 1 or v6[itemId].sub.Stack or 1, v7.stack, tonumber)
			end

			if v9 and v7.price then
				v9 = library.fish[v6[itemId].name] and searchCompare(
					fishing:SellFish(localPlayer, v6[itemId], true),
					v7.price,
					tonumber
				)
			end
		else
			v9 = text == "" or v8.Name:lower():find(text, 1, true)
		end

		if v9 and (v8:GetAttribute("tab") == name or not name) then
			v8:SetAttribute("searched", true)
		else
			v8:SetAttribute("searched", false)
		end

		updateVisiblity(v8) -- equivalent call inferred; original call site unknown
	end
end

function Trade.init()
	local tradeRequests = require(script.tradeRequests)
	tradeRequests.init()
	remoteEvent4.OnClientEvent:Connect(Trade.tradeStarted)
	remoteEvent.OnClientEvent:Connect(function(p, p2)
		v3 = p

		if p2 then
			v = workspace:GetServerTimeNow() + 3
		end

		Trade.updateOfferedItems(p)
		Trade.updateConfirmationState(p)
	end)
	remoteEvent5.OnClientEvent:Connect(Trade.tradeEnded)
	local _ = {
		Name = "1x1x1x1",
		UserId = 8166491
	}
	DataController.InventoryReplicator:Observe({ "Inventory" }, function()
		v2 = true
	end)
	Trade.updateSearch()
	trade.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(Trade.updateSearch)

	for _, button in trade.Tabs:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v6 = button
		button.Activated:Connect(function()
			name = v6.Name
			Trade.updateSearch()
		end)
	end

	if environment.target ~= "prod" then
		task.spawn(function()
			trade.debug.Visible = true
			trade.debug.debug.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

			while true do
				trade.debug.debug.Text = repr(v3, {
					pretty = true,
					richText = true,
					sortKeys = true
				})
				task.wait()
			end
		end)
	end

	trade.Options.Ready.Activated:Connect(function()
		local v6 = v3.player1 == localPlayer and "player1" or "player2"
		remoteEvent7:FireServer(not v3[`{v6}Confirmed`])
		Trade.setViewingOfferables(false)
	end)
	trade.Options.Cancel.Activated:Connect(function()
		remoteEvent6:FireServer()
	end)
	RunService.Heartbeat:Connect(function()
		for k, v6 in v4 do
			local parts = k:split("\254\254")
			local part = parts[1]
			local part2 = parts[2]

			if part == "Item" then
				Backpack.updateGradient(v6, DataController.getItemFromLink(part2))
			end
		end
	end)
	playerOffer.List.ScrollingFrame._add.Activated:Connect(function()
		Trade.setViewingOfferables(true)
	end)
	playerOffer.List.Offerables._rem.Activated:Connect(function()
		Trade.setViewingOfferables(false)
	end)
end

return Trade