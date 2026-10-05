local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local VipAccess = require(ReplicatedStorage.CAM.Global.VipAccess)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local LiveConfig = require(ReplicatedStorage.CAM.Global.LiveConfig)
local ShopSettingsLive = require(ReplicatedStorage.CAM.Global.ShopSettingsLive)
local shopSettings = require(ReplicatedStorage.CAM.Global.shopSettings)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
require(script.GridContent)
local GiftBox = require(script.GiftBox)
local AdForOre = require(ReplicatedStorage.CAM.Client.Components.Misc.AdForOre)
local Full = require(script.Full)
local Half = require(script.Half)
local info = faye.Info(0.35)

local function requiresVip(items)
	for _, item in items do
		if typeof(item) == "table" and item.RequiresVIP == true then
			return true
		end
	end

	return false
end

local function buildChildren(items)
	local v = {}

	for k, item in items do
		if typeof(item) == "table" and item.Hidden ~= true then
			table.insert(v, {
				Key = k,
				Entry = item
			})
		end
	end

	table.sort(v, function(a, b)
		local order = a.Entry.Order or 1e999
		local order2 = b.Entry.Order or 1e999

		if order == order2 then
			return a.Key < b.Key
		end

		return order < order2
	end)
	local v2 = nil
	local result = {}

	for _, v3 in ipairs(v) do
		local clone = table.clone(v3.Entry)
		clone.Icon = Shop.cashiers.Product.GetProductIcon(clone.ProductId)
		local label

		if typeof(clone.Duration) == "number" then
			label = `{clone.Name} ({math.floor(clone.Duration / 60 + 0.5)}m)`
		else
			label = clone.Name
		end

		clone.Label = label

		if clone.Type == 1 then
			table.insert(result, clone)
		elseif v2 == nil then
			v2 = {
				IsSplit = true,
				Content = { clone }
			}
		else
			table.insert(v2.Content, clone)
			table.insert(result, v2)
			v2 = nil
		end
	end

	if v2 ~= nil then
		table.insert(result, v2)
	end

	return result
end

local function spinsCategory()
	local result = {}

	for k, v in Shop.itemsforsale do
		if v.Type ~= Menum.ShopItemType.Spins then
			continue
		end

		local product

		if typeof(v.Price) == "table" then
			product = v.Price.Product or nil
		end

		if product ~= nil then
			result[k] = {
				Name = k,
				ProductId = product,
				ListedPrice = v.ListedPrice,
				Order = tonumber(v.Spins) or 1e999,
				Color = "Purple"
			}
		end
	end

	return result
end

local function buildContent()
	local shopSettings2 = {}

	for k, shopSetting in shopSettings do
		if typeof(shopSetting) == "table" then
			shopSettings2[k] = shopSetting
		end
	end

	shopSettings2.Spins = spinsCategory()
	local v = {}

	for k, v2 in shopSettings2 do
		if #buildChildren(v2) > 0 then
			table.insert(v, k)
		end
	end

	table.sort(v)
	local result = {}

	for _, categoryName in ipairs(v) do
		local v3 = {
			CategoryName = categoryName,
			Children = buildChildren(shopSettings2[categoryName]),
			RequiresVIP = 0
		}
		local flag = true
		local requiresVIP

		for _, v5 in shopSettings2[categoryName] do
			if not (typeof(v5) == "table" and v5.RequiresVIP == true) then
				continue
			end

			requiresVIP = true
			flag = false
			break
		end

		if flag then
			requiresVIP = false
		end

		v3.RequiresVIP = requiresVIP
		table.insert(result, v3)
	end

	return result
end

local item = gameSettings.SellRobuxPayout and gameSettings.SellRobuxPayout.Item or "Ore"
local v = {
	{
		Name = "Robux",
		Icon = BunchaIcons.Robux
	},
	{
		Name = "Ore",
		Icon = Items[item] and Items[item].Icon or "",
		IconColor = Color3.new(1, 1, 1)
	}
}
local value = "Robux"
local vector = Vector2.new(0.3, 0.045)
local v2 = vector.Y / 0.62
local v3 = {
	{
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0)
	},
	{
		Position = UDim2.fromScale(0.5, 1),
		AnchorPoint = Vector2.new(0.5, 1)
	}
}
return function(maid, _)
	local value2 = maid:Value(value)
	maid:Connect(value2.Changed, function()
		value = value2.Value
	end)
	local value3 = maid:Value("")
	local value4 = maid:Value("")
	local v4 = Platform_Handler.Platform.Value == "Mobile" and 1.35 or 1
	local uDim = UDim2.fromScale(vector.X * v4, vector.Y * v4)
	local numberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	local space = maid:Space(function(state)
		local state2 = state.In:Compare(true) and 1 or 0

		if state.State == state2 then
			return
		end

		if state2 == 1 then
			state.BgColor:Set(Color3.new(0.32, 0.32, 0.32))
			state.ShadowTransparency:Set(0.15)
			state.StrokeTransparency:Set(0.25)
			state.StrokeThickness:Set(2)
			state.GradientTransparency:Set(numberSequence)
			state.IconSize:Set(UDim2.fromScale(1.3, 1.3))
		else
			state.BgColor:Reset()
			state.ShadowTransparency:Reset()
			state.StrokeTransparency:Reset()
			state.StrokeThickness:Reset()
			state.GradientTransparency:Reset()
			state.IconSize:Reset()
		end

		state.State = state2
	end)
	local localPlayer = Players.LocalPlayer
	local value5 = maid:Value(VipAccess.Has(localPlayer))
	maid:Connect(VipAccess.Changed(), function()
		value5:Set(VipAccess.Has(localPlayer))
	end)
	local flag = false

	local function promptVip(p)
		if flag then
			return
		end

		flag = true
		ScreenEffects.StrokeClick(p.Parent, UDim.new(0.2))
		local v5 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		VipAccess.PromptPurchase()
		v5:Destroy()
		flag = false
	end

	local canvasSize = maid:Value(UDim2.fromScale(0, 0))
	local size = maid:Value(UDim2.fromScale(1, 0))
	local padding = maid:Value(UDim.new(0, 0))
	local value9 = maid:Value({})

	local function updateContent()
		task.spawn(function()
			local content = buildContent()

			if not maid.IsActive then
				return
			end

			value9:Set(content)
		end)
	end

	task.spawn(function()
		local content = buildContent()

		if not maid.IsActive then
			return
		end

		value9:Set(content)
	end)
	maid:Add(LiveConfig.listen(ShopSettingsLive.KEY, updateContent))
	return maid:Create("Frame")({
		Size = maid:Animation(UDim2.fromScale(0.8, 0.8), maid.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(0.7200000000000001, 0.7200000000000001)
		}),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		maid:Create("Frame")({
			Name = "CurrencyTypeHolder",
			Size = UDim2.fromScale(0.2, 0.04),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 0, -2),
			BackgroundTransparency = 1,
			PageBrowser(maid, value2, v, {
				Key = function(_, p)
					return p.Name
				end,
				Icon = function(_, p)
					return p.Icon
				end,
				IconColor = function(_, p)
					return p.IconColor
				end,
				IconShadow = true,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0, 0),
				TabSize = UDim2.fromScale(1, 1),
				Padding = UDim.new(0, 0),
				Backdrop = false,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		}),
		maid:Create("Frame")({
			Name = "GiftHolder",
			Size = uDim,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 0, 0, -2),
			BackgroundTransparency = 1,
			ZIndex = 5,
			GiftBox(maid, value3, value4)
		}),
		maid:Create("Frame")({
			Name = "AdHolder",
			Size = UDim2.fromScale(1, v2 * v4),
			Position = UDim2.new(0, 0, 1, 2),
			BackgroundTransparency = 1,
			AdForOre(maid)
		}),
		maid:Create("CanvasGroup")({
			Name = "CategoriesGroup",
			Size = UDim2.new(1, 5, 1, 5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			maid:Create("UIGradient")({
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.92, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			maid:Create("ScrollingFrame")({
				Name = "Categories",
				Size = UDim2.new(1, -20, 1, -20),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				CanvasSize = canvasSize,
				ScrollBarThickness = 0,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ClipsDescendants = false,
				AbsoluteWindowSizeOnChangedInit = function(_, point: Vector2)
					local v5 = Platform_Handler.Platform.Value == "Mobile" and 0.476 or 0.34
					size:Set(UDim2.new(1, 0, 0, point.Y * v5))
					padding:Set(UDim.new(0, point.Y * 0.05))
				end,
				maid:Create("UIListLayout")({
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = padding,
					AbsoluteContentSizeOnChangedInit = function(p)
						canvasSize:Set(UDim2.fromOffset(0, p.AbsoluteContentSize.Y * 1.2))
					end
				}),
				maid:Iterate(value9, function(layoutOrder, data, object)
					local v5 = object:Create("Frame")
					local v6 = {
						Name = data.CategoryName,
						LayoutOrder = layoutOrder,
						Size = size,
						BackgroundTransparency = 1
					}
					local v7

					if data.RequiresVIP then
						v7 = object:State(function(callback, object2)
							if callback(value5) then
								return
							else
								return object2:Create("CanvasGroup")({
									Name = "VipCover",
									ZIndex = 99,
									Size = UDim2.new(1, 4, 1, 4),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									BackgroundTransparency = 1,
									OnClean = {
										GroupTransparency = object2:Animation(1, info)
									},
									object2:Create("TextButton")({
										ZIndex = 99,
										CleanDelay = info.Time,
										MouseButton1Click = promptVip,
										BackgroundTransparency = 0.05,
										Selectable = true,
										AutoButtonColor = false,
										Size = UDim2.fromScale(1, 1),
										BackgroundColor3 = Color3.new(),
										object2:Create("UICorner")({
											CornerRadius = UDim.new(0.06)
										}),
										object2:Create("UIShadow")({
											BlurRadius = UDim.new(0.6),
											Transparency = 0.15
										}),
										object2:Create("UIGradient")({
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 0),
												NumberSequenceKeypoint.new(1, 0.5)
											}),
											Rotation = -90
										}),
										object2:Create("UIListLayout")({
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											FillDirection = Enum.FillDirection.Vertical
										}),
										object2:Create("ImageLabel")({
											Size = UDim2.fromScale(0.3, 0.3),
											Instance.new("UIAspectRatioConstraint"),
											BackgroundTransparency = 1,
											Image = BunchaIcons.Locked
										}),
										object2:Create("TextLabel")({
											Size = UDim2.new(1, -4, 0.35, 0),
											BackgroundTransparency = 1,
											TextColor3 = Color3.new(1, 1, 1),
											Text = "You need VIP to access this (Purchase VIP by clicking me)",
											TextScaled = true,
											Font = Enum.Font.SourceSansSemibold
										})
									})
								})
							end
						end)
					end

					do local _values = table.pack(v7, object:Create("TextLabel")({
	Name = "Title",
	Size = UDim2.fromScale(1, 0.09),
	BackgroundTransparency = 1,
	Text = data.CategoryName,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.SourceSansSemibold
}), object:Create("Frame")({
	Name = "Holder",
	Size = UDim2.fromScale(1, 0.91),
	Position = UDim2.fromScale(0, 0.09),
	BackgroundTransparency = 1,
	object:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0)
	}),
	object:Iterate(data.Children, function(layoutOrder2, data2, object2)
		local v8 = object2:Create("Frame")
		local v9 = {
			Name = data2.IsSplit and "Split" or data2.Name,
			LayoutOrder = layoutOrder2,
			Size = UDim2.fromScale(0.25, 1),
			BackgroundTransparency = 1
		}
		local v10 = object2:Create("UIAspectRatioConstraint")({
			AspectRatio = 0.5
		})
		local v11

		if data2.IsSplit then
			v11 = function()
				local result = {}

				for k, v12 in data2.Content do
					table.insert(result, Half(object2, space, v12, v3[k], value2, value3, value4))
				end

				return result
			end
		else
			v11 = Full(object2, space, data2, value2, value3, value4)
		end

		v9[1], v9[2] = v10, v11
		return v8(v9)
	end)
})); for _k = 1, _values.n do v6[_k] = _values[_k] end end
					return v5(v6)
				end)
			})
		})
	})
end