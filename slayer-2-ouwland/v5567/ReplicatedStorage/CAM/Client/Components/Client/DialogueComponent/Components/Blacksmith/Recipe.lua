local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Crafting = require(ReplicatedStorage.CAM.Global.Crafting)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Connector = require(ReplicatedStorage.CAM.Client.Components.Misc.Connector)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local Footer = require(script.Parent.Footer)
local Header = require(script.Parent.Header)
local MaterialCard = require(script.Parent.MaterialCard)
local TierBadge = require(script.Parent.TierBadge)
local MaterialTile = require(script.Parent.MaterialTile)
local RefineBadge = require(script.Parent.RefineBadge)
local info = faye.Info(0.25, Enum.EasingStyle.Back)
local uDim = UDim2.fromScale(0.9, 0.9)
local info2 = faye.Info(0.2, Enum.EasingStyle.Back)
return function(object, p, callback)
	return object:Create("Frame")({
		Name = "Recipe",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.new(0.65, -18, 1, -12),
		BackgroundTransparency = 1,
		object:State(function(callback2, object2)
			local v = callback2(p)

			if v == "" then
				return
			end

			local v2 = Crafting.Get(v)

			if v2 == nil then
				return
			end

			local item = Items[v2.result]
			local v3 = item ~= nil and Rarities.Colors[item.Rarity] or Color3.new(1, 1, 1)
			local v4 = item == nil and "" or Rarities.Order[item.Rarity] or ""
			local v5 = string.upper((string.sub(v4, 1, 1))) .. string.lower((string.sub(v4, 2)))
			local data = Utility.GetData(Players.LocalPlayer)
			local value = object2:Value(0)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function bump()
				value:Set(value.Value + 1)
			end

			local v6 = {}

			for _, v7 in v2.required do
				v6[v7.name] = true
			end

			for _, additionalMaterial in v2.additionalMaterials do
				v6[additionalMaterial.name] = true
			end

			for _, v7 in v2.keep or {} do
				v6[v7] = true
			end

			for k in v2.price do
				v6[k] = true
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function watchStack(child)
				if not v6[child.Name] then
					return
				end

				bump() -- equivalent call inferred; original call site unknown
				local amount = child:FindFirstChild("Amount")

				if amount ~= nil then
					object2:Connect(amount.Changed, bump)
				end
			end

			for _, v7 in Utility.ItemBags(data) do
				for _, child in v7:GetChildren() do
					watchStack(child) -- equivalent call inferred; original call site unknown
				end

				object2:Connect(v7.ChildAdded, watchStack)
				object2:Connect(v7.ChildRemoved, function(p2)
					if v6[p2.Name] then
						bump() -- equivalent call inferred; original call site unknown
					end
				end)
			end

			local wen

			if data ~= nil then
				wen = data:FindFirstChild("Wen") or nil
			end

			if wen ~= nil then
				object2:Connect(wen.Changed, bump)
			end

			local items_Config = Players.LocalPlayer:FindFirstChild("Items_Config")
			local equipped

			if items_Config ~= nil then
				equipped = items_Config:FindFirstChild("Equipped") or nil
			end

			if equipped ~= nil then
				object2:Connect(equipped.Changed, bump)
			end

			local function tierOf(p2: string)
				return Crafting.RequiredTier(v2, p2)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function spentLevel(callback3, p2: string)
				callback3(value)
				local spentCopy = Crafting.SpentCopy(Players.LocalPlayer, p2, tierOf(p2))

				if spentCopy == nil then
					return nil
				end

				local refineLevel = spentCopy:FindFirstChild("RefineLevel")

				if refineLevel == nil then
					return 0
				end

				return refineLevel.Value
			end

			local name = nil

			if v2.refineKept ~= nil then
				for _, v8 in v2.required do
					if not Refinement.IsRefinable(v8.name) then
						continue
					end

					name = v8.name
					break
				end
			end

			local function owned(callback3, p2: string)
				callback3(value)
				local itemBag = Utility.ItemBag(data, p2)

				if itemBag == nil then
					return 0
				end

				return Crafting.Held(itemBag, p2, tierOf(p2))
			end

			local v7 = {}

			for _, v8 in { v2.required, v2.additionalMaterials } do
				for _, v9 in v8 do
					v7[v9.name] = (v7[v9.name] or 0) + v9.amount
				end
			end

			local function canPay(callback3, currency: string, amount: number)
				callback3(value)
				local cashier = Shop.cashiers[currency]

				if cashier == nil or data == nil then
					return false
				end

				if cashier.Deferred == true or Items[currency] == nil then
					return cashier.CanBuy(data, amount) == true
				end

				callback3(value)
				local itemBag = Utility.ItemBag(data, currency)
				return (itemBag == nil and 0 or Crafting.Held(itemBag, currency, tierOf(currency))) >= amount + (v7[currency] or 0)
			end

			local priceLines = {}

			for k, v9 in v2.price do
				table.insert(priceLines, {
					Currency = k,
					Amount = Crafting.PricedLine(nil, v2, k, v9)
				})
			end

			table.sort(priceLines, function(a, b)
				if a.Currency == "Wen" == (b.Currency == "Wen") then
					return a.Currency < b.Currency
				end

				return a.Currency == "Wen"
			end)

			local function canCraft(noGrab)
				for k, v9 in v7 do
					noGrab(value)
					local itemBag = Utility.ItemBag(data, k)

					if (itemBag == nil and 0 or Crafting.Held(itemBag, k, tierOf(k))) < v9 then
						return false
					end
				end

				for _, v9 in v2.keep or {} do
					noGrab(value)
					local itemBag = Utility.ItemBag(data, v9)

					if (itemBag == nil and 0 or Crafting.Held(itemBag, v9, tierOf(v9))) < 1 then
						return false
					end
				end

				for _, v9 in priceLines do
					local cashier = Shop.cashiers[v9.Currency]

					if cashier ~= nil and cashier.Deferred == true or not canPay(noGrab, v9.Currency, v9.Amount) then
						return false
					end
				end

				return true
			end

			local v9 = #v2.additionalMaterials > 0
			local canvasSize = object2:Value(UDim2.new())
			local v10 = false

			local function noGrab() end

			local v11 = object2:Create("Frame")
			local v12 = {
				Name = "Holder",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = object2:Animation(UDim2.fromScale(1, 1), info, {
					From = uDim
				}),
				BackgroundTransparency = 1
			}
			local header = Header(object2, v2.result, v5, v3)
			local v14 = object2:Create("Frame")
			local v15 = {
				Name = "Craft",
				Position = UDim2.fromScale(0, 0.145),
				Size = UDim2.fromScale(1, 0.44),
				BackgroundTransparency = 1
			}
			local v16 = object2:Create("Frame")({
				Name = "Required",
				Size = UDim2.fromScale(0.44, 1),
				BackgroundTransparency = 1,
				object2:Create("UIListLayout")({
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0.04, 0)
				}),
				object2:Iterate(v2.required, function(_, p2, p3, _)
					local v19

					if Refinement.IsRefinable(p2.name) then
						v19 = spentLevel
					end

					return MaterialCard(p3, p2, owned, v19, tierOf(p2.name))
				end),
				object2:Iterate(v2.keep or {}, function(_, name2, p3, _)
					return MaterialCard(p3, {
						name = name2,
						amount = 1
					}, owned, nil)
				end)
			})
			local connector = Connector(object2, UDim2.fromScale(0.47, 0.5), 0.17)
			local v18 = object2:Create("Frame")
			local v19 = {
				Name = "Result",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.32, 0.9),
				object2:Create("UIAspectRatioConstraint")({}),
				BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
				BackgroundTransparency = 0.95
			}
			local v20 = object2:Create("UICorner")({
				CornerRadius = UDim.new(0.5, 0)
			})
			local v21 = object2:Create("UIShadow")({
				Color = Color3.new(0.25, 0.25, 0.25),
				BlurRadius = UDim.new(0.4),
				Transparency = 0.4
			})
			local v22 = object2:Create("Frame")({
				Name = "Bg",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 0.5),
				Rotation = 45,
				BackgroundColor3 = v3,
				object2:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				}),
				object2:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.6),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -90
				}),
				object2:Create("UIShadow")({
					BlurRadius = UDim.new(1),
					Color = v3,
					Spread = UDim2.fromScale(-0.5, -0.5)
				})
			})
			local v23 = object2:Create("ImageLabel")({
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = object2:Animation(UDim2.fromScale(0.85, 0.85), info2, {
					From = UDim2.fromScale(0.6, 0.6)
				}),
				BackgroundTransparency = 1,
				Image = item == nil and "" or item.Icon or "",
				ZIndex = 2
			})
			local v24

			if v2.amount > 1 then
				v24 = object2:Create("TextLabel")({
					Name = "Amount",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.9),
					Size = UDim2.fromScale(0.4, 0.15),
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					Text = `x{v2.amount}`,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextStrokeTransparency = 0.8,
					ZIndex = 3
				}) or nil
			end

			local v25

			if name ~= nil then
				v25 = RefineBadge(object2, function(callback3)
					local v27 = spentLevel(callback3, name) -- equivalent call inferred; original call site unknown

					if v27 == nil then
						return nil
					end

					return (math.clamp(math.floor(v27 * v2.refineKept), 0, Refinement.MaxLevel))
				end) or nil
			end

			local v26

			if v2.tier ~= nil then
				v26 = TierBadge(object2, v2.tier) or nil
			end

			v19[2], v19[3], v19[4], v19[5], v19[6], v19[7], v19[8] = v20, v21, v22, v23, v24, v25, v26
			do local _values = table.pack(v16, connector, v18(v19)); for _k = 1, _values.n do v15[_k] = _values[_k] end end
			local v27 = v14(v15)
			local v28

			if v9 then
				v28 = object2:Create("Frame")({
					Name = "Additional",
					Position = UDim2.fromScale(0, 0.6),
					Size = UDim2.fromScale(1, 0.26),
					BackgroundTransparency = 1,
					object2:Create("TextLabel")({
						Name = "Label",
						Size = UDim2.fromScale(1, 0.19),
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSansSemibold,
						Text = "Additional Materials",
						TextColor3 = Color3.new(1, 1, 1),
						TextTransparency = 0.25,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left
					}),
					object2:Create("CanvasGroup")({
						Name = "StripMask",
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.fromScale(1, 0.76),
						BackgroundTransparency = 1,
						object2:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.02, 0),
								NumberSequenceKeypoint.new(0.8, 0),
								NumberSequenceKeypoint.new(1, 1)
							})
						}),
						object2:Create("ScrollingFrame")({
							Name = "Strip",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							ScrollBarThickness = 0,
							ScrollingDirection = Enum.ScrollingDirection.X,
							CanvasSize = canvasSize,
							object2:Create("UIListLayout")({
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								Padding = UDim.new(0, 4),
								AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
									canvasSize:Set(UDim2.new(0, point.X * 1.2 / callback(), 0, 0))
								end
							}),
							object2:Iterate(v2.additionalMaterials, function(_, p2, p3, _)
								return MaterialTile(p3, p2, owned)
							end)
						})
					})
				}) or nil
			end

			do local _values = table.pack(header, v27, v28, Footer(object2, {
	PriceLines = priceLines,
	CanPay = canPay,
	Ready = canCraft,
	Text = "Craft",
	Clicked = function()
		if v10 or not canCraft(noGrab) then
			return
		end

		v10 = true
		local v29 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		local success, result = pcall(SignalFunction.ToServer, "CraftRecipe", v)
		v29:Destroy()
		v10 = false

		if success then
			if typeof(result) == "table" then
				success = result.Ok == true
			else
				success = false
			end
		end

		local clone = ReplicatedStorage.Assets.Sounds.Misc[success and "Money_Kaching" or "denied_old"]:Clone()
		clone.Parent = script
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
	end
})); for _k = 1, _values.n do v12[_k] = _values[_k] end end
			return v11(v12)
		end)
	})
end