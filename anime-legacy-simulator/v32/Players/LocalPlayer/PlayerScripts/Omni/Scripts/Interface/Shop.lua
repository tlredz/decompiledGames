local module = require("@game/ReplicatedStorage/Omni")
local View = require(script.View)
local shop = module.Interface.Frames.Shop
local scroll = shop.List.Scroll
local scroll2 = shop.Options.Scroll
local shop2 = module.Assets.Interface.Templates.Shop
local v = { "Bundles", "Gamepasses", "Gem Packs" }
local v2 = {}
local cardsByName = {}
local clones = {}
local v3 = {}
local flag = false
local count = 0
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local flag2 = false
local count2 = 0
local flag3 = false
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = {}
local v12 = false
local v13 = 0
local Shop = {}

local function Invoke(...)
	local thread = coroutine.running()
	local v14 = table.pack(...)
	local flag4 = false
	task.spawn(function()
		local v15 = table.pack(pcall(module.Signal.Invoke, module.Signal, table.unpack(v14, 1, v14.n)))

		if flag4 then
			return
		end

		flag4 = true
		task.defer(thread, table.unpack(v15, 1, v15.n))
	end)
	task.delay(60, function()
		if flag4 then
			return
		end

		flag4 = true
		task.defer(thread, false, "Timeout")
	end)
	return coroutine.yield()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsMissingGems(reason)
	return reason == "Not enough Gems" or reason == "Not enough Paid Gems"
end

local function NotifyPurchase(reason)
	local v14 = "This offer is currently unavailable."
	local message

	if reason == nil then
		message = "Offer details are still loading. Please try again shortly."
	elseif reason == "Processing" then
		message = "A purchase is already being processed. Please wait."
	elseif reason == "Pending inbox" then
		message = v7 and "The recipient already has this gift in their inbox and must collect it first." or "You already have this purchase in your inbox. Collect it first!"
	elseif reason == "Owned" then
		message = v7 and "The recipient already owns this item." or "You already own this item."
	elseif reason == "Purchased" then
		message = v7 and "The recipient has reached the purchase limit for this offer." or "You have reached the purchase limit for this offer."
	elseif reason == "Expired" then
		message = "This offer has expired."
	elseif reason == "Sold Out" then
		message = "This offer is sold out."
	elseif IsMissingGems(reason) then
		message = reason == "Not enough Paid Gems" and "You don't have enough Paid Gems to send this gift." or "You don't have enough Gems to make this purchase."
	else
		message = reason == "Connection" and "Unable to confirm the purchase status. Please wait for the shop to update before trying again." or v14
	end

	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

local function RefreshBalance()
	local v14 = module.Shared.Gems.Read(module.Data)
	shop.Gems.FreeGems.Visible = v7 == nil
	shop.Gems.FreeGems.Icon.Image = module.Shared.Items.List["Free Gems"].Icon
	shop.Gems.FreeGems.Title.Text = module.Utils.Number:Format(not v14 and 0 or v14.Free or 0)
	shop.Gems.PaidGems.Visible = true
	shop.Gems.PaidGems.Icon.Image = module.Shared.Items.List["Paid Gems"].Icon
	shop.Gems.PaidGems.Title.Text = module.Utils.Number:Format(v14 and v14.Paid or 0)
end

local function RefreshCards(p)
	local v14 = p == nil

	for k, v15 in cardsByName do
		local status = not p and {} or p[k] or {}
		local offer = v15.Offer
		local v17 = {}

		if offer.Limit then
			table.insert(v17, tostring(status.Purchased or 0) .. "/" .. offer.Limit)
		end

		if offer.GlobalPurchaseLimit and status.Stock then
			table.insert(v17, "Stock: " .. status.Stock)
		end

		if offer.ExpiresAt then
			table.insert(v17, "Ends in " .. module.Utils.Number:Time2((math.max(0, offer.ExpiresAt - os.time()))))
		end

		if offer.PlayedTimeLimit then
			local v18

			if v7 then
				v18 = status.PlayedTimeRemaining or 0
			else
				v18 = math.max(
					0,
					offer.PlayedTimeLimit - module.Shared.TimeChamber.GetCommercePlayedTime(
						module.Data,
						module.Data.Profile.Stats["Time Played"] or 0
					)
				)
			end

			table.insert(v17, module.Utils.Number:Time2(v18) .. " left")
		end

		local maxPurchases = v15.Instance.Main:FindFirstChild("MaxPurchases")

		if maxPurchases then
			maxPurchases.Text = table.concat(v17, " | ")
			maxPurchases.TextWrapped = true
		end

		local visible = v7 == nil or offer.Kind == "GemPack"
		v15.RobuxContainer.Visible = visible
		v15.Available = visible and status.Available == true
		v15.Status = status
		v15.Button.Interactable = true

		if v15.GemsButton then
			local gems = status.Gems or {}
			v15.GemStatus = gems
			v15.GemsContainer.Visible = true
			v15.GemsButton.Interactable = true
			local reason = gems.Reason
			local v19

			if reason then
				if reason == "Unavailable" then
					v19 = false
				else
					local missingGems = IsMissingGems(reason) -- equivalent call inferred; original call site unknown
					v19 = not missingGems
				end
			else
				v19 = reason
			end

			local title = v15.GemsButton.Title

			if v15.Submitting == "Gems" then
				reason = "Processing"
			elseif not v19 then
				if gems.Price then
					reason = tostring(gems.Price) .. (v7 and " Paid Gems" or " Gems")
				else
					reason = v14 and "Loading..." or "Unavailable"
				end
			end

			title.Text = reason
		end

		local price

		if v7 then
			price = status.Price
		else
			price = module.Shared.CommerceCatalog.GetDisplayPrice(offer, {
				PriceInRobux = v15.Price or status.Price
			})
		end

		local reason = status.Reason
		local v19 = reason == "Owned" or reason == "Purchased" or reason == "Expired" or reason == "Sold Out" or reason == "Processing" or reason == "Pending inbox"
		local title = v15.Button.Title

		if v15.Submitting == "Robux" then
			reason = "Processing"
		elseif not v19 then
			if price == nil then
				reason = v14 and "Loading..." or "Unavailable"
			else
				reason = " " .. tostring(price)
			end
		end

		title.Text = reason
	end
end

local function ApplyProductInfo(p: string, p2)
	local v14 = cardsByName[p]

	if not v14 then
		return
	end

	v14.Price = p2.PriceInRobux

	if v14.Offer.Kind ~= "Gamepass" then
		return
	end

	for _, v15 in cardsByName do
		View.ApplyGamepassInfo(v15, p, p2)
	end
end

local function LoadProductInfo(data)
	if v2[data.Name] ~= nil or (typeof(data.ID) ~= "number" or data.ID <= 0 or data.ID % 1 ~= 0) then
		return
	end

	v2[data.Name] = false
	local success, result = pcall(function()
		local marketplaceService = module.Services.MarketplaceService
		local ID = data.ID
		local v14

		if data.Kind == "Gamepass" then
			v14 = Enum.InfoType.GamePass
		else
			v14 = Enum.InfoType.Product
		end

		return marketplaceService:GetProductInfoAsync(ID, v14)
	end)

	if not (success and result) then
		v2[data.Name] = nil
		return
	end

	v2[data.Name] = result

	if flag then
		ApplyProductInfo(data.Name, result)
		RefreshCards(Shop.Status)
	end
end

local function Resize()
	local X = scroll.AbsoluteSize.X

	for _, v14 in clones do
		v14.Size = UDim2.new(0.977, 0, 0, scroll.AbsoluteSize.Y * 0.1)
	end

	for _, v14 in cardsByName do
		if v14.Offer.Kind == "Bundle" then
			v14.Instance.Size = UDim2.new(0.9767, 0, 0, X * 0.9767 / 4.802043)
		else
			v14.Instance.Size = UDim2.new(0.488, 0, 0, X * 0.488 / 2.398428)
		end
	end
end

local function FetchStatus()
	if flag3 then
		return false
	end

	flag3 = true
	local v14 = count2
	local v15 = v7
	local v16, status

	if v15 then
		v16, status = Invoke("General", "Marketplace", "GiftStatus", v15.UserId)
	else
		v16, status = Invoke("General", "Marketplace", "Status")
	end

	flag3 = false

	if v14 ~= count2 then
		return false
	end

	local v18 = v16 and typeof(status) == "table"

	if v18 then
		Shop.Status = status
	end

	if flag then
		RefreshCards(Shop.Status)
	end

	return v18
end

local RequestStatus

RequestStatus = function()
	if v8 == count then
		return
	end

	local v14 = count
	v8 = v14
	task.delay(2.5, function()
		if v8 == v14 then
			v8 = nil
		end

		if not flag or count ~= v14 then
			return
		end

		if flag3 then
			RequestStatus()
		else
			FetchStatus()
		end
	end)
end

local function ReadGems()
	local v14 = module.Shared.Gems.Read(module.Data)
	return not v14 and 0 or v14.Free or 0, v14 and v14.Paid or 0
end

local function RefreshGems()
	RefreshBalance()
	local v14 = module.Shared.Gems.Read(module.Data)
	local v15 = not v14 and 0 or v14.Free or 0
	local paid = v14 and v14.Paid or 0

	if v15 == v9 and paid == v10 then
		return
	end

	v9 = v15
	v10 = paid

	if v8 == count then
		return
	end

	local v16 = count
	v8 = v16
	task.delay(2.5, function()
		if v8 == v16 then
			v8 = nil
		end

		if not flag or count ~= v16 then
			return
		end

		if flag3 then
			RequestStatus()
		else
			FetchStatus()
		end
	end)
end

local function RefreshEnded()
	local status = Shop.Status

	if not status then
		return
	end

	local now = os.time()
	local commercePlayedTime = module.Shared.TimeChamber.GetCommercePlayedTime(
		module.Data,
		module.Data.Profile.Stats["Time Played"] or 0
	)

	for k, v14 in cardsByName do
		if v11[k] then
			continue
		end

		local v15 = status[k]
		local gems = v15 and v15.Gems

		if not (v15 and (v15.Available or gems and gems.Available)) then
			continue
		end

		local offer = v14.Offer
		local v16

		if offer.ExpiresAt == nil then
			v16 = false
		else
			v16 = offer.ExpiresAt <= now
		end

		local v17

		if v7 == nil and offer.PlayedTimeLimit ~= nil then
			v17 = offer.PlayedTimeLimit <= commercePlayedTime
		else
			v17 = false
		end

		if not (v16 or v17) then
			continue
		end

		v11[k] = true

		if v8 == count then
			continue
		end

		v8 = count
		local v19 = count
		task.delay(2.5, function()
			if v8 == v19 then
				v8 = nil
			end

			if not flag or count ~= v19 then
				return
			end

			if flag3 then
				RequestStatus()
			else
				FetchStatus()
			end
		end)
	end
end

local function OnCommerceChanged(_, _, list)
	RefreshCards(Shop.Status)
	local v14 = list and list[1]

	if v14 == "Potions" or v14 == "PotionOrigins" or v14 == "Revision" or v8 == count then
		return
	end

	local v15 = count
	v8 = v15
	task.delay(2.5, function()
		if v8 == v15 then
			v8 = nil
		end

		if not flag or count ~= v15 then
			return
		end

		if flag3 then
			RequestStatus()
		else
			FetchStatus()
		end
	end)
end

local function Preload()
	for _, v14 in v do
		for _, v15 in module.Shared.CommerceCatalog.GetSection(v14) do
			task.spawn(LoadProductInfo, v15)
		end
	end

	for _ = 1, 5 do
		if Shop.Status or FetchStatus() then
			break
		else
			task.wait(3)
		end
	end
end

local Purchase

Purchase = function(state, submitting: string, data)
	if module.Frame:IsFrameOpened("Confirmation") or (not flag or cardsByName[state.Offer.Name] ~= state) then
		return
	end

	if v12 or os.clock() < v13 then
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = "A purchase is already being processed. Please wait.",
			Color = Color3.new(1, 1, 0)
		})
		return
	end

	local gemStatus

	if submitting == "Gems" then
		gemStatus = state.GemStatus
	else
		gemStatus = state.Status
	end

	if gemStatus and gemStatus.Available then
		if submitting == "Gems" and (typeof(gemStatus.Sequence) ~= "number" or typeof(gemStatus.Price) ~= "number") then
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Message = "Offer details are still loading. Please try again shortly.",
				Color = Color3.new(1, 1, 0)
			})
			task.spawn(FetchStatus)
		else
			local v14 = v7
			local generation = count
			local selection = count2

			if submitting == "Gems" then
				if data then
					if data.Generation ~= generation or data.Selection ~= selection or data.RecipientId ~= (not v14 and 0 or v14.UserId) or data.Price ~= gemStatus.Price or data.Sequence ~= gemStatus.Sequence then
						module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
							Message = "Unable to confirm the purchase status. Please wait for the shop to update before trying again.",
							Color = Color3.new(1, 1, 0)
						})
						task.spawn(FetchStatus)
						return
					end
				else
					local v17 = {
						Price = gemStatus.Price,
						Sequence = gemStatus.Sequence,
						Generation = generation,
						Selection = selection,
						RecipientId = not v14 and 0 or v14.UserId
					}
					local description

					if v14 then
						description = "Send " .. state.Offer.Name .. " to @" .. v14.UserName .. " for " .. gemStatus.Price .. " Paid Gems?"
					else
						description = "Buy " .. state.Offer.Name .. " for " .. gemStatus.Price .. " Gems?"
					end

					module.Scripts.Interface.Confirmation.Start({
						Title = v14 and "Confirm gift" or "Confirm purchase",
						Description = description,
						ConfirmText = v14 and "Send gift" or "Buy",
						CancelText = "Cancel",
						Callback = function(flag4: boolean)
							if not flag4 then
								return
							end

							Purchase(state, submitting, v17)
						end
					})
					return
				end
			end

			v12 = true
			state.Submitting = submitting
			RefreshCards(Shop.Status)
			local v17, v18

			if submitting == "Gems" then
				v17, v18 = Invoke(
					"General",
					"Marketplace",
					"BuyGems",
					state.Offer.Name,
					gemStatus.Sequence,
					gemStatus.Price,
					not v14 and 0 or v14.UserId
				)
			elseif v14 then
				v17, v18 = Invoke("General", "Marketplace", "GiftPurchase", state.Offer.Name, v14.UserId)
			else
				v17, v18 = Invoke("General", "Marketplace", "Purchase", state.Offer.Name)
			end

			v12 = false
			v13 = os.clock() + 1
			state.Submitting = nil

			if not v17 or typeof(v18) ~= "boolean" then
				module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
					Message = "Unable to confirm the purchase status. Please wait for the shop to update before trying again.",
					Color = Color3.new(1, 1, 0)
				})
			end

			if flag then
				if count == generation and count2 == selection then
					Shop.Status = nil
				end

				RefreshCards(Shop.Status)
				FetchStatus()
			end
		end
	else
		NotifyPurchase(gemStatus and gemStatus.Reason)
		task.spawn(FetchStatus)
	end
end

function Shop.SetGiftRecipient(p)
	v7 = p
	count2 += 1
	Shop.Status = nil
	shop.Buttons.Gift.Visible = v7 == nil
	shop.Buttons.Cancel.Visible = v7 ~= nil
	shop.Header.Title.Text = "Shop"
	shop.Gifting.Text = not v7 and "" or "Gifting to: @" .. v7.UserName
	shop.Gifting.Visible = v7 ~= nil
	RefreshBalance()

	if flag then
		RefreshCards(nil)
		task.spawn(FetchStatus)
	end
end

function Shop.StartGift()
	if flag2 then
		return
	end

	module.Scripts.Interface.PlayerSelector.Start({
		PastUI = "Shop",
		GlobalSearch = function(p: string)
			local v14, v15, v16 = Invoke("General", "Marketplace", "FindPlayer", p)

			if v14 then
				return v15, v16
			end

			return "PlayerNotFound"
		end,
		Callback = function(_: number, p: string)
			if flag2 then
				return
			end

			flag2 = true
			shop.Buttons.Gift.Main.Interactable = false
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Identifier = "GiftRecipient",
				Message = `Loading the shop for @{p}...`,
				Time = 60
			})
			local v14, v15, v16 = Invoke("General", "Marketplace", "GiftRecipient", p)
			flag2 = false
			shop.Buttons.Gift.Main.Interactable = true

			if not v14 or typeof(v15) ~= "table" then
				module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
					Identifier = "GiftRecipient",
					Message = (typeof(v16) ~= "string" or v16 == "Timeout") and "Couldn't load the shop for this player. Try again!" or v16,
					Color = Color3.new(1, 1, 0)
				})
				return
			end

			Shop.SetGiftRecipient(v15)
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Identifier = "GiftRecipient",
				Message = `Now gifting to @{v15.UserName}!`,
				Color = Color3.new(0, 1, 0)
			})
		end
	})
end

function Shop.CancelGift()
	Shop.SetGiftRecipient(nil)
	module.Signal:Fire("General", "Marketplace", "CancelGift")
end

function Shop.ScrollTo(p: string)
	local v14 = clones[p]

	if not v14 then
		return
	end

	if v6 then
		v6:Cancel()
	end

	local v15 = v14.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y
	local v16 = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
	v6 = module.Services.TweenService:Create(
		scroll,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			CanvasPosition = Vector2.new(0, (math.clamp(v15, 0, v16)))
		}
	)
	v6:Play()
end

function Shop:Open(p2: string?)
	local v14 = flag
	v4 = self
	v5 = p2
	module.Frame:Open(shop)

	if v14 then
		v5 = nil
	end

	if v14 and self then
		v4 = nil
		Shop.ScrollTo(self)
	end
end

function Shop.Start()
	if flag then
		return
	end

	flag = true
	count += 1
	local analytics = module.Scripts.General.Analytics

	if analytics then
		analytics.TrackShop(v5 or "Hud", v4 or "None")

		if v4 == "Gem Packs" then
			analytics.TrackUpsell("Gems")
		end
	end

	v5 = nil
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	scroll.UIListLayout.Wraps = true
	scroll.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	scroll2.ScrollingDirection = Enum.ScrollingDirection.Y
	local count3 = 0
	local count4 = 0

	for k, v14 in v do
		count3 += 1
		local clone = shop2.Separator:Clone()
		clone.Name = v14
		clone.Title.Text = v14
		clone.LayoutOrder = count3
		clone.Parent = scroll
		clones[v14] = clone
		local clone2 = shop2.Option:Clone()
		clone2.Name = v14
		clone2.LayoutOrder = k
		clone2.Main.Title.Text = v14
		clone2.Parent = scroll2
		table.insert(v3, clone2)
		table.insert(v3, View.Animate(clone2.Main, k, true))
		local v15 = v14
		table.insert(v3, View.Button(clone2.Main, function()
			Shop.ScrollTo(v15)
		end))

		for _, v16 in module.Shared.CommerceCatalog.GetSection(v14) do
			count4 += 1
			count3 += 1
			local v17 = v16.Kind == "Bundle" and "BundleTemplate" or v16.Kind == "Gamepass" and "GamepassTemplate" or "GemPackTemplate"
			local card = View.Card(shop2[v17], scroll, v16, count4)
			card.Instance.LayoutOrder = count3
			cardsByName[v16.Name] = card
			card.Bind = View.Button(card.Button, function()
				Purchase(card, "Robux")
			end)

			if card.GemsButton then
				local v19 = card
				card.GemsBind = View.Button(card.GemsButton, function()
					Purchase(v19, "Gems")
				end)
			end

			task.spawn(LoadProductInfo, v16)
		end
	end

	for k, v14 in v2 do
		if v14 then
			ApplyProductInfo(k, v14)
		end
	end

	local v14 = module.Shared.Gems.Read(module.Data)
	local v15 = not v14 and 0 or v14.Free or 0
	local paid = v14 and v14.Paid or 0
	v9 = v15
	v10 = paid
	Resize()
	RefreshBalance()
	RefreshCards(Shop.Status)
	table.insert(v3, scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize))
	table.insert(v3, module.Utils.Loop:Connect({
		Time = 15,
		Callback = FetchStatus
	}))
	table.insert(v3, module.Utils.Loop:Connect({
		Time = 1,
		Callback = function()
			RefreshCards(Shop.Status)
			RefreshEnded()
		end
	}))
	table.insert(v3, module:OnDataChanged({ "Items" }, RefreshGems))
	table.insert(v3, module:OnDataChanged({ "Commerce" }, OnCommerceChanged))
	table.insert(v3, module:OnDataChanged({ "Gamepasses" }, RequestStatus))
	table.insert(v3, module:OnDataChanged({ "Inbox" }, RequestStatus))
	task.spawn(FetchStatus)

	if v4 then
		local v16 = v4
		local v17 = count
		v4 = nil
		task.delay(0.3, function()
			if flag and count == v17 then
				Shop.ScrollTo(v16)
			end
		end)
	end
end

function Shop.Stop()
	flag = false
	count += 1

	if v7 then
		Shop.Status = nil
	end

	if v6 then
		v6:Cancel()
		v6 = nil
	end

	for _, v14 in cardsByName do
		View.DestroyCard(v14)
	end

	for _, v14 in v3 do
		View.Clean(v14)
	end

	for _, v14 in clones do
		v14:Destroy()
	end

	table.clear(cardsByName)
	table.clear(clones)
	table.clear(v3)
	table.clear(v11)
end

function Shop.Init()
	shop.Buttons.Gift.Main.Title.Text = "Gift"
	Shop.SetGiftRecipient(nil)
	View.Button(shop.Buttons.Gift.Main, Shop.StartGift)
	View.Button(shop.Buttons.Cancel.Main, Shop.CancelGift)
	module.Frame:OnFrameOpened(shop, Shop.Start)
	module.Frame:OnFrameClosed(shop, Shop.Stop)
	task.spawn(Preload)
end

return Shop