local ValleyPanels = {}
local FullscreenBackdrop = require(script.Parent.FullscreenBackdrop)

function ValleyPanels.fullscreenShade(p, p2)
	return FullscreenBackdrop.bind(p, p2)
end

ValleyPanels.Ink = Color3.fromRGB(15, 26, 38)
ValleyPanels.Paper = Color3.fromRGB(232, 237, 228)
ValleyPanels.Muted = Color3.fromRGB(151, 175, 183)
ValleyPanels.Gold = Color3.fromRGB(235, 201, 137)
ValleyPanels.Blue = Color3.fromRGB(125, 205, 228)
ValleyPanels.Purple = Color3.fromRGB(184, 157, 241)

function ValleyPanels.make(className, parent, name, options)
	local instance = Instance.new(className)
	instance.Name = name

	for k, v in options or {} do
		instance[k] = v
	end

	instance.Parent = parent
	return instance
end

function ValleyPanels.corner(p, value)
	ValleyPanels.make("UICorner", p, "Corner", {
		CornerRadius = UDim.new(0, value or 10)
	})
end

function ValleyPanels.stroke(p, p2, value)
	ValleyPanels.make("UIStroke", p, "Outline", {
		Color = p2 or ValleyPanels.Muted,
		Transparency = value or 0.6,
		Thickness = 1
	})
end

function ValleyPanels.text(p, p2, text, p4, p5, p6, p7, value, p8)
	return ValleyPanels.make("TextLabel", p, p2, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(p4, p5),
		Size = UDim2.fromOffset(p6, p7),
		Text = text,
		TextColor3 = p8 or ValleyPanels.Paper,
		Font = Enum.Font.Gotham,
		TextSize = value or 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true
	})
end

function ValleyPanels.button(p, p2, text, p4, p5, p6, p7, p8)
	local v = ValleyPanels.make("TextButton", p, p2, {
		Position = UDim2.fromOffset(p4, p5),
		Size = UDim2.fromOffset(p6, p7),
		Text = text,
		BackgroundColor3 = p8 or Color3.fromRGB(36, 56, 70),
		TextColor3 = ValleyPanels.Paper,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BorderSizePixel = 0,
		AutoButtonColor = true
	})
	ValleyPanels.corner(v, 8)
	return v
end

function ValleyPanels.screen(instance, p, value)
	return ValleyPanels.make("ScreenGui", instance:WaitForChild("PlayerGui"), p, {
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = value or 65,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
end

function ValleyPanels.panel(instance, p, p2, p3)
	local v = ValleyPanels.make("Frame", instance, p .. "Shade", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.28,
		BorderSizePixel = 0,
		Visible = false,
		Active = false
	})
	ValleyPanels.fullscreenShade(instance, v)
	local v2 = ValleyPanels.make("Frame", v, p, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(p2, p3),
		BackgroundColor3 = ValleyPanels.Ink,
		BorderSizePixel = 0,
		Active = false
	})
	ValleyPanels.corner(v2, 14)
	ValleyPanels.stroke(v2, ValleyPanels.Gold, 0.5)
	local v3 = ValleyPanels.make("UIScale", v2, "Scale", {})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function layout()
		local absoluteSize = instance.AbsoluteSize

		if absoluteSize.X > 0 and absoluteSize.Y > 0 then
			v3.Scale = math.min(
				absoluteSize.X * 0.94 / v2.Size.X.Offset,
				absoluteSize.Y * 0.91 / v2.Size.Y.Offset,
				1.25
			)
		end
	end

	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	layout() -- equivalent call inferred; original call site unknown
	local button = ValleyPanels.button(v2, "Close", "×", p2 - 64, 16, 44, 40)
	button.Modal = true
	button.TextSize = 26
	return v, v2, button
end

return ValleyPanels