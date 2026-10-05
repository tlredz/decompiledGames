local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ListRecipe = require(script.ListRecipe)
local Recipe = require(script.Recipe)
local TierTransfer = require(script.TierTransfer)
local faye = require(ReplicatedStorage.Packages.faye)
local Crafting = require(ReplicatedStorage.CAM.Global.Crafting)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Searchbar = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.Searchbar)
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
local info = faye.Info(0.45)
local uDim = UDim2.fromScale(0, 0.04)
local v = { "Craft", "Transfer" }

local function Panel(station: string?, object, instance, _, _)
	local v2 = Crafting.ForStation(station)
	local data = Utility.GetData(Players.LocalPlayer)
	local v3 = {}
	local value = object:Value("")
	local stringValue = Instance.new("StringValue")
	local v4 = {}
	local value2 = object:Value(v4)
	local v5 = {}
	local v6 = {}

	local function holds(p: string)
		local v7 = v2[p].required[1]
		local itemBag = Utility.ItemBag(data, v7.name)
		return itemBag ~= nil and Crafting.Held(itemBag, v7.name, v2[p].requiredTier) >= v7.amount
	end

	local function updateShown()
		table.clear(v4)
		table.clear(v3)
		table.clear(v5)
		table.clear(v6)
		local value3 = string.lower(stringValue.Value)

		for k, v7 in v2 do
			local v8 = false

			for _, v9 in v7.keep or {} do
				if Utility.HeldItem(data, v9) == nil then
					v8 = true
				end
			end

			if v8 or not (not v7.listedWhenHeld or Crafting.SpentCopy(
				Players.LocalPlayer,
				v7.required[1].name,
				v7.requiredTier
			) ~= nil) then
				continue
			end

			if v5[v7.result] == nil then
				v5[v7.result] = {}
				table.insert(v3, v7.result)
			end

			table.insert(v5[v7.result], k)
		end

		table.sort(v3)

		for _, id in v3 do
			if not (value3 == "" or string.sub(string.lower(id), 1, #value3) == value3) then
				continue
			end

			table.insert(v4, {
				result = id,
				id = id
			})
		end

		for k, v7 in v5 do
			local v8 = {}

			for _, v9 in v7 do
				local tier = v2[v9].tier or 0
				v8[tier] = v8[tier] or {}
				table.insert(v8[tier], v9)
			end

			local v9 = {}

			for _, v10 in v8 do
				local v11 = false

				for _, v12 in v10 do
					if v11 then
						continue
					end

					local v13 = v2[v12].required[1]
					local itemBag = Utility.ItemBag(data, v13.name)

					if itemBag == nil then
						v11 = false
					else
						v11 = Crafting.Held(itemBag, v13.name, v2[v12].requiredTier) >= v13.amount
					end
				end

				for _, v12 in v10 do
					v6[v12] = #v10 > 1

					if v11 then
						local v13 = v2[v12].required[1]
						local itemBag = Utility.ItemBag(data, v13.name)
						local v14

						if itemBag == nil then
							v14 = false
						else
							v14 = Crafting.Held(itemBag, v13.name, v2[v12].requiredTier) >= v13.amount
						end

						if not v14 then
							continue
						end
					end

					table.insert(v9, v12)
				end
			end

			table.sort(v9, function(a, b)
				local v10 = v2[a]
				local v11 = v2[b]

				if (v10.tier or 0) == (v11.tier or 0) then
					return v10.required[1].name < v11.required[1].name
				end

				return (v10.tier or 0) < (v11.tier or 0)
			end)
			v5[k] = v9
		end

		value2:Refresh()
	end

	updateShown()
	object:Connect(stringValue:GetPropertyChangedSignal("Value"), updateShown)

	for _, v7 in Utility.ItemBags(data) do
		object:Connect(v7.ChildAdded, updateShown)
		object:Connect(v7.ChildRemoved, updateShown)
	end

	local value3 = object:Value("")
	object:Connect(value3.Changed, function()
		local v7 = v5[value3:Get()] or {}
		local v8 = v7[1] or ""

		for _, v10 in v7 do
			local v11 = v2[v10].required[1]
			local itemBag = Utility.ItemBag(data, v11.name)
			local v12

			if itemBag == nil then
				v12 = false
			else
				v12 = Crafting.Held(itemBag, v11.name, v2[v10].requiredTier) >= v11.amount
			end

			if not v12 then
				continue
			end

			v8 = v10
			break
		end

		value:Set(v8)
	end)

	local function variantRows(p: string)
		local result = {}

		for _, id in v5[p] or {} do
			local v8 = v2[id]
			local v10

			if v6[id] then
				v10 = v8.required[1].name
			else
				v10 = v8.result
			end

			local tier

			if not v6[id] then
				tier = v8.tier
			end

			table.insert(result, {
				result = v10,
				tier = tier,
				id = id
			})
		end

		return result
	end

	local value4 = object:Value("Craft")
	local v7

	if TierTransfer.Offered(station) then
		v7 = TierTransfer.new(object, station)
	else
		v7 = nil
	end

	local v8 = v7 == nil and 0 or 0.07
	object:Connect(value4.Changed, function()
		value3:Set("")
	end)
	local value5 = object:Value(UDim2.new(1, 0, 0, 20))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function uiScale()
		local uIScale = instance:FindFirstChildOfClass("UIScale")

		if uIScale == nil or not (uIScale.Scale > 0) then
			return 1
		end

		return uIScale.Scale
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rowSpace(object2)
		local space = object:Space(function(state)
			local state2 = object2:Compare(state.Id) and 2 or state.In:Compare(true) and 1 or 0

			if state.State == state2 then
				return
			end

			if state2 == 2 then
				state.BgColor:Set(Color3.new(0.3, 0.3, 0.3))
				state.BgTransparency:Set(0.3)
				state.StrokeTransparency:Set(0.2)
				state.StrokeThickness:Set(2)
				state.NameGlowTransparency:Set(0.4)
				state.TextPosition:Set(UDim2.fromScale(0.54, 0.5))
				state.IconSize:Set(UDim2.fromScale(1.35, 1.35))
				state.IconBgRotation:Set(225)
			else
				if state2 == 1 then
					state.BgColor:Set(Color3.new(0.18, 0.18, 0.18))
					state.BgTransparency:Set(0.5)
					state.StrokeTransparency:Set(0.6)
					state.StrokeThickness:Set(1.5)
					state.NameGlowTransparency:Set(0.6)
					state.TextPosition:Set(UDim2.fromScale(0.52, 0.5))
					state.IconSize:Set(UDim2.fromScale(1.3, 1.3))
				else
					state.BgColor:Reset()
					state.BgTransparency:Reset()
					state.StrokeTransparency:Reset()
					state.StrokeThickness:Reset()
					state.NameGlowTransparency:Reset()
					state.TextPosition:Reset()
					state.IconSize:Reset()
				end

				state.IconBgRotation:Reset()
			end

			state.State = state2
		end)
		space:Connect(object2.Changed)
		return space
	end

	local function rowList(object2, p, value6, p2)
		local canvasSize = object2:Value(UDim2.new())
		return object2:Create("CanvasGroup")({
			Name = "ListMask",
			Size = UDim2.new(1, 0, 0.9299999999999999, -8),
			Position = UDim2.new(0, 0, 0.07, 8),
			BackgroundTransparency = 1,
			object2:Create("UIGradient")({
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.03, 0),
					NumberSequenceKeypoint.new(0.84, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object2:Create("ScrollingFrame")({
				Name = "recipesList",
				Size = UDim2.fromScale(1, 1),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 0,
				BackgroundTransparency = 1,
				CanvasSize = canvasSize,
				AbsoluteSizeOnChangedInit = function(_, point: Vector2)
					if point.X <= 0 then
						return
					end

					value5:Set(UDim2.new(1, 0, 0, point.X * 0.22 / uiScale()))
				end,
				object2:Create("Frame")({
					Name = "Holder",
					Size = UDim2.new(1, -4, 1, -4),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					object2:Create("UIListLayout")({
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 3),
						AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
							canvasSize:Set(UDim2.new(0, 0, 0, point.Y * 1.2 / uiScale()))
						end
					}),
					object2:Iterate(p2, function(p3, p4, p5, _)
						return ListRecipe(p5, p, value6, p4.id, p4, value5, p3)
					end)
				})
			})
		})
	end

	local function stepBar(object2, text: string, mouseButton1Click)
		local v9 = object2:Create("Frame")
		local v10 = {
			Name = "Bar",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			Size = UDim2.new(1, -8, 0.07),
			BackgroundTransparency = 1
		}
		local v11 = object2:Create("TextLabel")({
			Size = UDim2.fromScale(0.7, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansSemibold,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.25,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		local v12

		if mouseButton1Click ~= nil then
			v12 = object2:Create("TextButton")({
				Name = "Back",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0.3, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSansBold,
				Text = "Back",
				TextColor3 = Color3.fromRGB(85, 170, 255),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				MouseButton1Click = mouseButton1Click
			})
		end

		v10[1], v10[2] = v11, v12
		return v9(v10)
	end

	local space2 = rowSpace(value3) -- equivalent call inferred; original call site unknown
	local space3 = rowSpace(value) -- equivalent call inferred; original call site unknown
	local value6 = object:Value("")
	local step = "From"
	local flag = false
	local v11

	if v7 == nil then
		v11 = nil
	else
		v11 = object:Space(function(state)
			local state2 = value6:Compare(state.Id) and 2 or state.In:Compare(true) and 1 or 0

			if state.State == state2 then
				return
			end

			if state2 == 2 then
				state.BgColor:Set(Color3.new(0.3, 0.3, 0.3))
				state.BgTransparency:Set(0.3)
				state.StrokeTransparency:Set(0.2)
				state.StrokeThickness:Set(2)
				state.NameGlowTransparency:Set(0.4)
				state.TextPosition:Set(UDim2.fromScale(0.54, 0.5))
				state.IconSize:Set(UDim2.fromScale(1.35, 1.35))
				state.IconBgRotation:Set(225)
			else
				if state2 == 1 then
					state.BgColor:Set(Color3.new(0.18, 0.18, 0.18))
					state.BgTransparency:Set(0.5)
					state.StrokeTransparency:Set(0.6)
					state.StrokeThickness:Set(1.5)
					state.NameGlowTransparency:Set(0.6)
					state.TextPosition:Set(UDim2.fromScale(0.52, 0.5))
					state.IconSize:Set(UDim2.fromScale(1.3, 1.3))
				else
					state.BgColor:Reset()
					state.BgTransparency:Reset()
					state.StrokeTransparency:Reset()
					state.StrokeThickness:Reset()
					state.NameGlowTransparency:Reset()
					state.TextPosition:Reset()
					state.IconSize:Reset()
				end

				state.IconBgRotation:Reset()
			end

			state.State = state2
		end)
		v11:Connect(value6.Changed)
	end

	if v7 ~= nil then
		object:Connect(value6.Changed, function()
			if flag then
				return
			end

			local v12 = tonumber(value6:Get()) or 0
			local to

			if step == "To" then
				to = v7.To
			else
				to = v7.From
			end

			if to:Get() ~= v12 then
				to:Set(v12)
			end
		end)
	end

	local v12 = object:Create("CanvasGroup")
	local v13 = {
		Parent = instance,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = object:Animation(0, info, {
			From = 1
		}),
		Position = object:Animation(UDim2.fromScale(0, 0), info, {
			From = uDim
		}),
		OnClean = function(object2)
			return {
				GroupTransparency = object2:Animation(1, info),
				Position = object2:Animation(uDim, info)
			}
		end
	}
	local v14 = object:Create("Frame")
	local v15 = {
		Name = "BlacksmithFrame",
		CleanDelay = info.Time,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(0.4, 0.5),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.025)
		}),
		BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
	}
	local v16 = object:Create("UIGradient")({
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 0.4) }),
		Rotation = 90
	})
	local v17 = object:Create("Frame")
	local v18 = {
		Name = "ActualHolder",
		object:Create("UIShadow")({
			BlurRadius = UDim.new(1),
			Color = Color3.new(0.15, 0.15, 0.15),
			Spread = UDim2.fromScale(-0.5, -0.5)
		}),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5),
		Size = UDim2.new(0.35, 0, 1, -12),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.025)
		}),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(
					1,
					0.9
				) }),
			Rotation = 90
		}),
		BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
	}
	local v19

	if v7 ~= nil then
		v19 = object:Create("Frame")({
			Name = "Tabs",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			Size = UDim2.new(1, -8, 0.07, 0),
			BackgroundTransparency = 1,
			PageBrowser(object, value4, v, {
				Key = function(_, p)
					return p
				end,
				Label = function(_, p)
					return p
				end,
				CanClick = function()
					return v7.Busy:Get() ~= true
				end,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0, 0),
				TabSize = UDim2.fromScale(0.47, 0.85),
				Padding = UDim.new(0.06, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Center,
				Backdrop = false
			})
		})
	end

	local v20

	if v7 ~= nil then
		v20 = object:Create("Frame")({
			Name = "TransferBody",
			Position = UDim2.new(0, 0, v8, 8),
			Size = UDim2.new(1, 0, 1 - v8, -8),
			BackgroundTransparency = 1,
			object:State(function(callback, object2)
				if callback(value4) ~= "Transfer" then
					return nil
				end

				local v21 = TierTransfer.Pick(v7, callback)
				step = v21.Step
				flag = true
				value6:Set(v21.Picked)
				flag = false
				local v22 = object2:Create("Frame")
				local v23 = {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1
				}
				local v24

				if v21.Step == "To" then
					v24 = stepBar(object2, "Transfer to", function()
						if v7.Busy:Get() then
							return
						end

						v7.From:Set(0)
						v7.Step:Set("From")
					end)
				else
					v24 = stepBar(object2, "Transfer from")
				end

				do local _values = table.pack(v24, rowList(object2, v11, value6, v21.Rows)); for _k = 1, _values.n do v23[_k] = _values[_k] end end
				return v22(v23)
			end)
		})
	end

	do local _values = table.pack(v19, v20, object:Create("Frame")({
	Name = "CraftBody",
	Position = UDim2.new(0, 0, v8, v8 > 0 and 8 or 0),
	Size = UDim2.new(1, 0, 1 - v8, v8 > 0 and -8 or 0),
	BackgroundTransparency = 1,
	Visible = object:Do(function(callback)
		return callback(value4) == "Craft"
	end),
	object:Create("Frame")({
		Name = "Results",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = object:Do(function(callback)
			callback(value2)
			return #(v5[callback(value3)] or {}) < 2
		end),
		object:Create("Frame")({
			Name = "SearchbarHolder",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			Size = UDim2.new(1, -8, 0.07),
			BackgroundTransparency = 1,
			(Searchbar(object, v3, stringValue, "Search recipes", true))
		}),
		rowList(object, space2, value3, value2)
	}),
	object:State(function(callback, object2)
		local text = callback(value3)
		callback(value2)

		if #(v5[text] or {}) < 2 then
			return nil
		end

		return object2:Create("Frame")({
			Name = "Recipes",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			stepBar(object2, text, function()
				value3:Set("")
			end),
			rowList(object2, space3, value, variantRows(text))
		})
	end)
})); for _k = 1, _values.n do v18[3 + _k] = _values[_k] end end
	local v21 = v17(v18)
	local recipe = Recipe(object, value, uiScale)
	local v23

	if v7 ~= nil then
		v23 = object:State(function(callback, p)
			if callback(value4) == "Transfer" then
				return TierTransfer.View(p, v7)
			end

			return nil
		end)
	end

	v15[2], v15[3], v15[4], v15[5] = v16, v21, recipe, v23
	do local _values = table.pack(v14(v15)); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	return v12(v13)
end

return function(p)
	local station

	if p == nil then
		station = nil
	else
		station = p.Station
	end

	return function(p2, p3, p4, p5)
		return Panel(station, p2, p3, p4, p5)
	end
end