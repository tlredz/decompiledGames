local module = require("@game/ReplicatedStorage/Omni")
local v = {
	{
		Name = "Items"
	},
	{
		Name = "Fighters",
		Unique = true
	},
	{
		Name = "Weapons",
		Unique = true
	},
	{
		Name = "Mounts",
		Unique = true
	}
}
local fusion = module.Libs.Fusion
local trade = module.Interface:WaitForChild("Frames"):WaitForChild("Trade")
local main = trade:WaitForChild("Main")
local players = main:WaitForChild("Players")
local scroll = players:WaitForChild("List"):WaitForChild("Scroll")
local trading = main:WaitForChild("Trading")
local main2 = trading:WaitForChild("Main")
local player1 = main2:WaitForChild("Player1")
local player2 = main2:WaitForChild("Player2")
local buttons = player2:WaitForChild("Buttons")
local scroll2 = trading:WaitForChild("List"):WaitForChild("Scroll")
local trade2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Trade")
local v2 = {}
local v3 = {}
local innerScopesByName = {}
local v4 = {}
local v5 = {}
local v6 = module.Libs.DataContainerClient.New("TradeInfo")
local v7 = module.Libs.DataContainerClient.New("CurrentTrade")
local v8 = module.Libs.DataContainerClient.New("RAP")

local function RequestTimestamp(p, p2: number)
	local selected = p.Requests and p.Requests[p2]

	if not module.Utils.Validator:ValidateNumber(selected) then
		return nil
	end

	local v10 = workspace:GetServerTimeNow() - selected

	if v10 < 0 or module.Shared.Trade.TradeRequestDuration <= v10 then
		return nil
	end

	return selected
end

local function IsSaving()
	return v7.Data ~= nil and v7.Data.Status == "Saving"
end

local function IsOfferable(p)
	if not module.Shared.Trade.CanOffer(p, module.Data) then
		return false
	end

	if module.Shared.Trade.IsPaidOffer(p, module.Data) then
		local monetizationPolicy = module.Shared.MonetizationPolicy.FromPlayer(module.Instance)

		if not module.Shared.MonetizationPolicy.CanTradePaidItems(monetizationPolicy) then
			return false
		end
	end

	return true
end

local function IsCategoryAvailable(p: string)
	if p == "Items" then
		return (IsOfferable({
			Type = "Items",
			ID = "Paid Gems",
			Amount = 1
		}))
	end

	if p ~= "Fighters" and p ~= "Weapons" and p ~= "Mounts" then
		return false
	end

	local v9 = module.Data[p]

	if typeof(v9) ~= "table" or typeof(v9.List) ~= "table" then
		return false
	end

	for k in v9.List do
		if IsOfferable({
			Type = p,
			ID = k
		}) then
			return true
		end
	end

	return false
end

local function GetOfferedAmount(name: string, p: string)
	local v9 = v7.Data and v7.Data.Players[module.Instance.UserId]

	if not v9 then
		return nil
	end

	for _, offer in v9.Offers do
		if offer.Type == name and offer.ID == p then
			return offer.Amount
		end
	end

	return nil
end

local function GetOfferRAP(type: string, ID: string, data, amount: number?)
	if type == "Items" then
		return module.Shared.Trade.GetGemsValue({
			Type = "Items",
			ID = ID,
			Amount = amount
		})
	end

	local v9 = {
		[type] = {
			List = {
				[ID] = data
			}
		}
	}
	local v10 = {
		Type = type,
		ID = ID
	}
	local offerKey = module.Shared.Trade.GetOfferKey(v10, v9)
	local v11 = offerKey and v8.Data and v8.Data[offerKey]

	if typeof(v11) == "number" then
		return v11
	end

	return module.Shared.Trade.GetDefaultRAP(v10, v9)
end

local Trade = {}

local function UpdateTemplates(p: number, scroll3, items, items2, flag: boolean)
	for k, item in items do
		local clone = items2[k]

		if not clone then
			clone = flag and trade2.Slot1:Clone() or trade2.Slot2:Clone()
			clone.Name = k
			clone.Main.Title.Text = item.Name

			if item.Info.Icon then
				clone.Main.Icon.Visible = true
				clone.Main.Viewport.Visible = false
				clone.Main.Icon.Image = item.Info.Icon or ""
			else
				clone.Main.Icon.Visible = false
				clone.Main.Viewport.Visible = true
				module.Utils.Camera.ViewportCharacter({
					Viewport = clone.Main.Viewport,
					Animation = module.Utils.Characters.GetCharacterAnimation(item.Name, "Idle"),
					Character = module.Utils.Characters.Get({
						Name = item.Name,
						Shiny = item.Data.Shiny,
						RemoveHumanoidStates = true
					})
				})
			end

			if flag then
				local v9 = item
				module.Button:Create(clone.RemoveButton.Main, "Small"):BindFunction("Click", function()
					local player = v7.Data.Players[p]

					if not player then
						return
					end

					local v10 = nil

					for k2, offer in player.Offers do
						if not (offer.Type == v9.Type and offer.ID == v9.ID) then
							continue
						end

						v10 = k2
						break
					end

					if not v10 then
						return
					end

					module.Signal:Fire("General", "Trade", "RemoveTradeOffer", v10)
				end)
			end

			local v9 = module.Button:Create(clone.Main, "Small")
			local v10 = item
			v9:BindFunction("Click", function()
				if not v10.Hover then
					return
				end

				local player = v7.Data.Players[p]

				if not player then
					return
				end

				local v11 = nil

				for k2, offer in player.Offers do
					if not (offer.Type == v10.Type and offer.ID == v10.ID) then
						continue
					end

					v11 = offer
					break
				end

				if not v11 then
					return
				end

				local data, v13 = module.Shared.Trade.GetData(v11, player.Data)

				if v13 or not data then
					return
				end

				local hover = v10.Hover
				local main3 = clone.Main
				local name

				if v10.Type == "Items" then
					name = v10.ID
				end

				local v14 = {
					IsFake = true,
					Data = data,
					Name = name,
					Amount = v11.Amount,
					PlayerData = 0
				}
				local playerData

				if v10.Type == "Weapons" then
					playerData = module.Data
				else
					playerData = player.Data
				end

				v14.PlayerData = playerData
				hover:Click(main3, v14)
			end)
			local v11 = item
			v9:BindOnEnter("Hover", function()
				if not v11.Hover then
					return
				end

				local player = v7.Data.Players[p]

				if not player then
					return
				end

				local v12 = nil

				for k2, offer in player.Offers do
					if not (offer.Type == v11.Type and offer.ID == v11.ID) then
						continue
					end

					v12 = offer
					break
				end

				if not v12 then
					return
				end

				local data, v14 = module.Shared.Trade.GetData(v12, player.Data)

				if v14 or not data then
					return
				end

				local hover = v11.Hover
				local main3 = clone.Main
				local name

				if v11.Type == "Items" then
					name = v11.ID
				end

				local v15 = {
					IsFake = true,
					Data = data,
					Name = name,
					Amount = v12.Amount,
					PlayerData = 0
				}
				local playerData

				if v11.Type == "Weapons" then
					playerData = module.Data
				else
					playerData = player.Data
				end

				v15.PlayerData = playerData
				hover:Open(main3, v15)
			end)
			local v12 = item
			v9:BindOnLeave("Hover", function()
				if not v12.Hover then
					return
				end

				v12.Hover:Close(clone.Main)
			end)
			clone.Parent = scroll3
			clone.Visible = true
			items2[k] = clone
		end

		clone.Main.Amount.Text = not item.Amount and "" or module.Utils.Number:Format(item.Amount) or ""
		clone.Main.RAP.Text = module.Utils.Number:Format(GetOfferRAP(item.Type, item.ID, item.Data, item.Amount))
		clone.LayoutOrder = item.Index
	end

	for k, item in items2 do
		if items[k] then
			continue
		end

		item:Destroy()
		items2[k] = nil
	end
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = trade2.Player:Clone()
		self.Instance.Name = self.UserId
		self.Instance.Main.UserName.Text = self.Info.UserName or ""
		self.Instance.Main.NickName.Text = self.Info.NickName or ""
		module.Button:Create(self.Instance.Main.Buttons.Request.Main, "Small"):BindFunction("Click", function()
			local value = v6:GetValue({ module.Instance.UserId })

			if not value then
				return
			end

			local userId = self.UserId
			local v9 = value.Requests and value.Requests[userId]

			if module.Utils.Validator:ValidateNumber(v9) then
				local v10 = workspace:GetServerTimeNow() - v9

				if v10 < 0 or module.Shared.Trade.TradeRequestDuration <= v10 then
					v9 = nil
				end
			else
				v9 = nil
			end

			local info = self.Info
			local userId2 = module.Instance.UserId
			local v10 = info.Requests and info.Requests[userId2]

			if module.Utils.Validator:ValidateNumber(v10) then
				local v11 = workspace:GetServerTimeNow() - v10

				if v11 < 0 or module.Shared.Trade.TradeRequestDuration <= v11 then
					v10 = nil
				end
			else
				v10 = nil
			end

			if v10 then
				module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
					Message = "Wait for the player to accept your request.",
					Color = Color3.fromRGB(255, 255, 0)
				})
			elseif v9 then
				module.Signal:Fire("General", "Trade", "AcceptRequest", self.UserId)
			else
				module.Signal:Fire("General", "Trade", "RequestTrade", self.UserId)
			end
		end)
		module.Button:Create(self.Instance.Main.Buttons.Block.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Trade", "BlockPlayer", self.UserId)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local value = v6:GetValue({ module.Instance.UserId })

		if not value then
			return
		end

		local v9 = self.Info.Banner and module.Shared.ProfileBanners.List[self.Info.Banner]
		local icon = v9 and v9.Icon or ""
		local trading2 = self.Info.Trading == true
		local enabled = value.Blocked[self.UserId]
		local v11 = enabled or self.Info.Blocked[module.Instance.UserId] or self.Info.RequestsAllowed == false or value.RequestsAllowed == false
		local serverTimeNow = workspace:GetServerTimeNow()
		local userId = self.UserId
		local v12 = value.Requests and value.Requests[userId]

		if module.Utils.Validator:ValidateNumber(v12) then
			local v13 = workspace:GetServerTimeNow() - v12

			if v13 < 0 or module.Shared.Trade.TradeRequestDuration <= v13 then
				v12 = nil
			end
		else
			v12 = nil
		end

		local info = self.Info
		local userId2 = module.Instance.UserId
		local v13 = info.Requests and info.Requests[userId2]

		if module.Utils.Validator:ValidateNumber(v13) then
			local v14 = workspace:GetServerTimeNow() - v13

			if v14 < 0 or module.Shared.Trade.TradeRequestDuration <= v14 then
				v13 = nil
			end
		else
			v13 = nil
		end

		self.Instance.Main.Buttons.Request.Visible = not (trading2 or v11)
		self.Instance.Main.Buttons.Blocked.Visible = v11 and not trading2
		self.Instance.Main.Buttons.Trading.Visible = trading2
		self.Instance.Main.Buttons.Block.Main.UIGradient.Enabled = enabled

		if v13 then
			local v14 = module.Shared.Trade.TradeRequestDuration - math.floor(serverTimeNow - v13)
			self.Instance.Main.Buttons.Request.Main.Title.Text = `Wait ({v14}s)`
		elseif v12 then
			local v14 = module.Shared.Trade.TradeRequestDuration - math.floor(serverTimeNow - v12)
			self.Instance.Main.Buttons.Request.Main.Title.Text = `Accept ({v14}s)`
		else
			self.Instance.Main.Buttons.Request.Main.Title.Text = "Request"
		end

		self.Instance.Main.Banner.Image = icon
		self.Instance.Main.Icon.Main.Image = self.Info.Icon or ""
	end
})
local scope2 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = trade2.Selector:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			local v9 = module.Signal:InvokeSelf("Interface", "Inventory", "GetController")

			if v9 then
				local name = self.Name
				local info = self.Info
				v9.SetMode("Selection", {
					Category = name,
					PastUI = trade,
					NeededProperties = {
						Tradeable = true
					},
					IsCategoryAvailable = IsCategoryAvailable,
					Callback = function(ID: string)
						if info.Unique then
							module.Signal:Fire("General", "Trade", "AddTradeOffer", {
								Type = name,
								ID = ID
							})
							v9.CloseInterface()
						else
							local v10 = module.Shared.Gems.Read(module.Data)
							local maximum = not v10 and 0 or math.floor(v10.Paid)

							if ID == "Paid Gems" and not (maximum < 1) then
								module.Signal:FireSelf("Interface", "AmountSelector", "Start", {
									Minimum = 1,
									Maximum = maximum,
									Start = GetOfferedAmount(name, ID),
									Callback = function(amount: number)
										module.Signal:Fire("General", "Trade", "AddTradeOffer", {
											Type = name,
											ID = ID,
											Amount = amount
										})
										v9.CloseInterface()
									end
								})
							else
								module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
									Message = "Only Paid Gems can be offered from Items.",
									Color = Color3.fromRGB(255, 255, 0)
								})
							end
						end
					end
				})
				v9.LockMode()
			end
		end)
		self.Instance.Parent = scroll2
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		return true
	end
})

function Trade.ClearPlayers()
	for _, v9 in v3 do
		v9.Instance:Destroy()
		v9:doCleanup()
	end

	table.clear(v3)
end

function Trade.ClearSelectors()
	for _, v9 in innerScopesByName do
		v9.Instance:Destroy()
		v9:doCleanup()
	end

	table.clear(innerScopesByName)
end

function Trade.ClearOffers()
	for _, v9 in v4 do
		v9:Destroy()
	end

	for _, v9 in v5 do
		v9:Destroy()
	end

	table.clear(v4)
	table.clear(v5)
end

function Trade.ClearAll()
	Trade.ClearPlayers()
	Trade.ClearSelectors()
	Trade.ClearOffers()
end

function Trade.UpdatePlayers()
	if not v6.Data then
		return
	end

	if next(innerScopesByName) then
		Trade.ClearSelectors()
	end

	if not v7.Ready and (next(v4) or next(v5)) then
		Trade.ClearOffers()
	end

	local text = string.lower(players.Search.Text)
	local total = 0

	for k, info in v6.Data do
		if k == module.Instance.UserId then
			continue
		end

		local visible = string.find(string.lower(info.UserName or ""), text, 1, true) ~= nil or string.find(
			string.lower(info.NickName or ""),
			text,
			1,
			true
		) ~= nil
		local v11 = v3[k]

		if v11 or not visible then
			if v11 then
				v11.Instance.Visible = visible

				if visible then
					v11.Info = info
					v11:Update()
				end
			end
		else
			local innerScope = scope:innerScope()
			innerScope.UserId = k
			innerScope.Info = info
			v3[k] = innerScope
			local success, result = pcall(innerScope.Build, innerScope, total)

			if success and result then
				total += 0.05
			else
				if innerScope.Instance then
					innerScope.Instance:Destroy()
				end

				innerScope:doCleanup()
				v3[k] = nil

				if not success then
					warn((`[TRADE]: Player card unavailable: {result}`))
				end
			end
		end
	end

	for k, v9 in v3 do
		if v6.Data[k] then
			continue
		end

		v9.Instance:Destroy()
		v9:doCleanup()
		v3[k] = nil
	end
end

function Trade.UpdateTrading()
	if not (v7.Ready and v7.Data) then
		return
	end

	if next(v3) then
		Trade.ClearPlayers()
	end

	for k, info in v do
		local name = info.Name

		if innerScopesByName[name] then
			continue
		end

		local innerScope = scope2:innerScope()
		innerScope.Name = name
		innerScope.Info = info

		if innerScope:Build((k - 1) * 0.05) then
			innerScopesByName[name] = innerScope
		else
			innerScope:doCleanup()
		end
	end

	local v9 = nil
	local v10 = nil

	for k in v7.Data.Players do
		if k == module.Instance.UserId then
			v9 = k
		else
			v10 = k
		end
	end

	if not (v9 and v10) then
		return
	end

	local player = v7.Data.Players[v9]

	if not player then
		return
	end

	local player3 = v7.Data.Players[v10]

	if not player3 then
		return
	end

	local v11 = v6.Data[v9]

	if v11 then
		local v12 = v11.Banner and module.Shared.ProfileBanners.List[v11.Banner]
		local icon = v12 and v12.Icon or ""
		player1.Info.UserName.Text = v11.UserName or ""
		player1.Info.NickName.Text = v11.NickName or ""
		player1.Info.Banner.Image = icon
		player1.Info.Icon.Main.Image = v11.Icon or ""
	end

	local v12 = v6.Data[v10]

	if v12 then
		local v13 = v12.Banner and module.Shared.ProfileBanners.List[v12.Banner]
		local icon = v13 and v13.Icon or ""
		player2.Info.UserName.Text = v12.UserName or ""
		player2.Info.NickName.Text = v12.NickName or ""
		player2.Info.Banner.Image = icon
		player2.Info.Icon.Main.Image = v12.Icon or ""
	end

	player1.Quad.RAP.Text = module.Utils.Number:Format(player.OfferValue or 0) .. " RAP"
	player2.Quad.RAP.Text = module.Utils.Number:Format(player3.OfferValue or 0) .. " RAP"
	local fairness = v7.Data.Fairness
	local v13

	if fairness == nil or fairness.Active ~= true then
		v13 = false
	else
		v13 = fairness.Acknowledged ~= true
	end

	local v14

	if v7.Data == nil then
		v14 = false
	else
		v14 = v7.Data.Status == "Saving"
	end

	buttons.Ready.Visible = not v14 and v13
	buttons.Accept.Visible = v14 or not v13
	buttons.Decline.Visible = not v14

	if v14 then
		main2.Indicator.Text = "Saving..."
		buttons.Accept.Main.Title.Text = "Saving..."
	elseif v13 then
		local serverTimeNow = workspace:GetServerTimeNow()
		local v15 = fairness.Order[fairness.Progress + 1] == module.Instance.UserId
		local v16 = math.ceil(fairness.NextEligibleAt - serverTimeNow)
		main2.Indicator.Text = "Unfair Trade!"
		buttons.Decline.Main.Title.Text = "Decline"

		if v15 then
			if v16 > 0 then
				buttons.Ready.Main.Title.Text = `Ready ({v16}s)`
			else
				buttons.Ready.Main.Title.Text = "Ready"
			end
		else
			buttons.Ready.Main.Title.Text = "Waiting..."
		end
	elseif v7.Data.Status == "Waiting" then
		main2.Indicator.Text = "..."
		buttons.Accept.Main.Title.Text = player.Accepted == true and "..." or "Accept"
		buttons.Decline.Main.Title.Text = player.Accepted == true and "Back" or "Decline"
		player1.Status.Title.Text = "Accepted"
		player2.Status.Title.Text = "Accepted"
		player1.Status.Visible = player.Accepted == true
		player2.Status.Visible = player3.Accepted == true
	elseif v7.Data.Status == "Accepting" then
		local serverTimeNow = workspace:GetServerTimeNow()
		local v15 = serverTimeNow - (v7.Data.AcceptTime or serverTimeNow)
		local v16 = math.floor(module.Shared.Trade.TradeAcceptDuration - v15)

		if v16 > 0 then
			buttons.Accept.Main.Title.Text = "..."
			buttons.Decline.Main.Title.Text = "Back"
			main2.Indicator.Text = v16 .. "s"
			player1.Status.Title.Text = "Accepted"
			player2.Status.Title.Text = "Accepted"
			player1.Status.Visible = player.Accepted == true
			player2.Status.Visible = player3.Accepted == true
		else
			buttons.Accept.Main.Title.Text = player.Confirmed == true and "..." or "Confirm"
			buttons.Decline.Main.Title.Text = "Back"
			main2.Indicator.Text = "Confirm"
			player1.Status.Title.Text = "Confirmed"
			player2.Status.Title.Text = "Confirmed"
			player1.Status.Visible = player.Confirmed == true
			player2.Status.Visible = player3.Confirmed == true
		end
	end

	local v15 = {}
	local v16 = {}

	for k, offer in player.Offers do
		local v17 = offer.Type .. offer.ID
		local data, v18 = module.Shared.Trade.GetData(offer, player.Data)

		if v18 or not data then
			continue
		end

		local name = typeof(data) == "table" and data.Name or offer.ID
		local info = module.Utils.Info:Get(offer.Type, name)

		if info then
			v15[v17] = {
				ID = offer.ID,
				Type = offer.Type,
				Name = name,
				Index = k,
				Info = info,
				Hover = module.Libs.NeoHover.GetByPseudoIdentifier(offer.Type),
				Data = data,
				Amount = offer.Amount
			}
		end
	end

	for k, offer in player3.Offers do
		local v17 = offer.Type .. offer.ID
		local data, v18 = module.Shared.Trade.GetData(offer, player3.Data)

		if v18 or not data then
			continue
		end

		local name = typeof(data) == "table" and data.Name or offer.ID
		local info = module.Utils.Info:Get(offer.Type, name)

		if info then
			v16[v17] = {
				ID = offer.ID,
				Type = offer.Type,
				Name = name,
				Index = k,
				Info = info,
				Hover = module.Libs.NeoHover.GetByPseudoIdentifier(offer.Type),
				Data = data,
				Amount = offer.Amount
			}
		end
	end

	UpdateTemplates(v9, player1.Quad.List.Scroll, v15, v4, true)
	UpdateTemplates(v10, player2.Quad.List.Scroll, v16, v5, false)
end

function Trade.Update()
	local v9 = v7.Ready and "Trading" or "Players"

	for _, frame in main:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = frame.Name == v9
		end
	end

	local v10 = Trade[`Update{v9}`]

	if v10 then
		v10()
	end
end

function Trade.Stop()
	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
	Trade.ClearAll()
end

function Trade.Start()
	Trade.Stop()
	v2.TradeInfo = v6:OnChange({}, Trade.Update)
	v2.CurrentTrade = v7:OnChange({}, Trade.UpdateTrading)
	v2.Search = players.Search:GetPropertyChangedSignal("Text"):Connect(Trade.UpdatePlayers)
	v2.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = Trade.Update
	})
end

function Trade.Init()
	module.Button:Create(buttons.Accept.Main, "Small"):BindFunction("Click", function()
		local v9

		if v7.Data == nil then
			v9 = false
		else
			v9 = v7.Data.Status == "Saving"
		end

		if v9 then
			return
		end

		module.Signal:Fire("General", "Trade", "AcceptTrade")
	end)
	module.Button:Create(buttons.Ready.Main, "Small"):BindFunction("Click", function()
		local v9

		if v7.Data == nil then
			v9 = false
		else
			v9 = v7.Data.Status == "Saving"
		end

		if v9 then
			return
		end

		module.Signal:Fire("General", "Trade", "ReadyFairness")
	end)
	module.Button:Create(buttons.Decline.Main, "Small"):BindFunction("Click", function()
		local v9

		if v7.Data == nil then
			v9 = false
		else
			v9 = v7.Data.Status == "Saving"
		end

		if v9 then
			return
		end

		module.Signal:Fire("General", "Trade", "DeclineTrade")
	end)
	v7:OnReady(function()
		module.Frame:Open(trade)
	end)
	module.Frame:OnFrameClosed(trade, Trade.Stop)
	module.Frame:OnFrameOpened(trade, Trade.Start)
end

return Trade