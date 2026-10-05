local HudStyle = {
	Colors = {
		Panel = Color3.fromRGB(18, 25, 35),
		Surface = Color3.fromRGB(32, 43, 56),
		Text = Color3.fromRGB(241, 246, 249),
		Muted = Color3.fromRGB(166, 184, 197),
		Blue = Color3.fromRGB(99, 184, 245),
		Mint = Color3.fromRGB(107, 226, 186),
		Gold = Color3.fromRGB(255, 205, 112),
		Red = Color3.fromRGB(255, 130, 136),
		Border = Color3.fromRGB(83, 108, 128)
	},
	make = function(className, name, parent, options)
		local instance = Instance.new(className)
		instance.Name = name

		for k, v in options or {} do
			instance[k] = v
		end

		instance.Parent = parent
		return instance
	end
}

function HudStyle.corner(p, value)
	return HudStyle.make("UICorner", "Corner", p, {
		CornerRadius = UDim.new(0, value or 12)
	})
end

function HudStyle.card(p, p2)
	local v = HudStyle.make("Frame", p, p2, {
		BackgroundColor3 = HudStyle.Colors.Panel,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0
	})
	HudStyle.corner(v)
	HudStyle.make("UIStroke", "Border", v, {
		Color = HudStyle.Colors.Border,
		Transparency = 0.55,
		Thickness = 1
	})
	return v
end

function HudStyle.text(p, p2, value, p3)
	return HudStyle.make("TextLabel", p, p2, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		TextSize = value or 16,
		TextColor3 = p3 or HudStyle.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = "",
		TextWrapped = true
	})
end

return HudStyle