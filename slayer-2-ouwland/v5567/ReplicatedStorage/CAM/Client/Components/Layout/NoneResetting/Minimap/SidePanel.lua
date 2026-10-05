local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local RecommendedQuest = require(ReplicatedStorage.CAM.Client.Modules.RecommendedQuest)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Toggle = require(ReplicatedStorage.CAM.Client.Components.Misc.Toggle)
local MapKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.MapKeys)
local MapSettings = require(ReplicatedStorage.CAM.Client.Modules.MapSettings)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local vector = Vector2.new(10, 8)
local sourceSansBold = Enum.Font.SourceSansBold
local sourceSansBold2 = Enum.Font.SourceSansBold
local sourceSansSemibold = Enum.Font.SourceSansSemibold
local color = Color3.fromRGB(255, 176, 46)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.35),
	NumberSequenceKeypoint.new(0.7, 1),
	NumberSequenceKeypoint.new(1, 1)
})
local sourceSans = Enum.Font.SourceSans
local BOOK = RecommendedQuest.BOOK
local color2 = Color3.fromRGB(255, 176, 46)
local v = { "Recommended Quest", "Map Settings" }

local function shortName(value: string)
	if #value <= 20 then
		return value
	end

	return string.sub(value, 1, 18) .. ".."
end

return function(maid, instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function uiScale()
		local uIScale = instance:FindFirstChildOfClass("UIScale")

		if uIScale == nil or not (uIScale.Scale > 0) then
			return 1
		end

		return uIScale.Scale
	end

	local value = maid:Value(0)
	local canvasSize = maid:Value(UDim2.new())

	local function rowHeight(p: number)
		return maid:Do(function(callback)
			return UDim2.new(1, 0, 0, (math.floor(callback(value) * p)))
		end)
	end

	local function sectionHeader(text: string, layoutOrder: number, p3: number)
		return maid:Create("TextLabel")({
			Name = `{text}Header`,
			LayoutOrder = layoutOrder,
			Size = maid:Do(function(callback)
				return UDim2.new(7, 0, 0, (math.floor(callback(value) * (p3 + 0.1))))
			end),
			BackgroundTransparency = 1,
			Font = sourceSansBold,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = true,
			maid:Create("UIPadding")({
				PaddingTop = maid:Do(function(callback)
					return UDim.new(0, (math.floor(callback(value) * p3)))
				end)
			})
		})
	end

	local value3 = maid:Value(RecommendedQuest.Get())
	maid:Add(RecommendedQuest.Changed:Connect(function(p)
		value3:Set(p)
	end))
	local data = Utility.GetData(Players.LocalPlayer)
	local inventory

	if data ~= nil then
		inventory = data:FindFirstChild("Inventory") or nil
	end

	local v2

	if inventory == nil then
		v2 = nil
	else
		v2 = inventory:FindFirstChild("Inventory") or nil
	end

	local function ownsBook()
		if v2 == nil then
			return false
		end

		for _, child in v2:GetChildren() do
			if child.Name == BOOK then
				return true
			end
		end

		return false
	end

	local v4

	if v2 == nil then
		v4 = false
	else
		local flag = true

		for _, child in v2:GetChildren() do
			if child.Name ~= BOOK then
				continue
			end

			v4 = true
			flag = false
			break
		end

		if flag then
			v4 = false
		end
	end

	local value4 = maid:Value(v4)

	local function recheck()
		local v6

		if v2 == nil then
			v6 = false
		else
			local flag = true

			for _, child in v2:GetChildren() do
				if child.Name ~= BOOK then
					continue
				end

				v6 = true
				flag = false
				break
			end

			if flag then
				v6 = false
			end
		end

		value4:Set(v6)
	end

	if v2 ~= nil then
		maid:Connect(v2.ChildAdded, recheck)
		maid:Connect(v2.ChildRemoved, recheck)
	end

	local function bookBlock(object, layoutOrder: number)
		local item = Items[BOOK]
		local v5 = object:Create("Frame")
		local v6 = {
			Name = "Locked",
			LayoutOrder = layoutOrder,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			CleanDelay = 0.2
		}
		local v11 = 0.096
		local v15 = 0.084
		do local _values = table.pack(object:Create("UIListLayout")({
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 2)
}), object:Create("ImageLabel")({
	Name = "Icon",
	LayoutOrder = 1,
	Size = object:Do(function(callback)
		local v9 = math.floor(callback(value) * 0.3)
		return UDim2.fromOffset(v9, v9)
	end),
	BackgroundTransparency = 1,
	Image = item == nil and "" or item.Icon or "",
	object:Create("ImageLabel")({
		Name = "Lock",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.55, 0.55),
		BackgroundTransparency = 1,
		Image = BunchaIcons.Locked,
		object:Create("UIShadow")({
			BlurRadius = UDim.new(0.5, 0),
			Offset = UDim2.fromScale(0.05, 0.05),
			Transparency = 0.65
		})
	})
}), object:Create("TextLabel")({
	Name = "Name",
	LayoutOrder = 2,
	Size = maid:Do(function(callback)
		return UDim2.new(1, 0, 0, (math.floor(callback(value) * v11)))
	end),
	BackgroundTransparency = 1,
	Font = sourceSansSemibold,
	Text = BOOK,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true
}), object:Create("TextLabel")({
	Name = "Unlock",
	LayoutOrder = 3,
	Size = maid:Do(function(callback)
		return UDim2.new(1, 0, 0, (math.floor(callback(value) * v15)))
	end),
	BackgroundTransparency = 1,
	Font = sourceSansSemibold,
	Text = "Unlock at Windy Peak",
	TextColor3 = color2,
	TextScaled = true
})); for _k = 1, _values.n do v6[_k] = _values[_k] end end
		return v5(v6)
	end

	local function questRows(layoutOrder: number)
		return maid:State(function(callback, object)
			if callback(value4) ~= true then
				return bookBlock(object, layoutOrder)
			end

			local v5 = callback(value3)

			if v5 == nil then
				return
			end

			local v6 = object:Create("Frame")
			local v7 = {
				Name = "Recommended",
				LayoutOrder = layoutOrder,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				CleanDelay = 0.2
			}
			local v8 = object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder
			})
			local v9 = object:Create("Frame")
			local v11 = 0.135
			local v10 = {
				Name = "Giver",
				LayoutOrder = 1,
				Size = maid:Do(function(callback2)
					return UDim2.new(1, 0, 0, (math.floor(callback2(value) * v11)))
				end),
				BackgroundColor3 = color,
				BackgroundTransparency = 0.65
			}
			local v12 = object:Create("UIGradient")({
				Transparency = numberSequence
			})
			local v13 = object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
			local v14 = object:Create("UIPadding")({
				PaddingLeft = UDim.new(0, 6)
			})
			local v15 = object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			})
			local v16 = object:Create("ImageLabel")({
				Name = "Icon",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.9, 0.9),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = v5.Icon or ""
			})
			local v17 = object:Create("TextLabel")
			local v18 = {
				Name = "Name",
				LayoutOrder = 2,
				Size = UDim2.fromScale(7, 0.8),
				BackgroundTransparency = 1,
				Font = sourceSansSemibold,
				Text = 0,
				TextColor3 = 0,
				TextXAlignment = 0,
				TextScaled = true
			}
			local npc = v5.Npc

			if not (#npc <= 20) then
				npc = string.sub(npc, 1, 18) .. ".."
			end

			v18.Text = npc
			v18.TextColor3 = Color3.new(1, 1, 1)
			v18.TextXAlignment = Enum.TextXAlignment.Left
			do local _values = table.pack(v12, v13, v14, v15, v16, v17(v18)); for _k = 1, _values.n do v10[_k] = _values[_k] end end
			local v22 = 0.135
			do local _values = table.pack(v8, v9(v10), object:Create("Frame")({
	Name = "Quest",
	LayoutOrder = 2,
	Size = maid:Do(function(callback2)
		return UDim2.new(1, 0, 0, (math.floor(callback2(value) * v22)))
	end),
	BackgroundTransparency = 1,
	object:Create("UIPadding")({
		PaddingLeft = object:Do(function(callback2)
			return UDim.new(0, (math.floor(callback2(value) * 0.08)))
		end)
	}),
	object:Create("TextLabel")({
		Name = "Name",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(7, 0.7),
		BackgroundTransparency = 1,
		Font = sourceSans,
		Text = v5.Name,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextScaled = true
	})
})); for _k = 1, _values.n do v7[_k] = _values[_k] end end
			return v6(v7)
		end)
	end

	local v5 = {}

	for k, v6 in v do
		table.insert(v5, sectionHeader(v6, 100 * k, k > 1 and 0.03 or 0))
	end

	table.insert(v5, questRows(101))
	table.insert(v5, maid:Create("Frame")({
		Name = "MapSettings",
		LayoutOrder = 201,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		maid:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 3)
		}),
		maid:Iterate(MapKeys.Groups, function(layoutOrder: number, p2: string, object)
			local groupRequire = MapKeys.GroupRequires[p2]
			local visible = object:Value(groupRequire == nil)

			if groupRequire ~= nil then
				object:Spawn(function()
					for _, v6 in groupRequire do
						if not Shop.OwnsGamepassListing(Players.LocalPlayer, v6) then
							continue
						end

						visible:Set(true)
						break
					end
				end)
			end

			return object:Create("Frame")({
				Name = p2,
				Visible = visible,
				LayoutOrder = layoutOrder,
				CleanDelay = 0.2,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				object:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 3)
				}),
				object:Create("TextLabel")({
					Name = "Header",
					LayoutOrder = 0,
					Size = object:Do(function(callback)
						return UDim2.new(7, 0, 0, (math.floor(callback(value) * 0.08399999999999999)))
					end),
					BackgroundTransparency = 1,
					Font = sourceSansBold2,
					Text = p2,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.25,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					object:Create("UIPadding")({
						PaddingTop = object:Do(function(callback)
							return UDim.new(0, (math.floor(callback(value) * 0.024)))
						end)
					})
				}),
				object:Iterate(MapKeys.ByGroup[p2], function(layoutOrder2: number, p4, object2)
					local v6, v7 = MapSettings.Watch(object2, p4.Name)
					object2:Connect(v6.Changed, function()
						v7(v6:Compare(true))
					end)
					local v8 = object2:Create("Frame")
					local v9 = {
						Name = p4.Name,
						LayoutOrder = layoutOrder2,
						CleanDelay = 0.2
					}
					local v10 = 0.144
					v9.Size = maid:Do(function(callback)
						return UDim2.new(1, 0, 0, (math.floor(callback(value) * v10)))
					end)
					v9.BackgroundTransparency = 1
					do local _values = table.pack(Toggle(object2, v6, p4.Label, {
	Size = UDim2.fromScale(1, 1),
	Fade = true,
	TextSize = object2:Do(function(callback)
		return (math.floor(callback(value) * 0.144 * 0.408))
	end)
})); for _k = 1, _values.n do v9[_k] = _values[_k] end end
					return v8(v9)
				end)
			})
		end)
	}))
	return maid:Create("ScrollingFrame")({
		Name = "Content",
		Position = UDim2.fromOffset(vector.X, vector.Y),
		Size = UDim2.new(1, -vector.X * 2, 1, -vector.Y * 2),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = canvasSize,
		ClipsDescendants = false,
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			if point.X <= 0 then
				return
			end

			value:Set(point.X / uiScale())
		end,
		maid:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
				canvasSize:Set(UDim2.fromOffset(0, point.Y * 1.2 / uiScale()))
			end
		}),
		v5
	})
end