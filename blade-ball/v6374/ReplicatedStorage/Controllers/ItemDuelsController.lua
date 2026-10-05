local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
local v8 = require3(ReplicatedStorage2.Shared.Inventory)
local v9 = require3(ReplicatedStorage2.Shared.Statable)
local v10 = require3(ReplicatedStorage2.Common.Utils)
local v11 = require3(ReplicatedStorage2.Controllers.PromptController)
local v12 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local remoteEvent = v:RemoteEvent("ItemDuelsSendInvite")
local remoteEvent2 = v:RemoteEvent("ItemDuelsSelectItem")
local remoteEvent3 = v:RemoteEvent("ItemDuelsReady")
local remoteEvent4 = v:RemoteEvent("ItemDuelsAccept")
local remoteEvent5 = v:RemoteEvent("ItemDuelsCancel")
local remoteEvent6 = v:RemoteEvent("ItemDuelsReconnectPrompt")
local remoteEvent7 = v:RemoteEvent("ItemDuelsReconnectResponse")
local localPlayer = Players.LocalPlayer
local duelFrames = localPlayer.PlayerGui:WaitForChild("DuelFrames")
local playerlist = duelFrames:WaitForChild("Playerlist")
local tradeView = duelFrames:WaitForChild("TradeView")
local editView = duelFrames:WaitForChild("EditView")
local scrollingFrame = playerlist:WaitForChild("ScrollingFrame")
local template = scrollingFrame:WaitForChild("Template")
local ready = tradeView:WaitForChild("Ready")
local cancel = tradeView:WaitForChild("Cancel")
local edit = tradeView:WaitForChild("Edit")
local player1Offer = tradeView:WaitForChild("Player1Offer")
local player2Offer = tradeView:WaitForChild("Player2Offer")
local playerInformation = tradeView:WaitForChild("PlayerInformation")
local timer = tradeView:WaitForChild("Timer")
local close = editView:WaitForChild("Close")
local top = editView:WaitForChild("Top")
local itemsList = editView:WaitForChild("SidePanel"):WaitForChild("ItemsList")
local itemSearch = editView:FindFirstChild("ItemSearch")
local template2 = itemsList:WaitForChild("UIGridLayout"):WaitForChild("Template")
local player2Offer2 = editView:FindFirstChild("Player2Offer")
local playerInformation2 = editView:FindFirstChild("PlayerInformation")
local v13 = nil
local v14 = "None"
local v15 = nil
local userId = nil

local function setView(p: string)
	v14 = p
	playerlist.Visible = p == "Playerlist"
	tradeView.Visible = p == "TradeView"
	editView.Visible = p == "EditView"
end

local function setPlayerDisplay(instance, p)
	if not p then
		return
	end

	local username = instance:FindFirstChild("Username")

	if username and username:IsA("TextLabel") then
		username.Text = `@{p.Name}`
	end

	local playerImage = instance:FindFirstChild("PlayerImage")
	local ID = playerImage and playerImage:FindFirstChild("ID")

	if playerImage then
		ID.Image = `rbxthumb://type=AvatarHeadShot&id={p.UserId}&w=150&h=150`
	end
end

local function createButton(p, p2: string, p3: string)
	local state = v9.State(p2)
	local state2 = v9.State(p3)
	v9.Computed(function(callback)
		local v16 = callback(state)
		local text = callback(state2)
		p.Label.Text = text

		if v16 == "Green" then
			p.Active = true
			p.Image = "rbxassetid://18123799353"
			p.HoverImage = "rbxassetid://18123825435"
			p.Label.UIStroke.Color = Color3.fromRGB(1, 86, 0)
		elseif v16 == "Red" then
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
	return state, state2
end

local activatedConnection = nil
local v16 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function watchOfferFrame(instance, state)
	v9.Computed(function(callback)
		local v17 = callback(state)
		local itemImage = instance.ItemImage
		local itemTitle = instance.ItemTitle
		local itemValue = instance.ItemValue
		local inspect = instance:FindFirstChild("Inspect")

		if v17 then
			instance.ItemGlow.Visible = true

			if inspect then
				v16 = nil

				if activatedConnection then
					activatedConnection:Disconnect()
					activatedConnection = nil
				end

				if v12:CanPreview(v17) then
					inspect.Visible = true
					activatedConnection = instance.Inspect.Activated:Connect(function()
						local thread = coroutine.running()
						v16 = thread
						duelFrames.Enabled = false
						v12:Preview(v17.Type, {
							Name = v17.Name
						}, nil, function()
							task.delay(0, function()
								if v16 == thread then
									v4:Lock("ItemDuels", true)
									duelFrames.Enabled = true
									v14 = "TradeView"
									playerlist.Visible = false
									tradeView.Visible = true
									editView.Visible = false
								end
							end)
						end)
					end)
				else
					inspect.Visible = false
				end
			end

			local v18 = v5[v17.Type] and v5[v17.Type][v17.Name]

			if itemImage then
				itemImage.Image = not v18 and "" or v18.Icon or ""
				itemImage.Visible = true
			end

			if itemTitle then
				itemTitle.Text = v18 and v18.DisplayName or v17.Name
				itemTitle.Visible = true
			end

			if itemValue then
				itemValue.Visible = true
				local banner = itemValue:FindFirstChild("Banner")
				local textLabel = banner and banner:FindFirstChild("TextLabel")

				if textLabel then
					local v19 = {
						Name = v17.Name
					}
					local filteredItemKey = v6:GetFilteredItemKey(v17.Type, v19)
					local fastGetRAP = v6:FastGetRAP(v17.Type, v19, filteredItemKey)
					textLabel:SetAttribute("Item", filteredItemKey)
					textLabel.Text = not fastGetRAP and "---" or v10.ValueConvertor:ShrinkNumber(fastGetRAP) or "---"

					if not fastGetRAP then
						task.spawn(function()
							local fastGetRAPAsync = v6:FastGetRAPAsync(v17.Type, v19, filteredItemKey)

							if textLabel and textLabel:GetAttribute("Item") == filteredItemKey then
								textLabel.Text = fastGetRAPAsync and v10.ValueConvertor:ShrinkNumber(fastGetRAPAsync) or "---"
							end
						end)
					end
				end
			end
		else
			if inspect then
				v16 = nil
				inspect.Visible = false

				if activatedConnection then
					activatedConnection:Disconnect()
					activatedConnection = nil
				end
			end

			if itemImage then
				itemImage.Image = ""
				itemImage.Visible = false
			end

			if itemTitle then
				itemTitle.Text = ""
				itemTitle.Visible = false
			end

			if itemValue then
				itemValue.Visible = false
			end

			instance.ItemGlow.Visible = false
		end

		return nil
	end)
end

return {
	Start = function(_)
		template.Visible = false
		template2.Visible = false
		local state = v9.State("Sword")
		local state2 = v9.State("")
		local v17 = nil
		local state3 = v9.State(nil)
		local state4 = v9.State(nil)
		local state5 = v9.State("Default")
		local state6 = v9.State("Most")
		local v18 = ready
		local state7 = v9.State("Green")
		local state8 = v9.State("Ready")
		v9.Computed(function(callback)
			local v19 = callback(state7)
			local text = callback(state8)
			v18.Label.Text = text

			if v19 == "Green" then
				v18.Active = true
				v18.Image = "rbxassetid://18123799353"
				v18.HoverImage = "rbxassetid://18123825435"
				v18.Label.UIStroke.Color = Color3.fromRGB(1, 86, 0)
			elseif v19 == "Red" then
				v18.Active = true
				v18.Image = "rbxassetid://18123810348"
				v18.HoverImage = "rbxassetid://18123830153"
				v18.Label.UIStroke.Color = Color3.fromRGB(86, 0, 0)
			else
				v18.Active = false
				v18.Image = "rbxassetid://18526787517"
				v18.HoverImage = "rbxassetid://18526787649"
				v18.Label.UIStroke.Color = Color3.fromRGB(41, 41, 41)
			end

			return nil
		end)
		local v19 = cancel
		local state9 = v9.State("Red")
		local state10 = v9.State("Cancel")
		v9.Computed(function(callback)
			local v20 = callback(state9)
			local text = callback(state10)
			v19.Label.Text = text

			if v20 == "Green" then
				v19.Active = true
				v19.Image = "rbxassetid://18123799353"
				v19.HoverImage = "rbxassetid://18123825435"
				v19.Label.UIStroke.Color = Color3.fromRGB(1, 86, 0)
			elseif v20 == "Red" then
				v19.Active = true
				v19.Image = "rbxassetid://18123810348"
				v19.HoverImage = "rbxassetid://18123830153"
				v19.Label.UIStroke.Color = Color3.fromRGB(86, 0, 0)
			else
				v19.Active = false
				v19.Image = "rbxassetid://18526787517"
				v19.HoverImage = "rbxassetid://18526787649"
				v19.Label.UIStroke.Color = Color3.fromRGB(41, 41, 41)
			end

			return nil
		end)
		watchOfferFrame(player1Offer, state3) -- equivalent call inferred; original call site unknown
		watchOfferFrame(player2Offer, state4) -- equivalent call inferred; original call site unknown
		watchOfferFrame(player2Offer2, state4) -- equivalent call inferred; original call site unknown
		local warningTemplate = duelFrames.WarningTemplate
		local v23 = nil
		local clone = warningTemplate:Clone()
		clone.Name = "UnfairDuelWarning"
		clone.Visible = false
		clone.Title.Text = "Unfair Offer!"
		clone.Description1.Text = "The RAP of the item you're wagering is higher than your opponent's by:"
		clone.Parent = duelFrames
		local clone2 = warningTemplate:Clone()
		clone2.Name = "HighValueWarning"
		clone2.Visible = false
		clone2.Title.Text = "High Value Item!"
		clone2.Description1.Text = "You are about to wager an item worth more than 50,000 RAP:"
		clone2.Parent = duelFrames

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showUnfairDuelWarning(p: number, p2: number)
			if not clone then
				return false
			end

			clone.Amount.Amount.Text = v10.ValueConvertor:AddCommas(p - p2)
			clone.Visible = true
			tradeView.Visible = false
			return true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideUnfairDuelWarning()
			if not clone then
				return
			end

			clone.Visible = false

			if v14 == "TradeView" then
				tradeView.Visible = true
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showHighValueWarning(p: number, selectItem)
			if not clone2 then
				selectItem()
				return
			end

			v23 = selectItem
			clone2.Amount.Amount.Text = v10.ValueConvertor:AddCommas(p)
			clone2.Visible = true
			editView.Visible = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideHighValueWarning()
			if not clone2 then
				return
			end

			clone2.Visible = false
			v23 = nil

			if v14 == "EditView" then
				editView.Visible = true
			end
		end

		clone.Close.Activated:Connect(hideUnfairDuelWarning)
		clone.Buttons.No.Activated:Connect(hideUnfairDuelWarning)
		clone.Buttons.Yes.Activated:Connect(function()
			hideUnfairDuelWarning() -- equivalent call inferred; original call site unknown
			remoteEvent3:FireServer()
		end)
		clone2.Close.Activated:Connect(hideHighValueWarning)
		clone2.Buttons.No.Activated:Connect(hideHighValueWarning)
		clone2.Buttons.Yes.Activated:Connect(function()
			local v24 = v23
			hideHighValueWarning() -- equivalent call inferred; original call site unknown

			if v24 then
				v24()
			end
		end)

		local function openEditView()
			if v17 then
				v17:Destroy()
			end

			local maid = v3.new()
			v17 = maid
			maid:Add(v7:CreateTabOptions(top, state, state2))
			maid:Add(v7:CreateSearchBox(itemSearch, state2))
			maid:Add(v7:CreateSortOptions(itemSearch.Sort, state5, state6, {
				"Default",
				"Alphabetical",
				"RAP",
				"Creation Date",
				"Exists"
			}))
			local player2Name = playerInformation2 and playerInformation2:FindFirstChild("Player2Name")

			if player2Name then
				setPlayerDisplay(player2Name, v15)
				local username = player2Name:FindFirstChild("Username")

				if username and v15 then
					username.Text = `@{v15.Name}'s Offer`
				end
			end

			for _, inventoryType in { "Sword", "Explosion", "Emote" } do
				local v25 = inventoryType
				local v26 = inventoryType
				maid:Add(v7:CreateInventory({
					ItemTemplate = template2,
					Container = itemsList,
					InventoryType = inventoryType,
					SearchFilter = state2,
					SortOption = state5,
					SortOrder = state6,
					PageVisible = v9.Computed(function(callback)
						return callback(state) == v25
					end),
					AllowedIcons = { "Stack", "Lock" },
					GetVisibleState = function(_, p)
						if p.TradeLock then
							return v9.State(false)
						end

						return v9.State(true)
					end,
					OnSlotCreated = function(p, p2, p3, p4, maid2)
						maid2:Add(p4.ActivationButton.Activated:Connect(function()
							local v27 = v8.Client:FindItemsWithKey(v26, p3)[1]

							if not v27 then
								return
							end

							-- equivalent calls inferred from this helper; original call sites unknown
							local function selectItem()
								remoteEvent2:FireServer(p, v27)

								if v13 then
									v14 = "TradeView"
									playerlist.Visible = false
									tradeView.Visible = true
									editView.Visible = false
								end
							end

							local v28 = v6:FastGetRAP(v26, p2, (v6:GetFilteredItemKey(v26, p2))) or 0

							if v28 > 50000 then
								showHighValueWarning(v28, selectItem) -- equivalent call inferred; original call site unknown
							else
								selectItem() -- equivalent call inferred; original call site unknown
							end
						end))
					end
				}))
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeEditView()
			if v17 then
				v17:Destroy()
				v17 = nil
			end
		end

		v4:OnGuiOpen("DuelFrames", function()
			v14 = "Playerlist"
			playerlist.Visible = true
			tradeView.Visible = false
			editView.Visible = false
		end)
		v4:OnGuiClose("DuelFrames", function()
			if v14 == "Playerlist" then
				v14 = "None"
				playerlist.Visible = false
				tradeView.Visible = false
				editView.Visible = false
			end
		end)

		local function onPlayerAdded(player)
			if player == localPlayer then
				return
			end

			local clone3 = template:Clone()
			clone3.Name = player.UserId
			clone3.Visible = true
			local textLabel = clone3:FindFirstChild("TextLabel")

			if textLabel then
				textLabel.Text = player.DisplayName
			end

			local playerName = clone3:FindFirstChild("PlayerName")

			if playerName then
				playerName.Text = `@{player.Name}`
			end

			clone3.PlayerImage.ID.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`

			local function watchAttribute(p, attributeName, defaultFormatter)
				local attribute = player:GetAttribute(attributeName)
				p.Frame.TextLabel.Text = defaultFormatter(attribute)
				player:GetAttributeChangedSignal(attributeName):Connect(function()
					local attribute2 = player:GetAttribute(attributeName)
					p.Frame.TextLabel.Text = defaultFormatter(attribute2)
				end)
			end

			local function defaultFormatter(p)
				return p and v10.ValueConvertor:ShrinkNumber(p) or "---"
			end

			watchAttribute(clone3.Stats.RAP, "TotalRAP", defaultFormatter)
			watchAttribute(clone3.Stats.Kills, "PlayerElims", defaultFormatter)
			watchAttribute(clone3.Stats.Wins, "PlayerWins", defaultFormatter)
			local invite = clone3:FindFirstChild("Invite")

			if invite and invite:IsA("ImageButton") then
				invite.Visible = true
				local invite2 = invite:FindFirstChild("Invite")

				if invite2 then
					invite2.Visible = false
				end

				local inviteSent = invite:FindFirstChild("InviteSent")

				if inviteSent then
					inviteSent.Visible = false
				end

				local inRound = invite:FindFirstChild("InRound")

				if inRound then
					inRound.Visible = false
				end

				invite2.Visible = true
				invite.Activated:Connect(function()
					if inviteSent.Visible then
						return
					end

					remoteEvent:FireServer(player)

					if inviteSent then
						inviteSent.Visible = true
						task.delay(3, function()
							if inviteSent and inviteSent.Parent then
								inviteSent.Visible = false
							end
						end)
					end
				end)
			end

			clone3.Parent = scrollingFrame
		end

		Players.PlayerAdded:Connect(onPlayerAdded)
		Players.PlayerRemoving:Connect(function(player)
			local child = scrollingFrame:FindFirstChild(player.UserId)

			if child then
				child:Destroy()
			end
		end)

		for _, v24 in Players:GetPlayers() do
			task.spawn(onPlayerAdded, v24)
		end

		v2.Client:OnReplionAddedWithTag("ItemDuels", function(object)
			if v13 then
				return
			end

			v13 = object
			v4:CloseCurrent(true)
			v4:Lock("ItemDuels", true)
			duelFrames.Enabled = true
			v14 = "TradeView"
			playerlist.Visible = false
			tradeView.Visible = true
			editView.Visible = false
			local userId2 = tostring(localPlayer.UserId)
			local players = object:Get("Players")

			if players then
				for _, player in players do
					if player == localPlayer then
						continue
					end

					v15 = player
					userId = tostring(player.UserId)
				end
			end

			local player1Name = playerInformation:FindFirstChild("Player1Name")

			if player1Name then
				setPlayerDisplay(player1Name, localPlayer)
			end

			local player2Name = playerInformation:FindFirstChild("Player2Name")

			if player2Name then
				setPlayerDisplay(player2Name, v15)
			end

			local function updateState()
				state3:Set((object:Get({ userId2, "Item" })))

				if userId then
					state4:Set((object:Get({ userId, "Item" })))
				end

				local v25 = object:Get({ userId2, "Ready" })
				local v26 = object:Get({ userId2, "Accepted" })
				local processing = object:Get("Processing")
				local v27 = true

				for _, v29 in object:Get("Players"), nil, nil do
					local v30 = object:Get({ (tostring(v29.UserId)) })

					if v30 and v30.Item then
						continue
					end

					v27 = false
					break
				end

				local v29, v30

				if userId then
					v29 = object:Get({ userId, "Ready" }) or false
					v30 = object:Get({ userId, "Accepted" }) or false
				else
					v29 = false
					v30 = false
				end

				local v31 = v25 and v29
				edit.Visible = not v31

				if v31 and v14 == "EditView" then
					closeEditView() -- equivalent call inferred; original call site unknown
					v14 = "TradeView"
					playerlist.Visible = false
					tradeView.Visible = true
					editView.Visible = false
				end

				local confirmedOffer = player1Offer:FindFirstChild("ConfirmedOffer")

				if confirmedOffer then
					if v26 then
						confirmedOffer.Visible = true
						confirmedOffer.ItemTitle.Text = "Accepted!"
					elseif v25 and not v31 then
						confirmedOffer.Visible = true
						confirmedOffer.ItemTitle.Text = "Ready!"
					else
						confirmedOffer.Visible = false
					end
				end

				local confirmedOffer2 = player2Offer:FindFirstChild("ConfirmedOffer")

				if confirmedOffer2 then
					if v30 then
						confirmedOffer2.Visible = true
						confirmedOffer2.ItemTitle.Text = "Accepted!"
					elseif v29 and not v31 then
						confirmedOffer2.Visible = true
						confirmedOffer2.ItemTitle.Text = "Ready!"
					else
						confirmedOffer2.Visible = false
					end
				end

				local lastChange = object:Get("LastChange") or 0
				local v32 = workspace:GetServerTimeNow() - lastChange < 5

				if processing then
					state7:Set("Disabled")
					state8:Set("Processing...")
					state9:Set("Disabled")
				else
					if v31 and not v26 then
						state7:Set(v27 and "Green" or "Disabled")
						state8:Set("Accept")
					elseif v25 then
						state7:Set("Disabled")
						state8:Set(v26 and "Accept" or "Ready")
					else
						state7:Set(v27 and "Green" or "Disabled")
						state8:Set("Ready")
					end

					state9:Set("Red")
				end

				if v32 then
					state7:Set("Disabled")
				end
			end

			updateState()
			object:OnDataChange(function()
				if v13 ~= object then
					return
				end

				updateState()
			end)
			local heartbeatConnection = nil
			local v24 = false
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if v13 == object then
					local lastChange = object:Get("LastChange") or 0
					local v25 = math.max(0, 5 - (workspace:GetServerTimeNow() - lastChange))

					if timer and timer:IsA("TextLabel") then
						if v25 > 0 then
							timer.Text = `⌛{math.ceil(v25 * 10) / 10}s`
							timer.Visible = true
						else
							timer.Visible = false
						end
					end

					local v26 = v25 > 0

					if v24 ~= v26 then
						v24 = v26
						task.spawn(updateState)
					end
				elseif heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
		end)
		v2.Client:OnReplionRemovedWithTag("ItemDuels", function(p)
			if p ~= v13 then
				return
			end

			v13 = nil
			v15 = nil
			userId = nil
			state3:Set(nil)
			state4:Set(nil)
			hideUnfairDuelWarning() -- equivalent call inferred; original call site unknown
			hideHighValueWarning() -- equivalent call inferred; original call site unknown
			closeEditView() -- equivalent call inferred; original call site unknown
			state7:Set("Green")
			state8:Set("Ready")
			state9:Set("Red")
			state10:Set("Cancel")
			v4:Unlock("ItemDuels", true)
			duelFrames.Enabled = false
			v14 = "None"
			playerlist.Visible = false
			tradeView.Visible = false
			editView.Visible = false
		end)
		ready.Activated:Connect(function()
			if not v13 then
				return
			end

			local v24 = v13
			local userId2 = tostring(localPlayer.UserId)
			local v25 = v24:Get({ userId2, "Ready" })

			if v24:Get({ userId2, "Accepted" }) then
				return
			end

			local players = v24:Get("Players")
			local v26 = true

			if players then
				for _, player in players do
					if v24:Get({ tostring(player.UserId), "Ready" }) then
						continue
					end

					v26 = false
					break
				end
			end

			if v26 and v25 then
				remoteEvent4:FireServer()
				return
			end

			if v25 then
				remoteEvent3:FireServer()
				return
			end

			local v27 = state3:Get()
			local v28

			if v27 then
				local v29 = {
					Name = v27.Name
				}
				v28 = v6:FastGetRAP(v27.Type, v29, v6:GetFilteredItemKey(v27.Type, v29)) or 0
			else
				v28 = 0
			end

			local v29 = state4:Get()
			local v30

			if v29 then
				local v31 = {
					Name = v29.Name
				}
				v30 = v6:FastGetRAP(v29.Type, v31, v6:GetFilteredItemKey(v29.Type, v31)) or 0
			else
				v30 = 0
			end

			local timeoutFFlag = v10.FFlag.TimeoutFFlag("UnfairTradeWarningPercent", 5, 50)

			if v28 > 0 and v30 > 0 and v30 / v28 <= timeoutFFlag / 100 then
				-- equivalent call inferred; original call site unknown
				if showUnfairDuelWarning(v28, v30) then
					return
				end
			end

			remoteEvent3:FireServer()
		end)
		cancel.Activated:Connect(function()
			remoteEvent5:FireServer()
		end)
		edit.Activated:Connect(function()
			if not v13 then
				return
			end

			v14 = "EditView"
			playerlist.Visible = false
			tradeView.Visible = false
			editView.Visible = true
			openEditView()
		end)
		close.Activated:Connect(function()
			closeEditView() -- equivalent call inferred; original call site unknown
			v14 = "TradeView"
			playerlist.Visible = false
			tradeView.Visible = true
			editView.Visible = false
		end)
		tradeView.Close.Activated:Connect(function()
			remoteEvent5:FireServer()
		end)
		playerlist.Close.Activated:Connect(function()
			if v13 then
				remoteEvent5:FireServer()
				return
			end

			v4:Unlock("ItemDuels", true)
			v4:Close("DuelFrames", true)
		end)
		remoteEvent6.OnClientEvent:Connect(function()
			v11:CreatePrompt({
				PromptType = "Accept",
				Description = [[
You disconnected from an Item Duel that is still in progress.
Would you like to rejoin the match?]],
				Title = "Item Duel In Progress",
				AcceptButtonText = "Rejoin",
				DeclineButtonText = "Decline"
			}, function(flag: boolean)
				remoteEvent7:FireServer(flag)
			end)
		end)
	end
}