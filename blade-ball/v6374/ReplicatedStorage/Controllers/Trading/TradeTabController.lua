local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Shared.Statable)
local v5 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v7 = require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
require3(ReplicatedStorage2.Shared.ItemInfo)
local v9 = require3(ReplicatedStorage2.Packages.Promise)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v10 = require3(ReplicatedStorage2.Shared.Inventory.Shared)
local v11 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v12 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
local v13 = require3(ReplicatedStorage2.Controllers.Trading.TradeRequestController)
local v14 = require3(ReplicatedStorage2.Controllers.ViewInventoryController)
local v15 = require3(ReplicatedStorage2.Controllers.NotificationController)
require3(ReplicatedStorage2.Shared.FrameCap)
local localPlayer = Players.LocalPlayer
local trade = localPlayer.PlayerGui:WaitForChild("Trade")
local main = trade.Main
local unfairTradeWarning = trade.UnfairTradeWarning
local bottom = main.Right.Bottom
local accept = bottom.Accept
local decline = bottom.Decline
local label = main.Right.Label
local searchBox = main.ItemSearch.SearchBox
local v16 = nil
local v17 = nil
local template = main.Left.Items.UIGridLayout.Template
local state = v4.State(nil)
local state2 = v4.State("Sword")
local state3 = v4.State(0)
local state4 = v4.State(false)
local state5 = v4.State(false)
local state6 = v4.State(false)
local state7 = v4.State(false)
local state8 = v4.State(false)
local state9 = v4.State(false)
local state10 = v4.State(false)
local state11 = v4.State(false)
local state12 = v4.State(nil)
local state13 = v4.State(0)
local state14 = v4.State("")
local state15 = v4.State("")
local state16 = v4.State(true)
local postSimulationConnection = nil
local TradeTabController = {
	TradeReplionState = state
}

local function invokeServer(instance, ...)
	local v18 = { instance:InvokeServer(...) }

	if v18[1] then
		return table.unpack(v18)
	end

	ReplicatedStorage2.Misc.error:Play()

	if type(v18[2]) == "string" then
		warn((`Request failed for {instance:GetFullName()}:\n{v18[2]}`))
	else
		warn((`Request failed for {instance:GetFullName()}:\nno output`))
	end

	return table.unpack(v18)
end

local function createInventory(p: string, inventoryType, container, caller)
	if not table.find(v5.TradableItemTypes, inventoryType) then
		return
	end

	local fn

	if p == "LOCAL" then
		fn = function(p3, p4: string)
			return v2.List.removeValue(
				v10:FindItemsWithKey(nil, p3, p4),
				table.unpack(v10:FindItemsWithKey(caller, p3, p4))
			)
		end
	else
		fn = function(p3, p4: string)
			local v19

			if p ~= "LOCAL" then
				v19 = caller
			end

			return v10:FindItemsWithKey(v19, p3, p4)
		end
	end

	local defaults = {
		ItemTemplate = template,
		Container = container,
		Caller = 0,
		SearchFilter = 0,
		FindItemsWithKey = 0,
		OnSlotCreated = 0,
		InventoryType = 0,
		PageVisible = 0
	}
	local caller2

	if p ~= "LOCAL" then
		caller2 = caller
	end

	defaults.Caller = caller2
	local searchFilter

	if p == "LOCAL" then
		searchFilter = state15
	end

	defaults.SearchFilter = searchFilter
	defaults.FindItemsWithKey = fn

	function defaults.OnSlotCreated(p3, p4, p5: string, p6, maid)
		if not p4.TradeLock then
			maid:Add(p6.ActivationButton.Activated:Connect(function()
				if state4:Get() then
					return
				end

				local v21 = fn(p3, p5)
				invokeServer(v5.Remotes.AddItemToTrade, p3, v21[1])
			end))
		end
	end

	defaults.InventoryType = inventoryType
	local pageVisible

	if p == "LOCAL" then
		pageVisible = v4.Computed(function(callback)
			return callback(state2) == inventoryType and not (callback(state4) or callback(state5))
		end)
	else
		pageVisible = state16
	end

	defaults.PageVisible = pageVisible
	local maid = v3.new()
	local v22 = maid:Add(v12:CreateInventory(defaults))

	if p ~= "LOCAL" then
		return maid
	end

	local function onChange(p3, p4, _)
		if p4 == "Insert" then
			v22.TriggerUpdate(p3, "Remove")
		elseif p4 == "Remove" then
			v22.TriggerUpdate(p3, "Insert")
		end
	end

	local v23 = v10:Get(caller, inventoryType)

	if v23 then
		for _, v24 in v23 do
			v22.TriggerUpdate(v24, "Remove")
		end
	end

	local v24 = v10:OnChange(caller, inventoryType, onChange)

	if v24 then
		maid:Add(v24)
	end

	maid:Add(v12:CreateInventory(v2.Dictionary.merge(defaults, {
		SearchFilter = v2.None,
		FindItemsWithKey = v2.None,
		SortMode = v4.State("Name"),
		SortOption = v4.State(function(p3: string, _, _)
			return (` {p3}`)
		end),
		Caller = caller,
		PageVisible = state16,
		OnSlotCreated = function(p3, _, p4: string, p5, maid2)
			maid2:Add(v4.setPropertyComputed(p5.Checkmark, "Visible", function(callback)
				return not callback(state4)
			end))
			maid2:Add(function()
				p5.Checkmark.Visible = false
			end)
			maid2:Add(p5.ActivationButton.Activated:Connect(function()
				if state4:Get() then
					return
				end

				local items2 = v10:FindItemsWithKey(caller, p3, p4)
				invokeServer(v5.Remotes.RemoveItemFromTrade, p3, items2[1])
			end))
		end
	})))
	return maid
end

function TradeTabController.CanTrade(_)
	if v7.FFlag.GetInstantFFlag("TradingEnabled") ~= true or v7.FFlag.GetInstantFFlag("TradingSystemEnabled") ~= true then
		return false, "Trading is currently disabled!"
	end

	local replion = v.Client:GetReplion("Data")

	if not replion then
		return false, "You are still loading!"
	end

	local tradeLockedUntil = replion:Get("TradeLockedUntil")
	local serverTimeNow = workspace:GetServerTimeNow()

	if replion:Get("TradeBanned") then
		return false, "You are unable to trade!"
	end

	if tradeLockedUntil and tradeLockedUntil > 0 and serverTimeNow < tradeLockedUntil then
		local v18 = tradeLockedUntil - serverTimeNow
		return false, (`You are unable to trade for {v7.ValueConvertor:FormatShortTime(v18)}`)
	end

	if (replion:Get("TotalStats.Wins") or 0) < 1 and not RunService:IsStudio() then
		return false, "You can't trade before getting 1 Win!"
	end

	if not localPlayer:GetAttribute("__globalUpdatesInitialized") then
		return false, "You are still loading!"
	end

	local unixTimestamp = DateTime.now().UnixTimestamp
	local v18 = unixTimestamp - (localPlayer:GetAttribute("JoinedTimestamp") or replion:Get("LastSession") or unixTimestamp)
	local instantFFlag = v7.FFlag.GetInstantFFlag("TradeJoinCooldown", 30)

	if v18 < instantFFlag and not RunService:IsStudio() then
		return false, (`You can't trade for {math.ceil(instantFFlag - v18)} seconds!`)
	end

	local v19, v20 = v9.retryWithDelay(PolicyService.GetPolicyInfoForPlayerAsync, 3, 2, PolicyService, localPlayer):await()

	if v19 and v20 and v20.IsPaidItemTradingAllowed then
		return true
	end

	return false, "You are restricted from trading due to Roblox policy!"
end

function TradeTabController:GetTradeValue(p, p2)
	local v18 = p.Data[tostring(p2.UserId)]

	if not v18 then
		return 0
	end

	local total = 0

	for k, item in v18.Items do
		for _, v19 in item do
			total += v11:GetRAP(k, (v10:ItemToKey(k, v19, v11._IGNORE_ATTRIBUTES))) or 0
		end
	end

	return total + v18.Tokens
end

function TradeTabController:StartTrade(p)
	v6:CloseCurrent(true)
	v6:Lock("Trade", true)
	state:Set(p)
end

function TradeTabController:Clear()
	v6:Unlock("Trade", true)
	state:Set(nil)
end

function TradeTabController:Start()
	v16 = v.Client:WaitReplion("Data")
	v17 = v.Client:WaitReplion("Inventory")
	v.Client:OnReplionAddedWithTag("Trade", function(p)
		if state:Get() then
			warn("[OnReplionAddedWithTag] There is a Trade running already")
		else
			self:StartTrade(p)
		end
	end)
	v.Client:OnReplionRemovedWithTag("Trade", function(p)
		if p == state:Get() then
			self:Clear()
		else
			warn("[OnReplionRemovedWithTag] Failed to clear Trade")
		end
	end)
	trade:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not trade.Enabled and state:Get() then
			v5.Remotes.CancelTrade:InvokeServer()
		end
	end)

	for _, button in main.SideButtons:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v18 = button
		v4.Computed(function(callback)
			local v19

			if callback(state2) == v18.Name then
				v19 = callback(state15) == ""
			else
				v19 = false
			end

			v18.Image = v19 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
			v18.HoverImage = v19 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
			local uIStroke = v18.Label.UIStroke
			local color

			if v19 then
				color = Color3.fromRGB(149, 67, 0)
			else
				color = Color3.fromRGB(21, 56, 169)
			end

			uIStroke.Color = color
			v18.Visible = not callback(state4)
			return nil
		end)
		local v19 = button
		button.Activated:Connect(function()
			main.Left.Items.CanvasPosition = Vector2.zero
			state2:Set(v19.Name)
			state15:Set("")
			searchBox.Text = ""
		end)
	end

	local replionPathState = v4.getReplionPathState(v17, "Tokens")
	v4.setPropertyComputed(main.Currency.Coins.Amount, "Text", function(callback)
		return v7.ValueConvertor:AddCommas(callback(replionPathState))
	end)
	local enterAmount = main.Left.Tokens.EnterAmount
	local v18 = {
		"k",
		"m",
		"b",
		"t"
	}
	enterAmount.FocusLost:Connect(function()
		local text = string.lower(enterAmount.Text)

		for k, v20 in v18 do
			local v21 = tonumber(string.match(text, (`^([%d%.]*)[{v20}]$`)) or "")

			if not v21 then
				continue
			end

			text = tostring(v21 * 1000 ^ k)
			break
		end

		local v20 = math.clamp(
			tonumber((string.gsub(text, "%D+", ""))) or 0,
			math.min(0, replionPathState:Get()),
			(math.max(0, replionPathState:Get()))
		)
		state3:Set(v20)
		enterAmount.Text = v7.ValueConvertor:AddCommas(v20)
		local v21 = not invokeServer(v5.Remotes.AddTokensToTrade, v20) and state:Get()

		if v21 then
			state3:Set(v21:Get({ tostring(localPlayer.UserId), "Tokens" }) or 0)
			enterAmount.Text = v7.ValueConvertor:AddCommas(state3:Get())
		end
	end)

	local function createButton(p, p2, p3)
		local state17 = v4.State(p2)
		local state18 = v4.State(p3)
		v4.Computed(function(callback)
			local v19 = callback(state17)
			local text = callback(state18)
			p.Label.Text = text

			if v19 == "Green" then
				p.Active = true
				p.Image = "rbxassetid://18123799353"
				p.HoverImage = "rbxassetid://18123825435"
				p.Label.UIStroke.Color = Color3.fromRGB(1, 86, 0)
			elseif v19 == "Red" then
				p.Active = true
				p.Image = "rbxassetid://18123810348"
				p.HoverImage = "rbxassetid://18123830153"
				p.Label.UIStroke.Color = Color3.fromRGB(86, 0, 0)
			else
				p.Active = false
				p.Image = "rbxassetid://18526787517"
				p.HoverImage = "rbxassetid://18526787649"
				p.Label.UIStroke.Color = Color3.fromRGB(41, 41, 41)
			end

			return nil
		end)
		return state17, state18
	end

	local accept2 = accept
	local state17 = v4.State("Green")
	local state18 = v4.State("Ready")
	v4.Computed(function(callback)
		local v20 = callback(state17)
		local text = callback(state18)
		accept2.Label.Text = text

		if v20 == "Green" then
			accept2.Active = true
			accept2.Image = "rbxassetid://18123799353"
			accept2.HoverImage = "rbxassetid://18123825435"
			accept2.Label.UIStroke.Color = Color3.fromRGB(1, 86, 0)
		elseif v20 == "Red" then
			accept2.Active = true
			accept2.Image = "rbxassetid://18123810348"
			accept2.HoverImage = "rbxassetid://18123830153"
			accept2.Label.UIStroke.Color = Color3.fromRGB(86, 0, 0)
		else
			accept2.Active = false
			accept2.Image = "rbxassetid://18526787517"
			accept2.HoverImage = "rbxassetid://18526787649"
			accept2.Label.UIStroke.Color = Color3.fromRGB(41, 41, 41)
		end

		return nil
	end)
	local decline2 = decline
	local state19 = v4.State("Red")
	local state20 = v4.State("Decline")
	v4.Computed(function(callback)
		local v21 = callback(state19)
		local text = callback(state20)
		decline2.Label.Text = text

		if v21 == "Green" then
			decline2.Active = true
			decline2.Image = "rbxassetid://18123799353"
			decline2.HoverImage = "rbxassetid://18123825435"
			decline2.Label.UIStroke.Color = Color3.fromRGB(1, 86, 0)
		elseif v21 == "Red" then
			decline2.Active = true
			decline2.Image = "rbxassetid://18123810348"
			decline2.HoverImage = "rbxassetid://18123830153"
			decline2.Label.UIStroke.Color = Color3.fromRGB(86, 0, 0)
		else
			decline2.Active = false
			decline2.Image = "rbxassetid://18526787517"
			decline2.HoverImage = "rbxassetid://18526787649"
			decline2.Label.UIStroke.Color = Color3.fromRGB(41, 41, 41)
		end

		return nil
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearTrade()
		if not state:Get() then
			return
		end

		invokeServer(v5.Remotes.AddTokensToTrade, 0)
		state3:Set(0)
		enterAmount.Text = ""
		invokeServer(v5.Remotes.ClearItemsFromTrade)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showUnfairTradeWarning(tradeValue: number, tradeValue2: number)
		unfairTradeWarning.Amount.Amount.Text = v7.ValueConvertor:AddCommas(tradeValue - tradeValue2)
		unfairTradeWarning.Visible = true
		main.Visible = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hideUnfairTradeWarning()
		unfairTradeWarning.Visible = false
		main.Visible = true
	end

	unfairTradeWarning.Close.Activated:Connect(function()
		hideUnfairTradeWarning() -- equivalent call inferred; original call site unknown
		clearTrade() -- equivalent call inferred; original call site unknown
	end)
	unfairTradeWarning.Buttons.No.Activated:Connect(function()
		hideUnfairTradeWarning() -- equivalent call inferred; original call site unknown
		clearTrade() -- equivalent call inferred; original call site unknown
	end)
	unfairTradeWarning.Buttons.Yes.Activated:Connect(function()
		hideUnfairTradeWarning() -- equivalent call inferred; original call site unknown
		local v21 = state:Get()

		if not v21 then
			return
		end

		invokeServer(v5.Remotes.ReadyUp, not v21:Get({ tostring(localPlayer.UserId), "Ready" }))
	end)
	accept.Activated:Connect(function()
		local v21 = state:Get()

		if not v21 or state13:Get() > 0 then
			return
		end

		if state4:Get() then
			invokeServer(v5.Remotes.ConfirmTrade)
			return
		end

		if v16:Get({ "TradeSettings", "UnfairTradeWarning" }) then
			local v22 = nil

			for _, player in v21.Data.Players do
				if player == localPlayer then
					continue
				end

				v22 = player
				break
			end

			local tradeValue = self:GetTradeValue(v21, v22)
			local tradeValue2 = self:GetTradeValue(v21, localPlayer)
			local timeoutFFlag = v7.FFlag.TimeoutFFlag("UnfairTradeWarningPercent", 5, 50)

			if tradeValue / tradeValue2 <= timeoutFFlag / 100 then
				showUnfairTradeWarning(tradeValue2, tradeValue) -- equivalent call inferred; original call site unknown
				return
			end
		end

		invokeServer(v5.Remotes.ReadyUp, not v21:Get({ tostring(localPlayer.UserId), "Ready" }))
	end)
	decline.Activated:Connect(function()
		if state:Get() then
			invokeServer(v5.Remotes.CancelTrade)
		end
	end)
	main.Close.Activated:Connect(function()
		if state:Get() then
			invokeServer(v5.Remotes.CancelTrade)
		end
	end)
	v4.Computed(function(callback)
		local v21 = callback(state13)
		local text = callback(state14)
		local v23 = callback(state5)
		local v24 = callback(state8)
		local v25 = callback(state10)
		local v26 = callback(state7)
		local v27 = callback(state4)

		if v21 > 0 then
			local formatted = `{math.floor(v21 * 10) / 10}s`

			if v26 then
				label.Text = `⌛ {formatted}`
			else
				state18:Set(formatted)
				state17:Set("Disabled")
				label.Text = ""
			end
		else
			label.Text = text

			if v25 or v24 then
				state18:Set("Confirmed")
				state17:Set("Disabled")
				state20:Set("Cancel")
				state19:Set(v25 and "Disabled" or "Red")
			elseif v27 then
				state18:Set("Confirm")
				state17:Set("Green")
				state20:Set("Decline")
				state19:Set("Red")
			else
				state18:Set(v23 and "Unready" or "Ready")
				state17:Set(v23 and "Red" or "Green")
			end
		end

		enterAmount.TextEditable = not (v27 or v25 or v26)
		local v28 = bottom
		local position

		if #label.Text > 0 then
			position = UDim2.fromScale(0.009, 0.78)
		else
			position = UDim2.fromScale(0.009, 0.8)
		end

		v28.Position = position
		label.Visible = #label.Text > 0
		return nil
	end)

	local function getCountdown()
		local v21 = state:Get()

		if not v21 then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local confirmedTime = v21:Get("ConfirmedTime") or 0

		if confirmedTime and confirmedTime ~= 0 then
			local v22 = serverTimeNow - confirmedTime
			return v5.ConfirmedCountdown + 0.05 - v22, v22
		end

		local v22 = serverTimeNow - (v21:Get("LastChange") or 0)
		return v5.ItemChangeCountdown + 0.05 - v22, v22
	end

	local function updateCountdown()
		local countdown, _ = getCountdown()

		if countdown and countdown <= 0 then
			state13:Set(0)
			countdown = nil
		elseif countdown then
			state13:Set(countdown)
		end

		if not countdown and postSimulationConnection then
			postSimulationConnection:Disconnect()
			postSimulationConnection = nil
		end
	end

	local clones = {}

	local function updateChatMessages(flag: boolean?)
		local frame

		if main.RightChat.Visible then
			frame = main.RightChat.Frame
		else
			frame = trade.MiscChat.Frame
		end

		for _, v21 in clones do
			if not v21.Parent or flag then
				v21.Parent = frame.ChatList
			end
		end
	end

	local function createChatMessage(data, p: string?)
		local child = main.Chat.Templates:FindFirstChild(data.Sender == localPlayer and "Player1" or "Player2")

		if not child then
			return
		end

		local clone = child:Clone()
		clone.Text = data.Message
		clone.LayoutOrder = data.Time
		clone.Visible = true
		clones[p or `{data.Sender.UserId}-{data.Time}`] = clone
		updateChatMessages()
	end

	TextChatService.ChildAdded:Connect(function(textChannel)
		if not (string.find(textChannel.Name, "TradeChat") == 1 and string.find(
			textChannel.Name,
			(tostring(localPlayer.UserId))
		)) then
			return
		end

		if not textChannel:IsA("TextChannel") then
			return
		end

		state12:Set(textChannel)

		textChannel.OnIncomingMessage = function(p)
			local textChatMessageProperties = Instance.new("TextChatMessageProperties")
			local userId = p.TextSource and p.TextSource.UserId
			textChatMessageProperties.PrefixText = ""
			local playerByUserId = userId and Players:GetPlayerByUserId(userId)

			if playerByUserId then
				textChatMessageProperties.PrefixText ..= `[{playerByUserId.DisplayName}]`
			end

			return textChatMessageProperties
		end

		textChannel.MessageReceived:Connect(function(data)
			if clones[data.MessageId] then
				return
			end

			local textSource = data.TextSource

			if not textSource then
				return
			end

			local playerByUserId = Players:GetPlayerByUserId(textSource.UserId)

			if not playerByUserId then
				return
			end

			createChatMessage({
				Sender = playerByUserId,
				Message = `{data.PrefixText} {data.Text}`,
				Time = data.Timestamp.UnixTimestamp
			}, data.MessageId)
		end)
		textChannel.Destroying:Once(function()
			state12:Set(nil)
		end)
	end)
	v5.Remotes.ReceiveChatMessage.OnClientEvent:Connect(createChatMessage)
	v4.Computed(function(callback)
		local v21 = callback(v8.State)
		local v22 = callback(state12) ~= nil
		local rightChat = main.RightChat
		rightChat.Visible = v21 == "PC" and v22
		main.Chat.Misc.Visible = not main.RightChat.Visible and v22
		updateChatMessages()
		return nil
	end)
	local propertyState = v4.getPropertyState(trade.MiscChat, "Visible")
	v4.setPropertyComputed(trade.Black, "ZIndex", function(callback)
		if callback(propertyState) then
			return 1
		end

		return 0
	end)
	v4.setPropertyComputed(main, "Size", function(callback)
		local v21 = callback(v8.State)

		if v21 == "Phone" or v21 == "Tablet" then
			return (UDim2.fromScale(0.65, 0.75))
		end

		return (UDim2.fromScale(0.65, 0.65))
	end)
	v4.setPropertyComputed(main.Left.Items.UIGridLayout, "CellSize", function(callback)
		local v21 = callback(v8.State)

		if v21 == "Phone" or v21 == "Tablet" then
			return (UDim2.fromScale(0.4, 0.4))
		end

		return (UDim2.fromScale(0.31, 0.31))
	end)
	v4.setPropertyComputed(main.Right.Items.UIGridLayout, "CellSize", function(callback)
		local v21 = callback(v8.State)

		if v21 == "Phone" or v21 == "Tablet" then
			return (UDim2.fromScale(0.56, 0.56))
		end

		return (UDim2.fromScale(0.43, 0.43))
	end)
	local v21 = 0

	local function sendText(enterText)
		local DELAY_DURATION = 0.5
		local v22 = state12:Get()

		if not v22 then
			enterText.Text = "Text Channel not found! Please report to the devs!"
			return
		end

		local text = enterText.Text
		local text2 = ""
		enterText.TextEditable = false
		local thread = nil
		thread = task.delay(v5.Chat.Cooldown, function()
			enterText.TextEditable = true
			thread = nil
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancelCooldown()
			enterText.Text = text2

			if thread then
				enterText.TextEditable = true
				v7.Thread.SafeCancel(thread)
				thread = nil
			end
		end

		if #text > v5.Chat.MaxMessageLength then
			enterText.Text = `Text too long ({enterText.Text}/{v5.Chat.MaxMessageLength})`
			task.delay(DELAY_DURATION, cancelCooldown)
		elseif #text < v5.Chat.MinMessageLength then
			if text == "" then
				return
			end

			enterText.Text = `Text too small ({enterText.Text}/{v5.Chat.MinMessageLength})`
			task.delay(DELAY_DURATION, cancelCooldown)
		else
			local now = os.clock()

			if now - v21 < v5.Chat.Cooldown then
				enterText.Text = "Please wait before sending another message"
				text2 = text
				task.delay(DELAY_DURATION, cancelCooldown)
			else
				enterText.Text = ""
				v21 = now
				local success, result = pcall(v22.SendAsync, v22, text)

				if not success then
					task.spawn(error, (`[TradeChat] - Failed to send message {result}`))
				end

				cancelCooldown() -- equivalent call inferred; original call site unknown
			end
		end
	end

	local v22 = 0

	local function sendQuickText(p: number)
		if not state12:Get() then
			v15:SendNotification("Text Channel not found! Please report to the devs!")
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()

		if serverTimeNow - v22 <= v5.Chat.Cooldown then
			v15:SendNotification("Please wait before sending another message!")
			return
		end

		v22 = serverTimeNow

		if not v5.Chat.QuickMessages[p] then
			v15:SendNotification("Failed to find quick message!")
			return
		end

		local v23, message = v5.Remotes.SendChatMessage:InvokeServer(p)

		if v23 then
			createChatMessage({
				Sender = localPlayer,
				Message = message,
				Time = serverTimeNow
			})
		else
			v15:SendNotification(message or "Something went wrong!")
		end
	end

	local rightChat = main.RightChat
	local enterText = rightChat.Frame.ChatButton.EnterText
	enterText.FocusLost:Connect(function(flag: boolean)
		if flag then
			sendText(enterText)
		end
	end)
	rightChat.Frame.ChatButton.Activated:Connect(function()
		enterText:CaptureFocus()
	end)
	rightChat.Frame.ChatButton.SendButton.Activated:Connect(function()
		sendText(enterText)
	end)

	for k, quickMessage in v5.Chat.QuickMessages do
		local clone = main.RightChat.Frame.QuickWords.UIGridLayout.QuickMessageTemplate:Clone()
		clone.Name = `Message_{k}`
		clone.LayoutOrder = k
		clone.Label.Text = `"{quickMessage}"`
		local v23 = k
		clone.Activated:Connect(function()
			sendQuickText(v23)
		end)
		clone.Parent = main.RightChat.Frame.QuickWords
	end

	local miscChat = trade.MiscChat
	local enterText2 = miscChat.Frame.ChatButton.EnterText
	miscChat.Frame.ChatButton.SendButton.Activated:Connect(function()
		sendText(enterText2)
	end)
	miscChat.Frame.ChatButton.Activated:Connect(function()
		enterText2:CaptureFocus()
	end)
	miscChat.Frame.Close.Activated:Connect(function()
		miscChat.Visible = false
	end)
	main.Chat.Misc.ChatButton.Activated:Connect(function()
		miscChat.Visible = not miscChat.Visible
	end)

	for k, quickMessage in v5.Chat.QuickMessages do
		local clone = miscChat.Frame.QuickWords.UIGridLayout.QuickMessageTemplate:Clone()
		clone.Name = `Message_{k}`
		clone.LayoutOrder = k
		clone.Label.Text = `"{quickMessage}"`
		local v23 = k
		clone.Activated:Connect(function()
			sendQuickText(v23)
		end)
		clone.Parent = miscChat.Frame.QuickWords
	end

	searchBox.FocusLost:Connect(function(flag: boolean)
		if flag then
			main.Left.Items.CanvasPosition = Vector2.zero
			state15:Set(searchBox.Text)
		end
	end)
	main.ItemSearch.Search.Activated:Connect(function()
		main.Left.Items.CanvasPosition = Vector2.zero
		state15:Set(searchBox.Text)
	end)
	local inventory = main.Inventory
	inventory.Activated:Connect(function()
		local v23 = state:Get()

		if not v23 then
			return
		end

		local fakePlayer = nil

		for _, v25 in v23:GetExpect("Players") do
			if v25 == localPlayer then
				continue
			end

			fakePlayer = v25
			break
		end

		if not fakePlayer then
			return
		end

		if type(fakePlayer) == "table" then
			fakePlayer = v13.FakePlayer
		end

		local playerStates = v13:GetPlayerStates(fakePlayer)

		if not playerStates then
			return
		end

		local v25 = playerStates.options:Get()

		if v25 and v25.CanViewInventory and v14:ViewInventory(fakePlayer) and not v6:IsOpen("ViewInventory") then
			v6:Open("ViewInventory", true, true)
		end
	end)
	local v23 = {}
	v4.Computed(function(callback)
		local replion = callback(state)
		trade.Enabled = replion ~= nil

		if replion then
			callback((v4.getReplionPathState(replion, "TradeId")))
			callback((v4.getReplionPathState(replion, "LastChange")))
			local v25 = callback((v4.getReplionPathState(replion, "Processing")))
			local v26 = callback((v4.getReplionPathState(replion, "ConfirmedTime")))
			local v27 = callback((v4.getReplionPathState(replion, "Players")))
			state11:Set(callback((v4.getReplionPathState(replion, "CanChat"))))
			updateChatMessages()
			local flag = true
			local v28 = true

			for _, v29 in v27 do
				local userId = tostring(v29.UserId)
				local v30 = callback((v4.getReplionPathState(replion, { userId, "Ready" })))
				local v31 = callback((v4.getReplionPathState(replion, { userId, "Confirmed" })))
				callback((v4.getReplionPathState(replion, { userId, "Tokens" })))

				if not v30 then
					flag = false
				end

				if not v31 then
					v28 = false
				end
			end

			for _, fakePlayer in v27 do
				local userId = tostring(fakePlayer.UserId)
				local v29 = fakePlayer == localPlayer
				local left

				if v29 then
					left = main.Left
				else
					left = main.Right
				end

				local v30 = v29 and "LOCAL" or userId
				local v31 = callback((v4.getReplionPathState(replion, { userId, "Ready" })))
				local v32 = callback((v4.getReplionPathState(replion, { userId, "Confirmed" })))
				local v33 = callback((v4.getReplionPathState(replion, { userId, "Tokens" })))
				callback((v4.getReplionPathState(replion, { userId, "Items" })))
				local tradeValue = self:GetTradeValue(replion, fakePlayer)
				left.Top.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=100&h=100`
				left.ReadyOverlay.Visible = v31 and not flag
				left.ConfirmedOverlay.Visible = v32 or v25
				left.Top.Labels.Amount.Amount.Text = v7.ValueConvertor:AddCommas(tradeValue)

				if v29 then
					state5:Set(v31)
					state8:Set(v32)

					if flag then
						left.Tokens.EnterAmount.Text = v7.ValueConvertor:AddCommas(v33 or 0)
					end
				else
					state6:Set(v31)
					state9:Set(v32)
					left.Top.Labels.PlayerName.Text = `{fakePlayer.DisplayName}'s Value:`
					left.TokenOffer.Amount.Amount.Text = v7.ValueConvertor:AddCommas(v33 or 0)
					miscChat.Frame.Title.Text = `Chat with {fakePlayer.DisplayName}`
					rightChat.Frame.Title.Text = `Chat with {fakePlayer.DisplayName}`

					if type(fakePlayer) == "table" then
						fakePlayer = v13.FakePlayer
					end

					local playerStates = v13:GetPlayerStates(fakePlayer)

					if playerStates then
						local canViewInventory = callback(playerStates.options).CanViewInventory
						inventory.Active = canViewInventory
						inventory.Image = canViewInventory and "rbxassetid://18711611169" or "rbxassetid://18860669626"
						inventory.HoverImage = canViewInventory and "rbxassetid://18711662604" or "rbxassetid://18860669386"
						local uIStroke = inventory.Label.UIStroke
						local color

						if canViewInventory then
							color = Color3.fromRGB(93, 18, 112)
						else
							color = Color3.fromRGB(41, 41, 41)
						end

						uIStroke.Color = color
					end
				end

				if v23[v30] then
					continue
				end

				v23[v30] = {}
				local v34 = userId
				local v35 = {
					Type = "FakeCaller",
					CustomType = "Trading",
					ModifyPath = function(p)
						return v2.List.concat({ v34, "Items" }, v2.List.shift(p))
					end,
					Replion = replion
				}

				for _, tradableItemType in v5.TradableItemTypes do
					v23[v30][tradableItemType] = createInventory(v30, tradableItemType, left.Items, v35)
				end
			end

			if getCountdown() then
				if not postSimulationConnection then
					postSimulationConnection = RunService.PostSimulation:Connect(updateCountdown)
				end
			elseif postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
			end

			state4:Set(flag)
			state7:Set(v28)
			state10:Set(v25)

			if v25 or v26 > 0 then
				state14:Set("Processing Trade")
			elseif v28 or not flag then
				state14:Set("")
			else
				state14:Set("Countdown starts when both players confirm")
			end

			return nil
		else
			for _, v25 in pairs(v23) do
				for _, v26 in pairs(v25) do
					v26:Destroy()
				end
			end

			table.clear(v23)

			for _, v25 in clones do
				v25:Destroy()
			end

			table.clear(clones)

			if postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
			end

			state14:Set("")
			state15:Set("")
			searchBox.Text = ""
			state2:Set("Sword")
			state3:Set(0)
			state13:Set(0)
			state4:Set(false)
			state5:Set(false)
			state6:Set(false)
			state7:Set(false)
			state8:Set(false)
			state9:Set(false)
			state10:Set(false)
			state11:Set(false)
			enterAmount.Text = ""
			main.Visible = true
			unfairTradeWarning.Visible = false
			return nil
		end
	end)
end

return TradeTabController