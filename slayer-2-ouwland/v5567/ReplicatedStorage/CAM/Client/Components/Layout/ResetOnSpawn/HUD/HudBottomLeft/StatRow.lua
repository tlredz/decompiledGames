local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)

local function iconFor(p: string)
	local statsAndDebuff = BunchaIcons.StatsAndDebuffs[p]

	if statsAndDebuff ~= nil then
		return statsAndDebuff
	end

	local v = SkillTreeConfig[p]
	return v ~= nil and v.Icon or nil
end

require(ReplicatedStorage.Packages.faye)
local HoverInfo = require(ReplicatedStorage.CAM.Client.Modules.HoverInfo)
return function(object, p: string, data)
	local v = HoverInfo.new(nil, p)
	local v2 = object:Create("Frame")
	local v3 = {
		Name = `{p} Holder`,
		MouseEnter = function()
			v:Enter()
		end,
		MouseLeave = function()
			v:Leave()
		end,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0.75,
		BackgroundColor3 = Color3.new()
	}
	local v4 = object:Create("UICorner")({
		CornerRadius = UDim.new(1)
	})
	local v5 = object:Create("UIStroke")({
		BorderOffset = UDim.new(0, -2),
		Color = Color3.new(1, 1, 1),
		Transparency = 0.85
	})
	local v6 = object:Create("UIGradient")({
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.4, 0.7),
			NumberSequenceKeypoint.new(1, 0.8)
		}),
		Rotation = -90
	})
	local v7 = object:Create("UIShadow")({
		BlurRadius = UDim.new(1),
		Transparency = 0.5,
		Spread = UDim2.fromScale(0.4, -0.1)
	})
	local v8 = object:Create("UIListLayout")({
		Name = "List",
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 2)
	})
	local v9 = object:Create("Frame")
	local v10 = {
		Name = "AImageHolder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}
	local v11 = object:Create("ImageLabel")
	local v12 = {
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.5, 1.5),
		BackgroundTransparency = 1,
		Image = 0,
		ImageTransparency = 0
	}
	local icon = BunchaIcons.StatsAndDebuffs[p]

	if icon == nil then
		local v13 = SkillTreeConfig[p]
		icon = v13 ~= nil and v13.Icon or nil
	end

	v12.Image = icon
	v12.ImageTransparency = data.Dim
	do local _values = table.pack(v11(v12)); for _k = 1, _values.n do v10[_k] = _values[_k] end end
	do local _values = table.pack(v4, v5, v6, v7, v8, v9(v10), object:Create("Frame")({
	Size = UDim2.new(0, 0, 1, 0),
	Name = "BTextHolder",
	BackgroundTransparency = 1,
	object:Create("TextLabel")({
		Name = "Amount",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(100, 1),
		BackgroundTransparency = 1,
		Text = data.Text,
		TextScaled = true,
		TextColor3 = data.Tint,
		TextTransparency = data.Dim,
		Font = Enum.Font.SourceSansSemibold,
		TextBoundsOnChangedInit = function(p2, point: Vector2)
			p2.Parent.Size = UDim2.new(0, not (point.X > 0) and 0 or point.X + 10, 1, 0)
		end
	})
})); for _k = 1, _values.n do v3[_k] = _values[_k] end end
	return v2(v3)
end