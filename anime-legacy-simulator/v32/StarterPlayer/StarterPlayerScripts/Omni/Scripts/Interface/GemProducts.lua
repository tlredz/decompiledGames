local module = require("@game/ReplicatedStorage/Omni")
local View = require(script.Parent.Shop.View)
local gemProducts = module.Interface.Frames.GemProducts
local scroll = gemProducts.List.Scroll
local gemProduct = module.Assets.Interface.Templates.GemProduct
local context = nil
local cardsByName = {}
local v2 = {}
local v3 = false
local v4 = 0
local flag = false
local GemProducts = {}

local function Invoke(...)
	local thread = coroutine.running()
	local v5 = table.pack(...)
	local flag2 = false
	task.spawn(function()
		local v6 = table.pack(pcall(module.Signal.Invoke, module.Signal, table.unpack(v5, 1, v5.n)))

		if flag2 then
			return
		end

		flag2 = true
		task.defer(thread, table.unpack(v6, 1, v6.n))
	end)
	task.delay(60, function()
		if flag2 then
			return
		end

		flag2 = true
		task.defer(thread, false, "Timeout")
	end)
	return coroutine.yield()
end

local function Notify(message: string)
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

local function Refresh()
	local v5 = module.Shared.Gems.Read(module.Data)
	gemProducts.Gems.FreeGems.Visible = true
	gemProducts.Gems.FreeGems.Icon.Image = module.Shared.Items.List["Free Gems"].Icon
	gemProducts.Gems.FreeGems.Title.Text = module.Utils.Number:Format(not v5 and 0 or v5.Free or 0)
	gemProducts.Gems.PaidGems.Visible = true
	gemProducts.Gems.PaidGems.Icon.Image = module.Shared.Items.List["Paid Gems"].Icon
	gemProducts.Gems.PaidGems.Title.Text = module.Utils.Number:Format(not v5 and 0 or v5.Paid or 0)

	for _, v6 in cardsByName do
		local conversion = v6.Conversion
		v6.Reason = nil

		if conversion and conversion.Enabled and module.Shared.CommerceCatalog.Enabled and not (conversion.Amount <= 0 or conversion.Gems <= 0) then
			if v5 then
				if v5.Total < conversion.Gems then
					v6.Reason = "You do not have enough Gems for this purchase."
				end
			else
				v6.Reason = "Your Gems balance is temporarily unavailable. Please try again."
			end
		else
			v6.Reason = "This offer is unavailable at the moment."
		end

		v6.Available = v6.Reason == nil
		v6.Button.Interactable = true
	end
end

local Purchase

Purchase = function(p: string, data, data2)
	if module.Frame:IsFrameOpened("Confirmation") or (not flag or cardsByName[p] ~= data) then
		return
	end

	if v3 or os.clock() < v4 then
		Notify("A purchase is processing. Please wait a moment.")
		return
	end

	Refresh()

	if not data.Available then
		Notify(data.Reason)
		return
	end

	local conversion = data.Conversion
	local sequence = module.Data.Commerce.ConversionSequence + 1

	if data2 then
		if data2.Context ~= context or data2.Price ~= conversion.Gems or data2.Amount ~= conversion.Amount or data2.Currency ~= conversion.Currency or data2.Sequence ~= sequence then
			Notify("The offer changed. Please confirm the updated purchase.")
			return
		end

		v3 = true
		local v6, v7 = Invoke("General", "Marketplace", "Convert", p, data2.Sequence, data2.Price)
		v3 = false
		v4 = os.clock() + 0.3

		if flag then
			Refresh()
		end

		if not v6 or typeof(v7) ~= "boolean" then
			Notify("The purchase response could not be confirmed. Check your balance before trying again.")
		end
	else
		local v6 = {
			Context = context,
			Price = conversion.Gems,
			Amount = conversion.Amount,
			Currency = conversion.Currency,
			Sequence = sequence
		}
		module.Scripts.Interface.Confirmation.Start({
			Title = "Confirm purchase",
			Description = "Buy " .. conversion.Amount .. " " .. conversion.Currency .. " for " .. conversion.Gems .. " Gems?",
			ConfirmText = "Buy",
			CancelText = "Cancel",
			Callback = function(flag2: boolean)
				if not flag2 then
					return
				end

				Purchase(p, data, v6)
			end
		})
	end
end

function GemProducts:Open(sourceName: string, p3: string?)
	local v5 = module.Shared[self]

	if v5 and v5.List and self ~= "Breathings" and self ~= "Traits" and self ~= "PlayerLevel" then
		v5 = v5.List[sourceName]
	end

	local price = v5 and v5.Price

	if not price or typeof(price.Name) ~= "string" then
		return
	end

	if flag then
		GemProducts.Stop()
	end

	context = {
		Type = price.Type,
		Name = price.Name,
		SourceType = self,
		SourceName = sourceName
	}
	local analytics = module.Scripts.General.Analytics

	if analytics then
		analytics.TrackUpsell(price.Name)
	end

	module.Frame:SetPastUI(p3)
	module.Frame:Open(gemProducts)

	if not flag then
		GemProducts.Start()
	end
end

function GemProducts.Start()
	if flag or not context then
		return
	end

	flag = true
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local v5 = {}

	for k, conversion in module.Shared.CommerceCatalog.Conversions do
		if not (conversion.SourceType == context.SourceType and conversion.SourceName == context.SourceName and conversion.Type == context.Type and conversion.Currency == context.Name) then
			continue
		end

		table.insert(v5, {
			Name = k,
			Info = conversion
		})
	end

	table.sort(v5, function(a, b)
		return a.Info.Order < b.Info.Order
	end)

	for k, v6 in v5 do
		local info = v6.Info
		local v7

		if info.Gems > 0 then
			v7 = info.Amount > 0
		else
			v7 = false
		end

		local name

		if info.Amount > 0 then
			name = tostring(info.Amount) .. " " .. info.Currency
		else
			name = info.Currency .. " #" .. info.Order
		end

		local v8 = {
			Name = name,
			Description = not v7 and "This offer is not available yet." or "Receive " .. info.Amount .. " " .. info.Currency .. ".",
			Kind = "Conversion",
			Rewards = {}
		}
		local card = View.Card(gemProduct, scroll, v8, k)
		card.Instance.Name = v6.Name
		local v10 = module.Utils.Info:Get(info.Type, info.Currency)
		card.Instance.Main.Icon.Image = View.Image(v10 and v10.Icon)
		card.Instance.Main.Icon.Visible = card.Instance.Main.Icon.Image ~= ""
		card.Conversion = info
		card.Button.Title.Text = not v7 and "Unavailable" or tostring(info.Gems) .. " Gems"
		local v11 = v6
		card.Bind = View.Button(card.Button, function()
			Purchase(v11.Name, card)
		end)
		cardsByName[v6.Name] = card
	end

	for _, v6 in {
		{ "Items" },
		{ "Commerce" }
	} do
		table.insert(v2, module:OnDataChanged(v6, Refresh))
	end

	Refresh()
end

function GemProducts.Stop()
	flag = false

	for _, connection in v2 do
		connection:Disconnect()
	end

	for _, v5 in cardsByName do
		View.DestroyCard(v5)
	end

	table.clear(v2)
	table.clear(cardsByName)
end

function GemProducts.Init()
	module.Frame:OnFrameOpened(gemProducts, GemProducts.Start)
	module.Frame:OnFrameClosed(gemProducts, GemProducts.Stop)

	for _, v5 in { gemProducts.Gems.FreeGems, gemProducts.Gems.PaidGems } do
		local more = v5:FindFirstChild("More")

		if more then
			View.Button(more, function()
				module.Signal:FireSelf("Interface", "Shop", "Open", "Gem Packs", "GemBalance")
			end)
		end
	end
end

return GemProducts