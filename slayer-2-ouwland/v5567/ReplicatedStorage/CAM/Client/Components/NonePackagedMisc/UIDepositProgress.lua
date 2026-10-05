local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Row = require(script.Row)
local color = Color3.new(1, 1, 1)
local info = faye.Info(0.3)
local info2 = faye.Info(0.3, Enum.EasingStyle.Back)

local function fadeOutOnClean(udim: UDim2)
	return function(animator, folder)
		animator:LoadAnimation(folder, {
			BackgroundTransparency = 1
		}, info):Play()

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("GuiObject") then
				animator:LoadAnimation(descendant, {
					BackgroundTransparency = 1
				}, info):Play()
			end

			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				animator:LoadAnimation(descendant, {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}, info):Play()
			end

			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				animator:LoadAnimation(descendant, {
					ImageTransparency = 1
				}, info):Play()
			end

			if descendant:IsA("UIStroke") or descendant:IsA("UIShadow") then
				animator:LoadAnimation(descendant, {
					Transparency = 1
				}, info):Play()
			end
		end

		return {
			Size = animator:Animation(udim, info)
		}
	end
end

return function(parent, list, text: string?)
	if list == nil then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function previewValue(p2: number)
			local intValue = Instance.new("IntValue")
			intValue.Value = p2
			return intValue
		end

		list = {
			{
				Item = "Health Elixir",
				Value = previewValue(3),
				Max = previewValue(10)
			},
			{
				Item = "Health Regen Elixir",
				Value = previewValue(10),
				Max = previewValue(10)
			},
			{
				Item = "Stamina Regen Elixir",
				Value = previewValue(0),
				Max = previewValue(10)
			}
		}
		text = text or "Infirmary Restock"
	end

	local v = faye.new()
	local v2 = (0.88 - #list * 0.02) / (#list + 1)
	local v3 = v:Create("Frame")
	local v4 = {
		Parent = parent,
		Name = "Root",
		Size = v:Animation(UDim2.fromScale(1, 1), info2, {
			From = UDim2.fromScale(0.85, 0.85)
		}),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5)
	}
	local uDim = UDim2.fromScale(0.85, 0.85)

	function v4.OnClean(animator, folder)
		animator:LoadAnimation(folder, {
			BackgroundTransparency = 1
		}, info):Play()

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("GuiObject") then
				animator:LoadAnimation(descendant, {
					BackgroundTransparency = 1
				}, info):Play()
			end

			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				animator:LoadAnimation(descendant, {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}, info):Play()
			end

			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				animator:LoadAnimation(descendant, {
					ImageTransparency = 1
				}, info):Play()
			end

			if descendant:IsA("UIStroke") or descendant:IsA("UIShadow") then
				animator:LoadAnimation(descendant, {
					Transparency = 1
				}, info):Play()
			end
		end

		return {
			Size = animator:Animation(uDim, info)
		}
	end

	do local _values = table.pack(v:Create("Frame")({
	Name = "Bg",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, -4, 1, -4),
	BackgroundColor3 = Color3.new(0.075, 0.075, 0.075),
	BackgroundTransparency = v:Animation(0, info, {
		From = 1
	}),
	v:Create("UIGradient")({
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.9) }),
		Rotation = 90
	}),
	v:Create("UICorner")({
		CornerRadius = UDim.new(0.12, 0)
	}),
	v:Create("UIStroke")({
		BorderOffset = UDim.new(0, -4),
		Transparency = v:Animation(0.75, info, {
			From = 1
		}),
		Color = color
	}),
	v:Create("UIPadding")({
		PaddingTop = UDim.new(0.06, 0),
		PaddingBottom = UDim.new(0.06, 0),
		PaddingLeft = UDim.new(0.06, 0),
		PaddingRight = UDim.new(0.06, 0)
	}),
	v:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0.02, 0)
	}),
	v:Create("TextLabel")({
		Name = "Title",
		LayoutOrder = 0,
		Size = UDim2.fromScale(0.75, v2),
		BackgroundTransparency = 1,
		Text = text,
		TextScaled = true,
		Font = Enum.Font.SourceSansSemibold,
		TextColor3 = color,
		TextTransparency = v:Animation(0, info, {
			From = 1
		}),
		v:Create("UIStroke")({
			Thickness = 2,
			Color = Color3.new(0, 0, 0),
			Transparency = v:Animation(0, info, {
				From = 1
			}),
			v:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 1) }),
				Rotation = -90
			})
		})
	}),
	v:Iterate(list, function(p2, p3, p4)
		return Row(p4, p2, p3, v2)
	end)
})); for _k = 1, _values.n do v4[_k] = _values[_k] end end
	v3(v4)
	return function()
		v:Destroy()
	end
end