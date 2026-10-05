local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Promise)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Packages.Observers)
local v6 = nil
local v7 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v8 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v9 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v10 = require3(ReplicatedStorage2.Controllers.Trading.TradeController)
local v11 = require3(ReplicatedStorage2.Packages.Trove)
local v12 = require3(ReplicatedStorage2.Shared.DeepCopy)
local v13 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.ServerInfo)
local v14 = require3(ReplicatedStorage2.Shared.Trading.TradingTokens)
local v15 = require3(ReplicatedStorage2.Shared.Statable)
local v16 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v17 = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.Shared.ItemInfo)
local v18 = require3(ReplicatedStorage2.Controllers.ViewInventoryController)
local v19 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v20 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v21 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v22 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local localPlayer = Players.LocalPlayer
local HUD = localPlayer.PlayerGui.HUD
local tradeRequest = localPlayer.PlayerGui.TradeRequest
local tradeCompleted = localPlayer.PlayerGui.TradeCompleted
local tradeIncoming = localPlayer.PlayerGui.TradeIncoming
local main = tradeRequest.Main
local tokensInfo = tradeRequest.TokensInfo
local tokensShop = tradeRequest.TokensShop
local tradeHistory = main.Views.TradeHistory
local tradeSettings = main.Views.TradeSettings
local tradeItemsHistory = main.Views.TradeItemsHistory
local itemsReceived = tradeItemsHistory.Label.ItemsReceived
local itemsSent = tradeItemsHistory.Label.ItemsSent
local scrollingFrame = main.Views.PlayersList.ScrollingFrame
local template = scrollingFrame.UIListLayout.Template
local v23 = {
	{
		key = "Last 7 Days",
		filterTime = 604800
	},
	{
		key = "Last 14 Days",
		filterTime = 1209600
	},
	{
		key = "Last 30 Days",
		filterTime = 2592000
	},
	{
		key = "Last 60 Days",
		filterTime = 5184000
	}
}
local state = v15.State("Main")
local state2 = v15.State("PlayersList")
local state3 = v15.State(v23[1])
local state4 = v15.State("")
local state5 = v15.State("")
local state6 = v15.State(nil)
local state7 = v15.State(nil)
local v24 = {}
local maid = v11.new()
local fakePlayer = {
	Name = "SpyderSammy",
	DisplayName = "SpyderSammy",
	UserId = 2678001507
}
local TradeRequestController = {}
TradeRequestController.CurrentPage = state
TradeRequestController.CurrentTab = state2
TradeRequestController.FakePlayer = fakePlayer

function TradeRequestController.OpenPage(_, p)
	state:Set(p)
end

function TradeRequestController:GetPlayerStates(p)
	return v24[p]
end

function TradeRequestController:SendTrade(p)
	local playerStates = self:GetPlayerStates(p)

	if not playerStates or playerStates.didInvite:Get() or playerStates.isInMatch:Get() or not playerStates.options:Get().CanInvite or playerStates.isInviting:Get() then
		return
	end

	playerStates.isInviting:Set(true)
	task.delay(0.25, function()
		playerStates.isInviting:Set(false)
	end)

	if not v7.Remotes.SendTradeRequest:InvokeServer(p) then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	playerStates.didInvite:Set(true)
	task.delay(v7.TradeRequestExpiration, function()
		playerStates.didInvite:Set(false)
	end)
end

function TradeRequestController:ShowTrade(p)
	if state7:Get() == p then
		if state2:Get() ~= "TradeItemsHistory" then
			state2:Set("TradeItemsHistory")
		end
	else
		maid:Clean()
		state5:Set("")
		state7:Set(p)

		if p == nil then
			return
		end

		local v26 = nil
		local username = nil

		for k, user in p.Users do
			if k == tostring(localPlayer.UserId) then
				continue
			end

			v26 = tonumber(k)
			username = user.Username
			break
		end

		if not v26 then
			return
		end

		local user = p.Users[tostring(v26)]
		local user2 = p.Users[tostring(localPlayer.UserId)]
		tradeItemsHistory.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v26}&w=150&h=150`
		local state8 = v15.State(username)

		if not state8:Get() then
			maid:AddPromise(v17:GetUser(v26):andThen(function(p2)
				state8:Set(p2.Username)
			end))
		end

		maid:Add(v15.setPropertyComputed(tradeItemsHistory.Username, "Text", function(callback)
			return (`@{callback(state8) or "[LOADING]"}`)
		end))

		for k, v28 in { user2, user } do
			local v29 = {}
			local clonesByItemToKey = {}
			local v30

			if k == 1 then
				v30 = itemsSent
			else
				v30 = itemsReceived
			end

			v30.Tokens.Amount.Text = v13.ValueConvertor:AddCommas(v28.Tokens)

			for k2, item in v28.Items do
				for _, v31 in item do
					local itemToKey = client:ItemToKey(k2, v31, { "Id" })

					if v29[itemToKey] then
						v29[itemToKey] += 1
					else
						local itemInfo = v8:GetItemInfo(k2, v31.Name)

						if itemInfo then
							local clone = maid:Clone(itemsReceived.ScrollingFrame.UIGridLayout.Template)
							clone.ItemName.Text = itemInfo.DisplayName or itemInfo.Name
							clone.Vector.Image = itemInfo.Icon or v13.Icons:GetIcon("DEFAULT_MISSING")
							local rarity = itemInfo.Rarity

							if rarity then
								local v32 = v7.SlotColors[rarity] or v7.SlotColors.Default
								clone.Image = v32.Image
								clone.HoverImage = v32.HoverImage
								clone.ItemName.UIStroke.Color = v32.StrokeColor
							end

							v21:Add(clone, k2, v31, itemToKey)

							if k == 1 then
								local v32 = string.lower(itemInfo.DisplayName or v31.Name)
								maid:Add(v15.setPropertyComputed(clone, "Visible", function(callback)
									local v33 = string.lower(callback(state5))
									return #v33 <= 0 or v32 == v33 or string.sub(v32, 1, #v33) == v33 or string.find(
										v32,
										v33,
										1,
										true
									) ~= nil
								end))
							end

							clone.Parent = v30.ScrollingFrame
							local stack = clone:FindFirstChild("Stack")
							local finisher = clone:FindFirstChild("Finisher")
							local swordAccessory = clone:FindFirstChild("SwordAccessory")

							if k2 == "Sword" then
								finisher.Visible = v31 and v31.Finisher ~= nil

								if finisher.Visible then
									local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(v31.Name)
									finisher.Icon.Image = child and child:GetAttribute("Icon") or v13.Icons:GetIcon("DEFAULT_MISSING")
								end

								swordAccessory.Visible = v31 and v31.Accessory == true

								if swordAccessory.Visible then
									local v32 = v22:GetCollection()[v31.Name]
									swordAccessory.Icon.Image = v32 and v32.Icon or v13.Icons:GetIcon("DEFAULT_MISSING")
								end
							end

							local v32 = { stack, finisher, swordAccessory }

							for i = #v32, 1, -1 do
								if v32[i] == nil then
									table.remove(v32, i)
								end
							end

							local positions = {}

							for k3, v33 in v32 do
								local position = v33:GetAttribute("Position")

								if not position then
									position = v33.Position
									v33:SetAttribute("Position", position)
								end

								positions[k3] = position
							end

							local v33 = 1

							for _, v34 in v32 do
								if not v34.Visible then
									continue
								end

								v34.Position = positions[v33] or v34.Position
								v33 += 1
							end

							v29[itemToKey] = 1
							clonesByItemToKey[itemToKey] = clone
						else
							warn((`Failed to find info for {k2}: "{v31.Name}"`))
						end
					end
				end
			end

			for k2, v31 in v29 do
				clonesByItemToKey[k2].Stack.Label.Text = `x{v31}`
				clonesByItemToKey[k2].Stack.Visible = v31 > 1
			end
		end

		state2:Set("TradeItemsHistory")
	end
end

function TradeRequestController.Init(_)
	v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTabController)
end

function TradeRequestController:Start()
	local v26 = v.Client:WaitReplion("TradeList")
	local v27 = v.Client:WaitReplion("Data")
	local v28 = v.Client:WaitReplion("Inventory")

	if client:GetInventoryVersion() == "New" then
		local function updateButtonVisibility()
			local hasTradeRequirementsInstant = v10:HasTradeRequirementsInstant()

			if hasTradeRequirementsInstant then
				if v19:GetKey("TradingEnabled") == true then
					hasTradeRequirementsInstant = v19:GetKey("TradingSystemEnabled") == true
				else
					hasTradeRequirementsInstant = false
				end
			end

			local v29 = localPlayer.Character and localPlayer.Character.Parent == workspace.Alive
			HUD.LeftFrame.Bottom.BottomOptions.TradeButton.Visible = hasTradeRequirementsInstant and not (v20:IsMobile() or v29)
			HUD.LeftFrame.TradeButton.Visible = hasTradeRequirementsInstant and v20:IsMobile() and not v29
		end

		v27:OnChange("TotalStats.Wins", updateButtonVisibility)
		workspace.Alive.ChildAdded:Connect(updateButtonVisibility)
		workspace.Alive.ChildRemoved:Connect(updateButtonVisibility)
		v19.DataUpdatedEvent:Connect(updateButtonVisibility)
		v20:Observe(updateButtonVisibility)
		task.spawn(updateButtonVisibility)

		if not v10:CanTradeInstant() then
			v10:ListenForCanTrade(updateButtonVisibility)
		end
	end

	HUD.LeftFrame.Bottom.BottomOptions.TradeButton.Activated:Connect(function()
		v4:Open(tradeRequest.Name)
	end)
	HUD.LeftFrame.TradeButton.Activated:Connect(function()
		v4:Open(tradeRequest.Name)
	end)
	v4:OnGuiOpen(tradeRequest.Name, function()
		if v27:Get("HasInteractedWithTrading") then
			return
		end

		v7.Remotes.SetUIOpen:FireServer()
	end)
	task.spawn(function()
		local v29, v30 = v2.retryWithDelay(PolicyService.GetPolicyInfoForPlayerAsync, 3, 2, PolicyService, localPlayer):await()

		if v29 and v30 and not v30.IsPaidItemTradingAllowed and v27:Get("TotalStats.Wins") >= 1 then
			v7.Remotes.SetUIOpen:FireServer()
		end
	end)

	for _, child in tradeRequest.Main.Views:GetChildren() do
		local v29 = child
		v15.setPropertyComputed(child, "Visible", function(callback)
			return callback(state2) == v29.Name
		end)
	end

	for _, button in tradeRequest.Main.TopButtons:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v29 = button
		v15.Computed(function(callback)
			local v30 = callback(state2) == v29.Name
			v29.Image = v30 and "rbxassetid://18349747903" or "rbxassetid://18349766782"
			v29.HoverImage = v30 and "rbxassetid://18349971549" or "rbxassetid://18349973767"
			local uIStroke = v29.Label.UIStroke
			local color

			if v30 then
				color = Color3.fromRGB(149, 67, 0)
			else
				color = Color3.fromRGB(21, 61, 168)
			end

			uIStroke.Color = color
			return nil
		end)
		local v30 = button
		button.Activated:Connect(function()
			if state2:Get() == "TradePinEnter" then
				return
			end

			state2:Set(v30.Name)
		end)
	end

	v15.Computed(function(callback)
		local v29 = callback(state)

		for _, image in tradeRequest:GetChildren() do
			if image:IsA("ImageLabel") then
				image.Visible = image.Name == v29
			end
		end

		return nil
	end)
	main.Close.Activated:Connect(function()
		v4:Close(tradeRequest.Name)
		state2:Set("PlayersList")
	end)
	main.Currency.About.Activated:Connect(function()
		state:Set("TokensInfo")
	end)
	main.Currency.AddMore.Activated:Connect(function()
		if v19:GetKey("TradingTokensEnabled") ~= true then
			v9:SendNotification("Tokens are disabled!")
		elseif v19:GetKey("TradingTokensPurchasesEnabled") == true then
			state:Set("TokensShop")
		else
			v9:SendNotification("Token purchases are disabled!")
		end
	end)
	v15.setPropertyComputed(main.Currency.Coins.Amount, "Text", function(callback)
		return v13.ValueConvertor:AddCommas(callback((v15.getReplionPathState(v28, "Tokens"))))
	end)
	local state8 = v15.State({})
	local clonesByFrom = {}
	v15.Computed(function(callback)
		if callback(v6.TradeReplionState) then
			for _, v29 in clonesByFrom do
				v29:Destroy()
			end

			table.clear(clonesByFrom)
		end

		return nil
	end)

	local function observePlayer(player)
		if player == localPlayer then
			return nil
		end

		local state9 = v15.State(false)
		local state10 = v15.State(false)
		local v29

		if typeof(player) == "Instance" then
			v29 = v5.observeCharacter(player, function(_, instance)
				local parentChangedConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
					state10:Set(instance.Parent == workspace.Alive)
				end)
				return function()
					parentChangedConnection:Disconnect()
				end
			end)
		else
			v29 = nil
		end

		local clone = template:Clone()
		local buttons = clone.Buttons
		local username = clone.Username
		username:SetAttribute("TextPreview", player.DisplayName)
		username:SetAttribute("TextReveal", (`@{player.Name}`))
		username:AddTag("TextHoverReveal")
		clone.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		clone.Parent = scrollingFrame
		local options = v15.Computed(function(callback)
			local v30 = callback((v15.getReplionPathState(v26, (tostring(player.UserId)))))
			return {
				CanInvite = v30 and (v30.AllowRequests == "Friends" and table.find(
					v30.UserFriends,
					(tostring(localPlayer.UserId))
				) ~= nil or v30.AllowRequests == "Everyone"),
				CanViewInventory = v30 and (v30.ViewInventory == "Friends" and table.find(
					v30.UserFriends,
					(tostring(localPlayer.UserId))
				) ~= nil or v30.ViewInventory == "Everyone")
			}
		end)
		local hasPendingRequest = v15.Computed(function(callback)
			local v30 = callback(state8)

			for _, v32 in v30 do
				if v32.From == player and v32.To == localPlayer then
					return true
				end
			end

			return false
		end)
		v24[player] = {
			didInvite = state9,
			isInMatch = state10,
			options = options,
			isInviting = v15.State(false),
			hasPendingRequest = hasPendingRequest
		}
		local computed3 = v15.Computed(function(callback)
			local v30 = callback(state9)
			local v31 = callback(state10)
			local v32 = callback(options)
			callback(state8)
			local v33 = callback(hasPendingRequest)
			buttons.Inventory.Visible = v32.CanViewInventory

			if v30 then
				buttons.Interaction.Size = UDim2.fromScale(0.187, 0.682)
				buttons.Interaction.Image = "rbxassetid://18349866093"
				buttons.Interaction.HoverImage = "rbxassetid://18349978039"
				buttons.Interaction.Label.Text = "SENT"
				buttons.Interaction.Label.UIStroke.Color = Color3.fromRGB(149, 67, 0)
			elseif v31 then
				buttons.Interaction.Size = UDim2.fromScale(0.25, 0.682)
				buttons.Interaction.Image = "rbxassetid://18349871268"
				buttons.Interaction.HoverImage = "rbxassetid://18349982582"
				buttons.Interaction.Label.Text = "IN MATCH"
				buttons.Interaction.Label.UIStroke.Color = Color3.fromRGB(63, 63, 63)
			elseif v32.CanInvite or v33 then
				buttons.Interaction.Size = UDim2.fromScale(0.187, 0.682)
				buttons.Interaction.Image = "rbxassetid://18349847684"
				buttons.Interaction.HoverImage = "rbxassetid://18349979827"
				buttons.Interaction.Label.Text = v33 and "ACCEPT" or "SEND"
				buttons.Interaction.Label.UIStroke.Color = Color3.fromRGB(23, 116, 21)
			else
				buttons.Interaction.Size = UDim2.fromScale(0.25, 0.682)
				buttons.Interaction.Image = "rbxassetid://18349871268"
				buttons.Interaction.HoverImage = "rbxassetid://18349982582"
				buttons.Interaction.Label.Text = "NOT ACCEPTING"
				buttons.Interaction.Label.UIStroke.Color = Color3.fromRGB(63, 63, 63)
			end

			return nil
		end)
		local activatedConnection = buttons.Interaction.Activated:Connect(function()
			self:SendTrade(player)
		end)
		buttons.Inventory.Activated:Connect(function()
			if not options:Get().CanViewInventory then
				return
			end

			v18:ViewInventory(player)
		end)
		local computed4 = v15.Computed(function(callback)
			if callback(v6.TradeReplionState) then
				state9:Set(false)
			end

			return nil
		end)
		return function()
			v24[player] = nil
			computed4:Destroy()
			activatedConnection:Disconnect()
			clone:Destroy()
			computed3:Destroy()

			if v29 then
				v29()
			end
		end
	end

	v5.observePlayer(observePlayer)

	if #Players:GetPlayers() == 1 and RunService:IsStudio() then
		task.spawn(observePlayer, fakePlayer)
	end

	v7.Remotes.ReceivedTradeRequest.OnClientEvent:Connect(function(p)
		if v6.TradeReplionState:Get() then
			return
		end

		local clone = tradeIncoming.Template:Clone()
		clone.Description.Text = `Trade request from {p.From.DisplayName} (@{p.From.Name})\ndo you want to accept?`
		clone.Visible = true
		clone.Parent = tradeIncoming
		clonesByFrom[p.From] = clone
		local v29 = state8:Get()
		state8:Set(v3.List.insert(v29, #v29 + 1, p))
		clone.Destroying:Once(function()
			local v30 = state8:Get()
			state8:Set(v3.List.removeValue(v30, p))
		end)
		local thread = nil
		thread = task.delay(p.Time + v7.TradeRequestExpiration - workspace:GetServerTimeNow(), function()
			clone:Destroy()
			thread = nil
		end)
		clone.Buttons.No.Activated:Once(function()
			clone:Destroy()

			if thread then
				v13.Thread.SafeCancel(thread)
				thread = nil
			end
		end)
		clone.Buttons.Yes.Activated:Once(function()
			local v30, v31 = v7.Remotes.RespondToTradeRequest:InvokeServer(p.From, true)

			if v30 then
				clone:Destroy()

				if thread then
					v13.Thread.SafeCancel(thread)
					thread = nil
				end
			else
				ReplicatedStorage2.Misc.error:Play()

				if v31 then
					warn(v31)
				end
			end
		end)
	end)

	local function updateDisclaimer()
		local key = v19:GetKey("TradingTokensDisclaimer")

		if key == nil then
			return
		end

		tokensInfo.List["3"].Visible = not key
		tokensInfo.List.Disclaimer.Visible = key
	end

	v19.DataUpdatedEvent:Connect(updateDisclaimer)
	task.spawn(updateDisclaimer)
	tokensInfo.Close.Activated:Connect(function()
		state:Set("Main")
	end)
	tokensShop.Close.Activated:Connect(function()
		state:Set("Main")
	end)

	for _, v29 in { tokensShop.ItemsList.Bottom, tokensShop.ItemsList.Top } do
		for _, button in v29:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local v31 = v14[assert((tonumber(button.Name)))]
			button.Coins.Amount.Text = v31.Amount

			if v31.Bonus then
				local bonusName = button:FindFirstChild("BonusName")

				if bonusName then
					bonusName.Text = v31.Bonus.DisplayName
				end

				local bonusIcon = button:FindFirstChild("BonusIcon")

				if bonusIcon then
					bonusIcon.Image = v31.Bonus.Icon or ""
				end
			end

			local buyButton = button.BuyButton
			buyButton.Activated:Connect(function()
				if v19:GetKey("TradingTokensEnabled") ~= true then
					v9:SendNotification("Tokens are disabled!")
				elseif v19:GetKey("TradingTokensPurchasesEnabled") == true then
					v16:PromptProductPurchase(localPlayer, v31.ProductId)
				else
					v9:SendNotification("Token purchases are disabled!")
				end
			end)
			buyButton.Label.Text = `{v31.Amount}`
		end
	end

	tradeCompleted.Main.Close.Activated:Connect(function()
		v4:Open("TradeRequest")
	end)
	tradeCompleted.Main.Ok.Activated:Connect(function()
		v4:Open("TradeRequest")
	end)
	local template2 = tradeHistory.ScrollingFrame.UIListLayout.Template
	local templateExpanded = tradeHistory.ScrollingFrame.UIListLayout.TemplateExpanded
	local clonesById = {}
	local state9 = v15.State({})
	local computed = v15.Computed(function(callback)
		local v29 = callback((v15.getReplionPathState(v28, "TradeHistoryPage")))
		local v30 = callback((v15.getReplionPathState(v28, "TradeHistoryIds")))
		local v31 = 500
		local result = {}

		for i = v29, math.max(v29 - 3, 1), -1 do
			local v32 = v30[tostring(i)]

			if not v32 then
				break
			end

			for k, v34 in v32 do
				if v31 <= 0 then
					break
				end

				if (v7.TradeIdToStatus[v34.Status] or v34.Status) ~= "Completed" then
					continue
				end

				local v35 = v12(v34)
				v35.Id = k
				v35.Page = tostring(i)
				table.insert(result, v35)
				v31 -= 1
			end
		end

		return result
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getTradeState(p)
		return v15.Computed(function(callback)
			local v29 = callback(state9)

			if not v29[p.Page] then
				return nil
			end

			for _, v30 in v29[p.Page] do
				if v30.Id == p.Id then
					return v30
				end
			end

			return nil
		end)
	end

	v15.Computed(function(callback)
		if callback(state2) ~= "TradeHistory" then
			return nil
		end

		local v29 = callback(computed)

		for _, v30 in v29 do
			if clonesById[v30.Id] then
				continue
			end

			local tradeState = getTradeState(v30) -- equivalent call inferred; original call site unknown
			local maid2 = v11.new()
			local clone = template2:Clone()
			clone.Name = v30.Id
			clonesById[v30.Id] = clone
			local dateTime = DateTime.fromUnixTimestamp(v30.Time)
			local v31 = ""
			local serverTimeNow = workspace:GetServerTimeNow()
			local v32 = DateTime.fromUnixTimestamp(serverTimeNow):ToLocalTime().Day - dateTime:ToLocalTime().Day
			local v33

			if serverTimeNow - dateTime.UnixTimestamp <= 172800 and (v32 == 0 or v32 == 1) then
				v33 = "LT"

				if v32 == 1 then
					v31 = "Yesterday "
				end
			else
				v33 = "l LT"
			end

			clone.Time.Text = `{v31}{dateTime:FormatLocalTime(v33, LocalizationService.SystemLocaleId)}`
			local v35 = maid2:Add(v15.Computed(function(callback2)
				local v36 = callback2(tradeState)

				if not v36 then
					return nil
				end

				local userId = nil
				local username = nil

				for k, user in v36.Users do
					if k == tostring(localPlayer.UserId) then
						continue
					end

					userId = tonumber(k)
					username = user.Username
					break
				end

				if userId then
					return {
						userId = userId,
						username = username
					}
				end

				return nil
			end))
			local v36 = tradeState
			local v37 = maid2:Add(v15.Computed(function(callback2)
				local v38 = callback2(v36)

				if v38 then
					return v38.Users[tostring(localPlayer.userId)]
				end

				return nil
			end))
			local v38 = tradeState
			local v40 = maid2:Add(v15.Computed(function(callback2)
				local v41 = callback2(v38)
				local v42 = callback2(v35)

				if v42 and v41 then
					return v41.Users[tostring(v42.userId)]
				end

				return nil
			end))
			local v41 = nil
			local v42 = v15.State(nil)
			local v43 = v35
			local v45 = maid2:Add(v15.Computed(function(callback2)
				local v46 = callback2(v42)

				if v46 then
					return v46
				end

				local v47 = callback2(v43)

				if not v47 then
					return nil
				end

				if v47.username then
					return v47.username
				end

				if not v41 then
					v41 = maid2:AddPromise(v17:GetUser(v47.userId):andThen(function(p)
						v42:Set(p.Username)
					end))
				end

				return nil
			end))
			maid2:Add(v15.setPropertyComputed(clone.TextLabel, "Text", function(callback2)
				return (`Trade with @{callback2(v45) or "[LOADING]"}`)
			end))
			maid2:Add(v15.setPropertyComputed(clone.Tokens.Amount, "Text", function(callback2)
				local v49 = callback2(v40)
				local v50 = callback2(v37)

				if v50 and v49 then
					local v51 = math.floor(v49.Tokens - v50.Tokens)
					return (`{v51 > 0 and "+" or v51 < 0 and "-" or ""}{v13.ValueConvertor:AddCommas((math.abs(v51)))}`)
				else
					return "+???"
				end
			end))
			local v49 = v35
			maid2:Add(v15.setPropertyComputed(clone.ProfilePicture.Headshot, "Image", function(callback2)
				local v50 = callback2(v49)

				if v50 then
					return (`rbxthumb://type=AvatarHeadShot&id={v50.userId}&w=150&h=150`)
				end

				return ""
			end))
			local v50 = v40
			local v51 = v37
			local v53 = maid2
			maid2:Add(v15.Computed(function(callback2)
				local v54 = callback2(v50)
				local v55 = callback2(v51)

				if not (v55 and v54) then
					return nil
				end

				for i, child in clone.ItemsHistory:GetChildren() do
					if child.Name == "Item" then
						child:Destroy()
					end
				end

				for k, v56 in { v55, v54 } do
					local v57 = 5
					local v58 = {}
					local clonesByItemToKey = {}

					for k2, item in v56.Items do
						local layoutOrder = (k - 1) * 2

						for k3, v61 in item do
							if v57 <= 0 then
								break
							end

							local itemToKey = client:ItemToKey(k2, v61, { "Id" })

							if v58[itemToKey] then
								v58[itemToKey] += 1
							else
								local itemInfo = v8:GetItemInfo(k2, v61.Name)

								if itemInfo then
									local clone2 = v53:Clone(clone.ItemsHistory.UIListLayout.Template)
									clone2.Name = "Item"
									clone2.LayoutOrder = layoutOrder
									clone2.Icon.Image = itemInfo.Icon or v13.Icons:GetIcon("DEFAULT_MISSING")
									local rarity = itemInfo.Rarity

									if rarity then
										local v62 = v7.SmallerSlotColors[rarity] or v7.SmallerSlotColors.Default
										clone2.Image = v62.Image
										clone2.HoverImage = v62.HoverImage
									end

									v21:Add(clone2, k2, v61, itemToKey)
									clone2.Parent = clone.ItemsHistory
									local stack = clone2:FindFirstChild("Stack")
									local finisher = clone2:FindFirstChild("Finisher")
									local swordAccessory = clone2:FindFirstChild("SwordAccessory")

									if k2 == "Sword" then
										finisher.Visible = v61 and v61.Finisher ~= nil

										if finisher.Visible then
											local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(v61.Name)
											finisher.Icon.Image = child and child:GetAttribute("Icon") or v13.Icons:GetIcon("DEFAULT_MISSING")
										end

										swordAccessory.Visible = v61 and v61.Accessory == true

										if swordAccessory.Visible then
											local v62 = v22:GetCollection()[v61.Name]
											swordAccessory.Icon.Image = v62 and v62.Icon or v13.Icons:GetIcon("DEFAULT_MISSING")
										end
									end

									local v62 = { stack, finisher, swordAccessory }

									for i = #v62, 1, -1 do
										if v62[i] == nil then
											table.remove(v62, i)
										end
									end

									local positions = {}

									for k4, v63 in v62 do
										local position = v63:GetAttribute("Position")

										if not position then
											position = v63.Position
											v63:SetAttribute("Position", position)
										end

										positions[k4] = position
									end

									local v63 = 1

									for k4, v64 in v62 do
										if not v64.Visible then
											continue
										end

										v64.Position = positions[v63] or v64.Position
										v63 += 1
									end

									v58[itemToKey] = 1
									clonesByItemToKey[itemToKey] = clone2
									v57 -= 1
								else
									warn((`Failed to find info for {k2}: "{v61.Name}"`))
								end
							end
						end

						if v57 <= 0 then
							break
						end
					end

					for k2, v60 in v58 do
						clonesByItemToKey[k2].Stack.Label.Text = `x{v60}`
						clonesByItemToKey[k2].Stack.Visible = v60 > 1
					end
				end

				return nil
			end))
			local v54 = v30
			local v55 = v45
			maid2:Add(v15.setPropertyComputed(clone, "Visible", function(callback2)
				local v56 = callback2(state3)

				if workspace:GetServerTimeNow() - v56.filterTime > v54.Time then
					return false
				end

				local v57 = callback2(v55)
				local v58 = string.lower(callback2(state4))

				if #v58 <= 0 or #v58 > 0 and v57 == nil then
					return true
				end

				local v59 = string.lower(v57)
				return v59 == v58 or string.sub(v59, 1, #v58) == v58 or string.find(v59, v58, 1, true) ~= nil
			end))
			local children = clone:GetChildren()
			table.insert(children, clone)
			local v56 = { "Image", "Position", "Size" }

			for _, v57 in children do
				local child

				if v57 == clone then
					child = templateExpanded
				else
					child = templateExpanded:FindFirstChild(v57.Name)
				end

				local child2

				if v57 == clone then
					child2 = template2
				else
					child2 = template2:FindFirstChild(v57.Name)
				end

				if child then
					for _, v58 in v56 do
						local v59 = v57
						local v60 = v58

						if not pcall(function()
							return v59[v60]
						end) then
							continue
						end

						local v61 = v30
						local v62 = child
						local v63 = v58
						local v64 = child2
						maid2:Add(v15.setPropertyComputed(v57, v58, function(callback2)
							if callback2(state6) == v61.Id then
								return v62[v63]
							end

							return v64[v63]
						end))
					end
				else
					local v58 = v30
					maid2:Add(v15.setPropertyComputed(v57, "Visible", function(callback2)
						return callback2(state6) == v58.Id
					end))
				end
			end

			clone.LayoutOrder = -v30.Time
			clone.Parent = tradeHistory.ScrollingFrame
			maid2:AttachToInstance(clone)
			local v57 = tradeState
			maid2:Add(clone.View.Activated:Connect(function()
				local v58 = v57:Get()

				if v58 then
					self:ShowTrade(v58)
				end
			end))
			local v58 = tradeState
			local v59 = v30
			maid2:Add(clone.Activated:Connect(function()
				if v58:Get() then
					local v61

					if state6:Get() ~= v59.Id then
						v61 = v59.Id
					end

					state6:Set(v61)
				end
			end))
		end

		return nil
	end)

	local function tryFetchPage(p: string)
		local v29, v30, v31 = xpcall(function()
			return v7.Remotes.GetTradeHistoryPage:InvokeServer(p)
		end, warn)

		if not v29 then
			return false, v30
		end

		if v30 and type(v31) == "table" then
			state9:Set(v3.Dictionary.set(state9:Get(), p, v31))
			return v30, v31
		end

		if not v30 then
			task.wait(10)
		end

		return v30, v31
	end

	task.spawn(function()
		while state2:Get() ~= "TradeHistory" do
			state2:Wait()
		end

		local tradeHistoryPage = v28:Get("TradeHistoryPage") or 1
		local v29 = 500

		for i = tradeHistoryPage, math.max(tradeHistoryPage - 3, 1), -1 do
			while not tryFetchPage(tostring(i)) do
				task.wait(10)
			end

			local v30 = state9:Get()[tostring(i)]
			v29 -= v3.Dictionary.count(v30 or {})

			if v29 <= 0 then
				break
			end
		end
	end)
	v7.Remotes.AddToPageHistory.OnClientEvent:Connect(function(p: string, p2)
		if not state9:Get()[p] then
			state9:Set(v3.Dictionary.set(state9:Get(), p, {}))
		end

		local clone = table.clone(state9:Get())
		table.insert(clone[p], p2)
		state9:Set(clone)
	end)
	local v29 = v15.setPropertyComputed(main.ItemSearch, "Visible", function(callback)
		return callback(state2) == "TradeItemsHistory"
	end)
	v15.setPropertyComputed(main.Currency, "Position", function(callback)
		if callback(v29) then
			return (UDim2.fromScale(0.749, 1.079))
		end

		return (UDim2.fromScale(0.5, 1.079))
	end)
	local searchBox = main.ItemSearch.SearchBox
	searchBox.FocusLost:Connect(function(flag: boolean)
		if flag then
			state5:Set(searchBox.Text)
		end
	end)
	main.ItemSearch.Search.Activated:Connect(function()
		state5:Set(searchBox.Text)
	end)

	for _, v30 in v23 do
		local clone = tradeHistory.Top.FilterPopUp.UIListLayout.Template:Clone()
		clone.Label.Text = v30.key
		clone.Parent = tradeHistory.Top.FilterPopUp
		local v31 = v30
		clone.Activated:Connect(function()
			state3:Set(v31)
			tradeHistory.Top.FilterPopUp.Visible = false
		end)
	end

	v15.setPropertyComputed(tradeHistory.Top.Filter.Label, "Text", function(callback)
		return callback(state3).key
	end)
	tradeHistory.Top.Filter.Activated:Connect(function()
		tradeHistory.Top.FilterPopUp.Visible = not tradeHistory.Top.FilterPopUp.Visible
	end)
	local searchPlayer = tradeHistory.Top.SearchPlayer
	searchPlayer.TextBox.FocusLost:Connect(function(flag: boolean)
		if flag then
			state4:Set(searchPlayer.TextBox.Text)
		end
	end)
	searchPlayer.SearchButton.Activated:Connect(function()
		state4:Set(searchPlayer.TextBox.Text)
	end)
	v7.Remotes.TradeStatus.OnClientEvent:Connect(function(flag: boolean, p: string?)
		v4:Unlock("Trade", true)
		tradeCompleted.Main.Description.Text = p or flag and "Trade Completed!" or "Trade Failed!"
		v4:Open("TradeCompleted", true)
	end)

	for childName, setting in v7.Settings do
		local child = tradeSettings.ScrollingFrame:FindFirstChild(childName)

		if not child then
			continue
		end

		local v30 = assert(child:FindFirstChild("Buttons"), (`Buttons frame not found for {childName}`))

		if setting.Type == "Option" then
			for _, childName2 in setting.Options do
				local child2 = v30:FindFirstChild(childName2)

				if not child2 then
					continue
				end

				local v31 = childName
				local v32 = childName2
				local v33 = child2
				v15.Computed(function(callback)
					local visible = callback((v15.getReplionPathState(v27, { "TradeSettings", v31 }))) == v32
					v33.Check.Visible = visible
					local uIStroke = v33.Label.UIStroke
					local color

					if visible then
						color = Color3.fromRGB(15, 106, 14)
					else
						color = Color3.fromRGB(25, 65, 168)
					end

					uIStroke.Color = color
					v33.Image = visible and "rbxassetid://18365905187" or "rbxassetid://18350075191"
					v33.HoverImage = visible and "rbxassetid://18365913217" or "rbxassetid://18350101265"
					return nil
				end)
				local v34 = childName
				local v35 = childName2
				child2.Activated:Connect(function()
					local v36, v37 = v7.Remotes.SetSetting:InvokeServer(v34, v35)

					if not v36 then
						if type(v37) == "string" then
							warn(v37)
						end

						ReplicatedStorage2.Misc.error:Play()
					end
				end)
			end
		elseif setting.Type == "Toggle" then
			local toggle = v30:WaitForChild("Toggle")
			local v31 = childName
			local v33 = v30:WaitForChild("CurrentState")
			v15.Computed(function(callback)
				local v34 = callback((v15.getReplionPathState(v27, { "TradeSettings", v31 }))) == true
				toggle.Label.Text = v34 and "Disable" or "Enable"
				local uIStroke = toggle.Label.UIStroke
				local color

				if v34 then
					color = Color3.fromRGB(25, 65, 168)
				else
					color = Color3.fromRGB(15, 106, 14)
				end

				uIStroke.Color = color
				toggle.Image = v34 and "rbxassetid://18350075191" or "rbxassetid://18365905187"
				toggle.HoverImage = v34 and "rbxassetid://18350101265" or "rbxassetid://18365913217"
				v33.Text = v34 and "Enabled" or "Disabled"
				local v36 = v33
				local textColor

				if v34 then
					textColor = Color3.fromRGB(109, 233, 26)
				else
					textColor = Color3.fromRGB(233, 26, 26)
				end

				v36.TextColor3 = textColor
				local uIStroke2 = v33.UIStroke
				local color2

				if v34 then
					color2 = Color3.fromRGB(44, 89, 63)
				else
					color2 = Color3.fromRGB(74, 29, 63)
				end

				uIStroke2.Color = color2
				return nil
			end)
			local v34 = childName
			toggle.Activated:Connect(function()
				local v35, v36 = v7.Remotes.SetSetting:InvokeServer(v34, not v27:Get({ "TradeSettings", v34 }))

				if not v35 then
					if type(v36) == "string" then
						warn(v36)
					end

					ReplicatedStorage2.Misc.error:Play()
				end
			end)
		end
	end

	pcall(function()
		StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(p)
			v7.Remotes.SetFriendState:FireServer(p, true)
		end)
	end)
	pcall(function()
		StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(function(p)
			v7.Remotes.SetFriendState:FireServer(p, false)
		end)
	end)
end

return TradeRequestController