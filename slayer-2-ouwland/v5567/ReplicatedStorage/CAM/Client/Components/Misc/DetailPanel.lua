local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)
local StatNames = require(ReplicatedStorage.CAM.Global.StatNames)
local RarityShine = require(script.Parent.RarityShine)
local vector = Vector2.new(10, 8)

local function iconFor(p: string)
	local statsAndDebuff = BunchaIcons.StatsAndDebuffs[p]

	if statsAndDebuff ~= nil and statsAndDebuff ~= "" then
		return statsAndDebuff
	end

	local v = SkillTreeConfig[p]
	local icon

	if v ~= nil then
		icon = v.Icon
	end

	if icon == nil or icon == "" then
		return nil
	end

	return icon
end

local function formatAmount(stat: string, p: number)
	if string.find(stat, "Factor", 1, true) ~= nil or string.find(stat, "Regen", 1, true) ~= nil then
		return (`{math.round((1 + p) * 10000) / 10000}x`)
	end

	local v = math.round(p * 100) / 100

	if v > 0 then
		return (`+{v}`)
	end

	return (tostring(v))
end

local function amountText(data)
	if data.text ~= nil then
		return data.text
	end

	local amount = data.amount

	if type(amount) ~= "number" then
		return ""
	end

	local v = formatAmount(data.stat, amount)

	if data.pvp == nil then
		return v
	end

	return (`{v} ({formatAmount(data.stat, data.pvp)} vs players)`)
end

return function(thread, instance, data)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function uiScale()
		local uIScale = instance:FindFirstChildOfClass("UIScale")

		if uIScale == nil or not (uIScale.Scale > 0) then
			return 1
		end

		return uIScale.Scale
	end

	local v = math.clamp(data.Rarity, 1, #Rarities.Order)
	local v2 = Rarities.Order[v]
	local text2 = string.gsub(string.lower(v2), "%f[%a]%a", string.upper)
	local gradient = Rarities.Gradients[v]
	local color

	if gradient == nil then
		color = Rarities.Colors[v]:Lerp(Color3.new(1, 1, 1), 0.45)
	else
		color = Color3.new(1, 1, 1)
	end

	local value = thread:Value(0)
	local value2 = thread:Value(14)
	local canvasSize = thread:Value(UDim2.new())

	local function rowHeight(p: number)
		return thread:Do(function(callback)
			return UDim2.new(1, 0, 0, (math.floor(callback(value) * p)))
		end)
	end

	local function bodyTextSize()
		return thread:Do(function(callback)
			return (math.min(100, (math.floor(callback(value2) * 1.2291666666666667))))
		end)
	end

	local function sectionHeader(text: string, layoutOrder: number)
		return thread:Create("TextLabel")({
			Name = `{text}Header`,
			LayoutOrder = layoutOrder,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansBold,
			Text = text,
			TextWrapped = true,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = thread:Do(function(callback)
				return (math.min(100, (math.floor(callback(value2) * 1.2291666666666667))))
			end)
		})
	end

	local function statSection(header: string, lines, layoutOrder: number)
		if #lines == 0 then
			return nil
		end

		local v4 = thread:Create("Frame")
		local v5 = {
			Name = `{header}Section`,
			LayoutOrder = layoutOrder,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1
		}
		local v9 = 0.06
		do local _values = table.pack(thread:Create("UIListLayout")({
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	SortOrder = Enum.SortOrder.LayoutOrder
}), thread:Create("Frame")({
	Name = "Gap",
	LayoutOrder = 0,
	Size = thread:Do(function(callback)
		return UDim2.new(1, 0, 0, (math.floor(callback(value) * v9)))
	end),
	BackgroundTransparency = 1
}), sectionHeader(header, 1), thread:Iterate(lines, function(p2: number, data2, object2)
	local stat = data2.stat
	local icon = BunchaIcons.StatsAndDebuffs[stat]

	if icon == nil or icon == "" then
		local v10 = SkillTreeConfig[stat]

		if v10 == nil then
			icon = nil
		else
			icon = v10.Icon
		end

		if icon == nil or icon == "" then
			icon = nil
		end
	end

	local text

	if data2.text == nil then
		local amount = data2.amount

		if type(amount) == "number" then
			text = formatAmount(data2.stat, amount)

			if data2.pvp ~= nil then
				text = `{text} ({formatAmount(data2.stat, data2.pvp)} vs players)`
			end
		else
			text = ""
		end
	else
		text = data2.text
	end

	local text3 = StatNames.Get(data2.stat)
	local v11 = object2:Create("Frame")
	local v12 = {
		Name = data2.stat,
		LayoutOrder = p2 + 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1
	}
	local v13 = object2:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	})
	local v14

	if icon ~= nil then
		v14 = object2:Create("ImageLabel")({
			Name = "Icon",
			LayoutOrder = 1,
			Size = object2:Do(function(callback)
				local v15 = math.floor(callback(value) * 0.135 * 0.9)
				return UDim2.fromOffset(v15, v15)
			end),
			BackgroundTransparency = 1,
			Image = icon
		}) or nil
	end

	local v15 = object2:Create("TextLabel")
	local v16 = {
		Name = "Amount",
		LayoutOrder = 2,
		Size = object2:Do(function(callback)
			local v17 = math.floor(callback(value) * 0.135)
			return UDim2.new(1, icon == nil and 0 or -math.floor(v17 * 0.9) - 4, 0, v17)
		end),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansSemibold,
		Text = 0,
		RichText = true,
		TextColor3 = 0,
		TextTransparency = 0.25,
		TextXAlignment = 0,
		TextWrapped = true,
		TextSize = 0
	}

	if text ~= "" then
		text3 = `{text} <i><font transparency="{0.4}">({text3})</font></i>`
	end

	v16.Text = text3
	v16.TextColor3 = Color3.new(1, 1, 1)
	v16.TextXAlignment = Enum.TextXAlignment.Left
	v16.TextSize = object2:Do(function(callback)
		return (math.min(100, (math.floor(callback(value) * 0.135 * 0.8))))
	end)
	do local _values = table.pack(v13, v14, v15(v16)); for _k = 1, _values.n do v12[_k] = _values[_k] end end
	return v11(v12)
end)); for _k = 1, _values.n do v5[_k] = _values[_k] end end
		return v4(v5)
	end

	local result = {}

	for k, v4 in data.Tags or {} do
		local v5 = thread:Create("Frame")
		local v6 = {
			Name = `{v4.Text}Tag`,
			LayoutOrder = k
		}
		local v8 = 0.096
		v6.Size = thread:Do(function(callback)
			return UDim2.new(1, 0, 0, (math.floor(callback(value) * v8)))
		end)
		v6.BackgroundTransparency = 1
		local v9 = thread:Create("Frame")({
			Name = "Bg",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.65,
			thread:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.35),
					NumberSequenceKeypoint.new(0.7, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			thread:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		})
		local v10 = thread:Create("Frame")
		local v11 = {
			Name = "Content",
			ZIndex = 2,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		}
		local v12 = thread:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4)
		})
		local v13

		if v4.Icon ~= nil then
			v13 = thread:Create("ImageLabel")({
				Name = "Icon",
				LayoutOrder = 1,
				ZIndex = 2,
				Size = thread:Do(function(callback)
					local v14 = math.floor(callback(value) * 0.096)
					return UDim2.fromOffset(v14, v14)
				end),
				BackgroundTransparency = 1,
				Image = v4.Icon
			}) or nil
		end

		do local _values = table.pack(v12, v13, thread:Create("TextLabel")({
	Name = "Text",
	LayoutOrder = 2,
	ZIndex = 2,
	Size = UDim2.fromScale(10, 1),
	BackgroundTransparency = 1,
	Font = Enum.Font.SourceSansSemibold,
	Text = v4.Text,
	TextColor3 = Color3.new(1, 1, 1),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextScaled = true
})); for _k = 1, _values.n do v11[_k] = _values[_k] end end
		do local _values = table.pack(v9, v10(v11)); for _k = 1, _values.n do v6[_k] = _values[_k] end end
		table.insert(result, v5(v6))
	end

	local result2 = {}
	local v4 = {
		Thread = thread,
		rowHeight = rowHeight,
		sectionHeader = sectionHeader,
		bodyTextSize = bodyTextSize,
		SECTION_GAP = 0.06,
		ROW_GAP = 4
	}

	for k, section in data.Sections do
		local v5 = statSection(section.Header, section.Lines, k * 100)

		if v5 ~= nil then
			table.insert(result2, v5)
		end
	end

	local v5 = thread:Create("ScrollingFrame")
	local v6 = {
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
		end
	}
	local v7 = thread:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
			canvasSize:Set(UDim2.fromOffset(0, point.Y * 1.2 / uiScale()))
		end
	})
	local v8 = thread:Create("Frame")
	local v9 = {
		Name = "NameRow",
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1
	}
	local v10 = thread:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	})
	local v11

	if data.Locked == true then
		v11 = thread:Create("ImageLabel")({
			Name = "Lock",
			LayoutOrder = 1,
			Size = thread:Do(function(callback)
				local v12 = math.floor(callback(value) * 0.144 * 0.8)
				return UDim2.fromOffset(v12, v12)
			end),
			BackgroundTransparency = 1,
			Image = data.LockIcon or BunchaIcons.Locked
		}) or nil
	end

	local v12

	if data.Mark ~= nil then
		v12 = thread:Create("ImageLabel")({
			Name = "Mark",
			LayoutOrder = 1,
			Size = thread:Do(function(callback)
				local v13 = math.floor(callback(value) * 0.144 * 0.8)
				return UDim2.fromOffset(v13, v13)
			end),
			BackgroundTransparency = 1,
			Image = data.Mark
		}) or nil
	end

	local v13 = thread:Create("TextLabel")
	local v14 = {
		Name = "EntryName",
		LayoutOrder = 2,
		Size = thread:Do(function(callback)
			local v15 = math.floor(callback(value) * 0.144)
			local v16 = (data.Locked == true and 1 or 0) + (data.Mark == nil and 0 or 1)
			return UDim2.new(1, -v16 * (math.floor(v15 * 0.8) + 4), 0, v15)
		end),
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansBold,
		Text = data.Name,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = false,
		TextSize = thread:Do(function(callback)
			return (math.min(100, (math.floor(callback(value) * 0.144))))
		end)
	}
	local v15

	if data.Color ~= nil then
		v15 = thread:Create("UIGradient")({
			Color = data.Color,
			Rotation = -90
		}) or nil
	end

	v14[1] = v15
	do local _values = table.pack(v10, v11, v12, v13(v14)); for _k = 1, _values.n do v9[_k] = _values[_k] end end
	local v16 = v8(v9)
	local v17 = thread:Create("Frame")
	local v18 = {
		Name = "Subtitle",
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1
	}
	local v19 = thread:Create("UIListLayout")({
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	})
	local v20 = thread:Create("Frame")
	local v22 = 0.096
	local v21 = {
		Name = "RarityRow",
		LayoutOrder = 0,
		Size = thread:Do(function(callback)
			return UDim2.new(1, 0, 0, (math.floor(callback(value) * v22)))
		end),
		BackgroundTransparency = 1
	}
	local v23 = thread:Create("Frame")
	local v24 = {
		Name = "Bg",
		Size = UDim2.fromScale(1, 1)
	}
	local backgroundColor

	if gradient == nil then
		backgroundColor = Rarities.Colors[v]
	else
		backgroundColor = Color3.new(1, 1, 1)
	end

	v24.BackgroundColor3 = backgroundColor
	v24.BackgroundTransparency = 0.65
	do local _values = table.pack(thread:Create("UIGradient")({
	Color = gradient,
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 1) })
}), thread:Create("UICorner")({
	CornerRadius = UDim.new(1)
})); for _k = 1, _values.n do v24[_k] = _values[_k] end end
	do local _values = table.pack(v23(v24), thread:Create("TextLabel")({
	Name = "Rarity",
	ZIndex = 2,
	Size = UDim2.fromScale(10, 1),
	BackgroundTransparency = 1,
	Font = Enum.Font.SourceSansSemibold,
	Text = text2,
	TextColor3 = color,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextScaled = true,
	TextBoundsOnChangedInit = function(_, point: Vector2)
		if point.Y <= 0 then
			return
		end

		local v26 = value:Get() * 0.096

		if v26 <= 0 then
			return
		end

		local Y = point.Y
		value2:Set((math.clamp(math.floor(Y / uiScale()), 1, (math.floor(v26)))))
	end,
	RarityShine(v, "Drift")
})); for _k = 1, _values.n do v21[_k] = _values[_k] end end
	v18[1], v18[2], v18[3] = v19, v20(v21), function()
	return result
end
	v6[1], v6[2], v6[3], v6[4], v6[5] = v7, v16, v17(v18), data.Extra ~= nil and (function()
	return data.Extra(v4)
end or nil) or nil, function()
	return result2
end
	return v5(v6)
end