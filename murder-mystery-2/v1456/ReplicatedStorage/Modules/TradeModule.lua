local TradeModule = {}
local trade = game.ReplicatedStorage.Trade
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local InventoryModule = require(script.Parent.InventoryModule)
local ItemModule = require(game.ReplicatedStorage.Modules.ItemModule)
TradeModule.GUI = {}
TradeModule.RequestsEnabled = true
TradeModule.TradeInventory = nil

function _G.NewTradeRequest() end

local v = nil
local lastOffer = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function exitTrade()
	warn("Trade failed - " .. tostring(v))
	v = nil
	trade.DeclineTrade:FireServer()
	TradeModule.GUI.TradeGUI.Enabled = false
	TradeModule.TradeInventory = nil
end

function TradeModule.SendTradeRequest(name)
	if not trade.SendRequest:InvokeServer(game.Players[name]) then
		TradeModule.UpdateTradeRequestWindow("SendingRequest", {
			Receiver = {
				Name = name
			}
		})
	end
end

function TradeModule.UpdateTradeRequestWindow(p, p2)
	local requestFrame = TradeModule.GUI.RequestFrame

	for _, child in pairs(requestFrame:GetChildren()) do
		child.Visible = child.Name == p
	end

	requestFrame.Visible = true
	_G.NewTradeRequest(false)

	if p == "SendingRequest" then
		requestFrame.SendingRequest.Username.Text = p2.Receiver.Name
		return
	end

	if p ~= "ReceivingRequest" then
		requestFrame.Visible = false
		return
	end

	requestFrame.ReceivingRequest.Username.Text = p2.Sender.Name
	_G.NewTradeRequest(true)
end

function TradeModule.ConnectRequestWindow()
	TradeModule.GUI.RequestFrame.SendingRequest.Cancel.MouseButton1Click:connect(function()
		TradeModule.GUI.RequestFrame.Visible = false
		trade.CancelRequest:FireServer()
	end)
	TradeModule.GUI.RequestFrame.ReceivingRequest.Accept.MouseButton1Click:connect(function()
		TradeModule.GUI.RequestFrame.Visible = false
		trade.AcceptRequest:FireServer()
		_G.NewTradeRequest(false)
	end)
	TradeModule.GUI.RequestFrame.ReceivingRequest.Decline.MouseButton1Click:connect(function()
		TradeModule.GUI.RequestFrame.Visible = false
		trade.DeclineRequest:FireServer()
		_G.NewTradeRequest(false)
	end)
end

trade.DeclineRequest.OnClientEvent:connect(function()
	TradeModule.UpdateTradeRequestWindow()
	_G.NewTradeRequest(false)
end)
trade.CancelRequest.OnClientEvent:Connect(function()
	TradeModule.UpdateTradeRequestWindow()
end)
trade.RequestSent.OnClientEvent:Connect(function(p)
	if TradeModule.RequestsEnabled then
		TradeModule.UpdateTradeRequestWindow("ReceivingRequest", {
			Sender = {
				Name = p.Name
			}
		})
	end
end)

trade.SendRequest.OnClientInvoke = function(p)
	if TradeModule.RequestsEnabled then
		TradeModule.UpdateTradeRequestWindow("ReceivingRequest", {
			Sender = {
				Name = p.Name
			}
		})
	end

	return TradeModule.RequestsEnabled
end

local function GetTradePlayers(p)
	if p.Player1.Player == game.Players.LocalPlayer then
		return "Player1", "Player2"
	end

	if p.Player2.Player == game.Players.LocalPlayer then
		return "Player2", "Player1"
	end
end

local connections = {}

local function ClearOfferFrame(container)
	for _, frame in pairs(container:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Visible = false

		if connections[frame] then
			connections[frame]:disconnect()
		end
	end
end

local function DisplayOffer(p, offer)
	for k, item in offer do
		local v2 = item[1] or item.ItemID
		local amount = item[2] or item.Amount
		local dataType = item[3] or item.ItemType
		local v5 = {}

		for k2, v6 in Sync[dataType][v2] do
			v5[k2] = v6
		end

		v5.DataType = dataType
		v5.Amount = amount
		local v6 = p.Container["NewItem" .. k]
		ItemModule.DisplayItem(v6, v5)

		if connections[v6] then
			connections[v6]:Disconnect()
		end

		connections[v6] = v6.Container.ActionButton.MouseButton1Click:Connect(function()
			trade.RemoveOffer:FireServer(v2, dataType)
		end)
		v6.Visible = true
	end
end

local v2 = "Accept"

function TradeModule.UpdateTrade(data)
	local v3, v4

	if data.Player1.Player == game.Players.LocalPlayer then
		v3 = "Player1"
		v4 = "Player2"
	elseif data.Player2.Player == game.Players.LocalPlayer then
		v3 = "Player2"
		v4 = "Player1"
	end

	local offer = data[v3].Offer
	local offer2 = data[v4].Offer
	local player = data[v4].Player

	if player then
		local child = game.Players:FindFirstChild(player.Name)

		if child and v == child.Name then
			ClearOfferFrame(TradeModule.GUI.YourOffer.Container)
			ClearOfferFrame(TradeModule.GUI.TheirOffer.Container)
			DisplayOffer(TradeModule.GUI.YourOffer, offer)
			DisplayOffer(TradeModule.GUI.TheirOffer, offer2)
			lastOffer = data.LastOffer
			v2 = "Accept"
			TradeModule.GUI.YourOffer.Accepted.Visible = false
			TradeModule.GUI.TheirOffer.Accepted.Visible = false
			TradeModule.GUI.TheirOffer.Username.Text = "(" .. child.Name .. ")"
			TradeModule.GUI.Actions.Accept.Confirm.Visible = false
			TradeModule.GUI.Actions.Accept.Cancel.Visible = false
			local addItem = TradeModule.GUI.Actions.Accept.AddItem
			addItem.Visible = #offer < 1 and #offer2 < 1
			TradeModule.UpdateTradeInventory(data)
			TradeModule.ResetCooldown(#offer < 1 and #offer2 < 1)
			return
		end

		exitTrade() -- equivalent call inferred; original call site unknown
	else
		exitTrade() -- equivalent call inferred; original call site unknown
	end
end

trade.UpdateTrade.OnClientEvent:connect(TradeModule.UpdateTrade)
local textChangedConnection = nil
trade.StartTrade.OnClientEvent:Connect(function(p, p2)
	if v == nil then
		v = p2

		for _, childName in pairs({ "Weapons", "Pets" }) do
			for childName2, _ in pairs(InventoryModule.CreateBlankTradeInventoryTable()[childName]) do
				TradeModule.GUI.TradeGUI.Container.Items.Main:FindFirstChild(childName).Items.Container:FindFirstChild(childName2).Container:ClearAllChildren()
			end
		end

		TradeModule.TradeInventory = InventoryModule.GenerateInventory(
			TradeModule.GUI.TradeGUI.Container.Items,
			ProfileData,
			"Trading",
			TradeModule.GUI.ItemsLayout
		)
		TradeModule.ConnectOfferButtons(TradeModule.TradeInventory)
		TradeModule.UpdateTrade(p)
		TradeModule.GUI.TheirOffer.Username.Text = "(" .. p2 .. ")"
		TradeModule.GUI.TradeGUI.Enabled = true
		TradeModule.GUI.RequestFrame.Visible = false

		if textChangedConnection then
			textChangedConnection:disconnect()
		end

		local searchText = TradeModule.GUI.TradeGUI.Container.Items.Tabs.Search.Container.SearchText
		textChangedConnection = searchText:GetPropertyChangedSignal("Text"):connect(function()
			local text = searchText.Text
			local v3 = string.gsub(text, "S", "")

			for _, v4 in pairs(TradeModule.TradeInventory.Data) do
				for _, v5 in pairs(v4.Current) do
					v5.Frame.Visible = string.find(string.lower(v5.Name), string.lower(v3))

					if v5.Frame.Parent.Parent:IsA("ScrollingFrame") then
						v5.Frame.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
					else
						v5.Frame.Parent.Parent.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
					end
				end
			end
		end)
	else
		exitTrade() -- equivalent call inferred; original call site unknown
	end
end)

function TradeModule.UpdateTradeInventory(p)
	local v3, v4

	if p.Player1.Player == game.Players.LocalPlayer then
		v3 = "Player1"
		v4 = "Player2"
	elseif p.Player2.Player == game.Players.LocalPlayer then
		v3 = "Player2"
		v4 = "Player1"
	end

	local offer = p[v3].Offer
	local _ = p[v4].Offer

	for k, v5 in pairs(TradeModule.TradeInventory.Data) do
		for _, v6 in pairs(v5) do
			for k2, v7 in pairs(v6) do
				local frame = v7.Frame
				local amount = v7.Amount

				for _, v8 in pairs(offer) do
					local v9 = v8[1] or v8.ItemID
					local v10 = v8[2] or v8.Amount
					local v11 = v8[3] or v8.ItemType

					if v9 == k2 and v11 == k then
						amount -= v10
					end
				end

				if amount == 1 then
					frame.Container.Amount.Text = ""
					frame.Visible = true
				elseif amount > 1 then
					frame.Container.Amount.Text = "x" .. amount
					frame.Visible = true
				elseif amount < 1 then
					frame.Visible = false
				end
			end
		end
	end
end

function TradeModule.ConnectOfferButtons(p)
	for k, v3 in pairs(p.Data) do
		for _, v4 in pairs(v3) do
			for k2, v5 in pairs(v4) do
				local frame = v5.Frame

				if not frame then
					continue
				end

				local v6 = k2
				local v7 = k
				frame.Container.ActionButton.MouseButton1Click:Connect(function()
					trade.OfferItem:FireServer(v6, v7)
				end)
			end
		end
	end
end

local flag = false
local v3 = 6

function TradeModule.ResetCooldown(p)
	if p then
		TradeModule.GUI.Actions.Accept.Cooldown.Visible = false
		v3 = 0
		flag = false
	else
		TradeModule.GUI.Actions.Accept.Cooldown.Visible = true
		v3 = 6
		TradeModule.GUI.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v3 .. ") before accepting."

		if flag then
			v3 = 6
			return
		end

		TradeModule.GUI.Actions.Accept.Cooldown.Visible = true
		flag = true

		repeat
			wait(1)
			v3 -= 1
			TradeModule.GUI.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v3 .. ") before accepting."
		until v3 <= 0

		flag = false
		TradeModule.GUI.Actions.Accept.Cooldown.Visible = false
	end
end

local v4 = time()

function TradeModule.ConnectActions()
	TradeModule.GUI.Actions.Accept.ActionButton.MouseButton1Click:connect(function()
		if v3 <= 0 and v2 == "Accept" then
			v2 = "Confirm"
			v4 = time()
			TradeModule.GUI.Actions.Accept.Confirm.Visible = true
		end
	end)
	TradeModule.GUI.Actions.Accept.Confirm.ActionButton.MouseButton1Click:connect(function()
		if v3 <= 0 and time() - v4 >= 0.4 and v2 == "Confirm" then
			v2 = "Waiting"
			TradeModule.GUI.YourOffer.Accepted.Visible = true
			TradeModule.GUI.Actions.Accept.Cancel.Visible = true
			trade.AcceptTrade:FireServer(game.PlaceId * 3, lastOffer)
		end
	end)
	TradeModule.GUI.Actions.Accept.Cancel.ActionButton.MouseButton1Click:connect(function()
		trade.CancelAccept:FireServer()
	end)
	TradeModule.GUI.Actions.Decline.ActionButton.MouseButton1Click:connect(function()
		v = nil
		trade.DeclineTrade:FireServer()
		TradeModule.GUI.TradeGUI.Enabled = false
		TradeModule.TradeInventory = nil
	end)

	if TradeModule.GUI.Actions:FindFirstChild("AddItems") then
		TradeModule.GUI.Actions.AddItems.ActionButton.MouseButton1Click:connect(function()
			TradeModule.GUI.TradeGUI.Container.Items.Visible = true
		end)
		TradeModule.GUI.TradeGUI.Container.Items.Tabs.Close.ActionButton.MouseButton1Click:connect(function()
			TradeModule.GUI.TradeGUI.Container.Items.Visible = false
		end)
	end
end

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ItemPopupService = require(ReplicatedStorage3:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
trade.AcceptTrade.OnClientEvent:Connect(function(p, items)
	if p then
		v = nil
		TradeModule.GUI.TradeGUI.Enabled = false

		if items then
			for _, item in items do
				local v5 = item[1]
				local v6 = item[2]
				ItemPopupService:AddNewItem(v5, item[3], v6)
			end
		end
	else
		TradeModule.GUI.TheirOffer.Accepted.Visible = true
	end
end)
trade.DeclineTrade.OnClientEvent:connect(function()
	v = nil
	TradeModule.GUI.TradeGUI.Enabled = false
	TradeModule.TradeInventory = nil
end)

function TradeModule.ConnectTabButtons()
	InventoryModule.ConnectTabButtons(
		nil,
		nil,
		TradeModule.GUI.TradeGUI.Container.Items,
		TradeModule.GUI.TradeGUI.Container.Items.Main
	)
end

return TradeModule