local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ContextActionService = game:GetService("ContextActionService")
local DatabaseCompatability = require(script:WaitForChild("DatabaseCompatability"))
local _ = DatabaseCompatability.Item
local _ = DatabaseCompatability.Pets
local rarity = DatabaseCompatability.Rarity
local lastOffer = nil
local names = {}

local function SetSelectionGroup(p)
	for _, v in pairs(names) do
		local GuiService = game:GetService("GuiService")
		GuiService:RemoveSelectionGroup(v)
	end

	if p then
		local GuiService = game:GetService("GuiService")
		GuiService:AddSelectionParent(p.Name, p)
		table.insert(names, p.Name)
	end
end

local PrintTable

PrintTable = function(item, p)
	local v = ""

	for _ = 1, p do
		v ..= "--"
	end

	for k, item2 in pairs(item) do
		if type(item2) == "table" then
			print(v .. k .. "{")
			PrintTable(item2, p + 1)
		else
			print(v .. k .. ": " .. tostring(item2))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetImage(image)
	if _G.Cache[image] ~= nil then
		return _G.Cache[image]
	end

	local v

	if tonumber(image) then
		v = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
	else
		v = image
	end

	local v2 = v .. "&bust=" .. math.random(1, 10000)
	_G.Cache[image] = v2
	return v2
end

local parent = script.Parent.Parent
local trade = game.ReplicatedStorage.Trade
local request = parent.Leaderboard.Trade.Request
local trade2 = parent.Trade

local function GetTradePlayers(p)
	if p.Player1.Player == game.Players.LocalPlayer then
		return "Player1", "Player2"
	end

	if p.Player2.Player == game.Players.LocalPlayer then
		return "Player2", "Player1"
	end
end

local v = false

local function ShowRequest(p, p2)
	if p2 then
		v = false
		request.Title.Text = p .. " wants to trade."
	else
		v = true
		request.Title.Text = "Waiting for " .. p .. " to respond."
	end

	parent.Leaderboard.Trade.Request.Visible = true

	for _, child in pairs(parent.Leaderboard.List:GetChildren()) do
		if child.Container.Response.Visible then
			child.Container.Response.Visible = false
		end
	end
end

_G.ShowRequest = ShowRequest
local connections = {}
local flag = false
local v2 = 5

function ResetCooldown()
	parent.Trade.Offers.Accept.TradeAccepted.Visible = false
	v2 = 5
	parent.Trade.Offers.Accept.Cooldown.Text = "(" .. v2 .. ")"

	if flag then
		v2 = 5
		return
	end

	parent.Trade.Offers.Accept.Cooldown.Visible = true
	flag = true

	repeat
		wait(1)
		v2 -= 1
		parent.Trade.Offers.Accept.Cooldown.Text = "(" .. v2 .. ")"
	until v2 <= 0

	flag = false
	parent.Trade.Offers.Accept.Cooldown.Visible = false
end

local visible = false

local function UpdateTrade(data)
	request.Visible = false
	trade2.Offers.Accept.TradeAccepted.Visible = false
	trade2.Offers.Accept.Waiting.Visible = false

	for _, child in pairs(trade2.Offers.OfferContainer.Offer1:GetChildren()) do
		if child.Name == "OfferLabel" then
			continue
		end

		child.Container.Icon.Image = ""
		child.Container.ItemName.Text = ""
		child.Container.Amount.Text = ""
	end

	for _, child in pairs(trade2.Offers.OfferContainer.Offer2:GetChildren()) do
		if child.Name == "OfferLabel" then
			continue
		end

		child.Container.Icon.Image = ""
		child.Container.ItemName.Text = ""
		child.Container.Amount.Text = ""
	end

	for _, connection in pairs(connections) do
		connection:disconnect()
	end

	if data then
		trade2.Visible = true
		local v4, v5

		if data.Player1.Player == game.Players.LocalPlayer then
			v4 = "Player1"
			v5 = "Player2"
		elseif data.Player2.Player == game.Players.LocalPlayer then
			v4 = "Player2"
			v5 = "Player1"
		end

		local offer = data[v4].Offer
		local offer2 = data[v5].Offer

		for k, v6 in pairs(offer) do
			local v7 = DatabaseCompatability[v6[3]]
			local icon = trade2.Offers.OfferContainer.Offer1["Slot" .. k].Container.Icon
			local image = GetImage(v7[v6[1]].Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
			trade2.Offers.OfferContainer.Offer1["Slot" .. k].Container.ItemName.Text = v7[v6[1]].ItemName or v7[v6[1]].Name
			trade2.Offers.OfferContainer.Offer1["Slot" .. k].Container.ItemName.TextColor3 = rarity[v7[v6[1]].Rarity]
			trade2.Offers.OfferContainer.Offer1["Slot" .. k].Container.Amount.Text = "x" .. v6[2]
			local v9 = v6
			table.insert(
				connections,
				trade2.Offers.OfferContainer.Offer1["Slot" .. k].Container.Button.MouseButton1Click:connect(function()
					trade.RemoveOffer:FireServer(v9[1], v9[3])
				end)
			)
		end

		for k, v6 in pairs(offer2) do
			local v7 = DatabaseCompatability[v6[3]]
			local icon = trade2.Offers.OfferContainer.Offer2["Slot" .. k].Container.Icon
			local image = GetImage(v7[v6[1]].Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
			trade2.Offers.OfferContainer.Offer2["Slot" .. k].Container.ItemName.Text = v7[v6[1]].ItemName or v7[v6[1]].Name
			trade2.Offers.OfferContainer.Offer2["Slot" .. k].Container.ItemName.TextColor3 = rarity[v7[v6[1]].Rarity]
			trade2.Offers.OfferContainer.Offer2["Slot" .. k].Container.Amount.Text = "x" .. v6[2]
		end

		lastOffer = data.LastOffer
		spawn(ResetCooldown)
	else
		parent.Leaderboard.Visible = false
		local buttonY = Enum.KeyCode.ButtonY

		local function fn()
			visible = not visible
			trade2.YourItems.Pets.Style = visible and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
			trade2.TheirItems.Pets.Style = visible and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
			trade2.YourItems.Weapons.Style = visible and Enum.ButtonStyle.RobloxRoundButton or Enum.ButtonStyle.RobloxRoundDefaultButton
			trade2.TheirItems.Weapons.Style = visible and Enum.ButtonStyle.RobloxRoundButton or Enum.ButtonStyle.RobloxRoundDefaultButton
			trade2.YourItems.PetsFrame.Visible = visible
			trade2.YourItems.Items.Visible = not visible
			trade2.TheirItems.PetsFrame.Visible = visible
			trade2.TheirItems.Items.Visible = not visible
			SetSelectionGroup(trade2)
			local GuiService = game:GetService("GuiService")
			GuiService.SelectedObject = trade2.YourItems[visible and "PetsFrame" or "Items"].Container.Slot1.Container.Button
		end

		ContextActionService:BindAction("ToggleItemType", function(_, p)
			if p == Enum.UserInputState.Begin and not _G.PauseBinds then
				fn()
			end
		end, false, buttonY)

		local function fn2() end

		ContextActionService:BindAction("TradeNoB", function(_, p)
			if p == Enum.UserInputState.Begin and not _G.PauseBinds then
				fn2()
			end
		end, false, Enum.KeyCode.ButtonB)

		local function fn3()
			parent.Chat.ChatBox:CaptureFocus()
		end

		ContextActionService:BindAction("TradeChat", function(_, p)
			if p == Enum.UserInputState.Begin and not _G.PauseBinds then
				fn3()
			end
		end, false, Enum.KeyCode.ButtonL3)
		trade2.Visible = true
		UpdateInventory("YourItems", ProfileData.Weapons.Owned, ProfileData.Pets.Owned)
		SetSelectionGroup(trade2)
		local GuiService = game:GetService("GuiService")
		GuiService.SelectedObject = trade2.YourItems.Items.Container.Slot1.Container.Button
		local _, v4 = game.ReplicatedStorage.Trade.GetTradeStatus:InvokeServer()
		local player = v4[v4.Player1.Player == game.Players.LocalPlayer and "Player2" or v4.Player2.Player == game.Players.LocalPlayer and "Player1" or nil].Player
		local v5 = game.ReplicatedStorage.Remotes.Extras.GetFullInventory:InvokeServer(player)
		UpdateInventory("TheirItems", v5.Weapons.Owned, v5.Pets.Owned)
	end
end

trade.DeclineTrade.OnClientEvent:connect(function()
	trade2.Visible = false
	parent.Leaderboard.Visible = true
	ContextActionService:UnbindAction("TradeNoB")
	ContextActionService:UnbindAction("TradeChat")
	SetSelectionGroup(parent.Leaderboard)
	local GuiService = game:GetService("GuiService")
	GuiService.SelectedObject = parent.Leaderboard.List.Player1.Container.Button
end)
trade.DeclineRequest.OnClientEvent:connect(function()
	parent.Leaderboard.Trade.Request.Visible = false
	parent.Leaderboard.Trade.Request.Response.Visible = false
	_G.Chatted("Server", "Your trade request was declined.")
end)
trade.CancelRequest.OnClientEvent:connect(function()
	parent.Leaderboard.Trade.Request.Visible = false
	parent.Leaderboard.Trade.Request.Response.Visible = false
end)

trade.SendRequest.OnClientInvoke = function(p)
	if _G.RequestsEnabled then
		_G.Chatted("Server", p.Name .. " has sent you a trade request.")
		ShowRequest(p.Name, true)
	end

	return _G.RequestsEnabled
end

trade.RequestSent.OnClientEvent:Connect(function(p)
	if _G.RequestsEnabled then
		_G.Chatted("Server", p.Name .. " has sent you a trade request.")
		ShowRequest(p.Name, true)
	end
end)
trade.UpdateTrade.OnClientEvent:connect(UpdateTrade)
trade.StartTrade.OnClientEvent:connect(function()
	UpdateTrade()
	parent.Leaderboard.Trade.Request.Visible = false
	parent.Leaderboard.Trade.Request.Response.Visible = false
end)
trade.AcceptTrade.OnClientEvent:connect(function(p)
	if not p then
		trade2.Offers.Accept.TradeAccepted.Visible = true
		return
	end

	trade2.Visible = false
	parent.Leaderboard.Visible = true
	ContextActionService:UnbindAction("TradeNoB")
	ContextActionService:UnbindAction("TradeChat")
end)
trade2.Offers.Decline.MouseButton1Click:connect(function()
	trade.DeclineTrade:FireServer()
end)
local inputBeganConnection = nil
parent.Leaderboard.Trade.Toggle.SelectionGained:connect(function()
	if parent.Leaderboard.Trade.Request.Visible and not v then
		parent.Leaderboard.Trade.Request.Response.Visible = true
		local UserInputService = game:GetService("UserInputService")
		inputBeganConnection = UserInputService.InputBegan:connect(function(p)
			if p.KeyCode == Enum.KeyCode.DPadLeft and parent.Leaderboard.Trade.Request.Visible and not parent.Chat.Control.Visible then
				if inputBeganConnection then
					inputBeganConnection:disconnect()
				end

				parent.Leaderboard.Trade.Request.Visible = false
				parent.Leaderboard.Trade.Request.Response.Visible = false
				trade.AcceptRequest:FireServer()
				SetSelectionGroup(nil)
				local GuiService = game:GetService("GuiService")
				GuiService.SelectedObject = nil
			elseif p.KeyCode == Enum.KeyCode.DPadRight and parent.Leaderboard.Trade.Request.Visible and not parent.Chat.Control.Visible then
				if inputBeganConnection then
					inputBeganConnection:disconnect()
				end

				SetSelectionGroup(parent.Leaderboard)
				local GuiService = game:GetService("GuiService")
				GuiService.SelectedObject = parent.Leaderboard.List.Player1.Container.Button
				parent.Leaderboard.Trade.Request.Visible = false
				parent.Leaderboard.Trade.Request.Response.Visible = false
				trade.DeclineRequest:FireServer()
			end
		end)
	elseif parent.Leaderboard.Trade.Request.Visible and v then
		parent.Leaderboard.Trade.Request.Cancel.Visible = true
		local UserInputService = game:GetService("UserInputService")
		inputBeganConnection = UserInputService.InputBegan:connect(function(p)
			if p.KeyCode == Enum.KeyCode.DPadRight and parent.Leaderboard.Trade.Request.Visible then
				if inputBeganConnection then
					inputBeganConnection:disconnect()
				end

				SetSelectionGroup(parent.Leaderboard)
				local GuiService = game:GetService("GuiService")
				GuiService.SelectedObject = parent.Leaderboard.List.Player1.Container.Button
				parent.Leaderboard.Trade.Request.Visible = false
				parent.Leaderboard.Trade.Request.Cancel.Visible = false
				trade.CancelRequest:FireServer()
			end
		end)
	end
end)
parent.Leaderboard.Trade.Toggle.SelectionLost:connect(function()
	parent.Leaderboard.Trade.Request.Response.Visible = false
	parent.Leaderboard.Trade.Request.Cancel.Visible = false

	if inputBeganConnection then
		inputBeganConnection:disconnect()
	end
end)
local v4 = time()
trade2.Offers.Accept.MouseButton1Click:connect(function()
	if flag == false and time() - v4 >= 1 then
		v4 = time()
		trade2.Offers.Accept.Waiting.Visible = true
		trade.AcceptTrade:FireServer(game.PlaceId * 3, lastOffer)
	end
end)
local v5, v6 = game.ReplicatedStorage.Trade.GetTradeStatus:InvokeServer()

if v5 == "StartTrade" then
	UpdateTrade(v6)
	local GuiService = game:GetService("GuiService")
	GuiService.SelectedObject = trade2.YourItems.Items.Container.Slot1.Container.Button
elseif v5 == "ShowRequest" then
	ShowRequest(v6, false)
elseif v5 == "SendRequest" then
	ShowRequest(v6, true)
end

local v7 = {
	Classic = 1,
	Common = 2,
	Uncommon = 3,
	Rare = 4,
	Legendary = 5,
	Godly = 6,
	Victim = 7,
	Unique = 7,
	Ancient = 6.5,
	Christmas = 1.6,
	Halloween = 1.5
}

function UpdateInventory(p, items, items2)
	local item = DatabaseCompatability.Item
	local pets = DatabaseCompatability.Pets
	local container = trade2[p].Items.Container
	local container2 = trade2[p].PetsFrame.Container
	container:ClearAllChildren()
	container2:ClearAllChildren()
	local v8 = {}
	local v9 = {}

	for k, item2 in pairs(items) do
		table.insert(v8, {
			ItemName = k,
			Amount = item2
		})
	end

	for k, item2 in pairs(items2) do
		table.insert(v9, {
			ItemName = k,
			Amount = item2
		})
	end

	table.sort(v9, function(a, b)
		if v7[pets[a.ItemName].Rarity] == v7[pets[b.ItemName].Rarity] then
			return a.Amount > b.Amount
		end

		return v7[pets[a.ItemName].Rarity] > v7[pets[b.ItemName].Rarity]
	end)
	table.sort(v8, function(a, b)
		if a.ItemName == "DefaultKnife" then
			return true
		end

		if b.ItemName == "DefaultKnife" then
			return false
		end

		if a.ItemName == "DefaultGun" then
			return true
		end

		if b.ItemName == "DefaultGun" then
			return false
		end

		if v7[item[a.ItemName].Rarity] == v7[item[b.ItemName].Rarity] then
			return a.Amount > b.Amount
		end

		return v7[item[a.ItemName].Rarity] > v7[item[b.ItemName].Rarity]
	end)
	local count = 0

	for _, v10 in pairs(v8) do
		local itemName = v10.ItemName
		local amount = v10.Amount
		count += 1
		local v11 = DatabaseCompatability.Item[itemName]
		local clone = script.Slot:Clone()
		clone.Parent = trade2[p].Items.Container
		local v12 = math.floor((count - 1) / 4)
		local v13 = (count - 1) % 4
		clone.Position = UDim2.new(clone.Size.X.Scale * v13, 0, 0, clone.AbsoluteSize.Y * v12)
		clone.Container.Icon.Image = v11.Image
		clone.Container.ItemName.Text = DatabaseCompatability.Item[itemName].ItemName
		clone.Container.ItemName.TextColor3 = DatabaseCompatability.Rarity[v11.Rarity]
		clone.Name = "Slot" .. count

		if amount > 1 then
			clone.Container.Amount.Text = "x" .. amount
		end

		if p == "YourItems" then
			local itemName2 = itemName
			clone.Container.Button.MouseButton1Click:connect(function()
				trade.OfferItem:FireServer(itemName2, "Weapons")
			end)
		else
			clone.Container.Button.Selectable = false
		end
	end

	local count2 = 0

	for _, v10 in pairs(v9) do
		local itemName = v10.ItemName
		local amount = v10.Amount
		count2 += 1
		local pet = pets[itemName]
		local clone = script.Slot:Clone()
		clone.Parent = container2
		local v11 = math.floor((count2 - 1) / 4)
		local v12 = (count2 - 1) % 4
		clone.Position = UDim2.new(clone.Size.X.Scale * v12, 0, 0, clone.AbsoluteSize.Y * v11)
		local icon = clone.Container.Icon
		local image = GetImage(pet.Image) -- equivalent call inferred; original call site unknown
		icon.Image = image
		clone.Container.ItemName.Text = pets[itemName].Name
		clone.Container.ItemName.TextColor3 = DatabaseCompatability.Rarity[pet.Rarity]
		clone.Name = "Slot" .. count2

		if amount > 1 then
			clone.Container.Amount.Text = "x" .. amount
		end

		if p == "YourItems" then
			local itemName2 = itemName
			clone.Container.Button.MouseButton1Click:connect(function()
				trade.OfferItem:FireServer(itemName2, "Pets")
			end)
		else
			clone.Container.Button.Selectable = false
		end
	end
end

if _G.RequestsEnabled == nil then
	_G.RequestsEnabled = true
end

parent.Leaderboard.Trade.Status.BackgroundColor3 = _G.RequestsEnabled and Color3.new(0, 0.7019607843137254, 0) or Color3.new(
	0.6666666666666666,
	0,
	0
)
parent.Leaderboard.Trade.Title.Text = "Trade Requests: " .. (_G.RequestsEnabled and "On" or "Off")
parent.Leaderboard.Trade.Toggle.MouseButton1Click:Connect(function()
	if not parent.Leaderboard.Trade.Request.Visible then
		_G.RequestsEnabled = not _G.RequestsEnabled
		trade.SetRequestsEnabled:FireServer(_G.RequestsEnabled)
		parent.Leaderboard.Trade.Status.BackgroundColor3 = _G.RequestsEnabled and Color3.new(0, 0.7019607843137254, 0) or Color3.new(
			0.6666666666666666,
			0,
			0
		)
		parent.Leaderboard.Trade.Title.Text = "Trade Requests: " .. (_G.RequestsEnabled and "On" or "Off")
		trade.DeclineRequest:FireServer()
	end
end)
UpdateInventory("YourItems", ProfileData.Weapons.Owned, ProfileData.Pets.Owned)