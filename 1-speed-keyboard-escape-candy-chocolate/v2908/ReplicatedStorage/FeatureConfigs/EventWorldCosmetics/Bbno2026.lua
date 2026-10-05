local assets = script.Parent.Parent.Auras.Assets

local function auraAttachment(childName: string)
	return assets:WaitForChild(childName):FindFirstChildWhichIsA("Attachment")
end

return {
	Trails = {
		GreenTrail = {
			Multiplier = 1.5,
			Price = 500,
			Color = ColorSequence.new(Color3.fromRGB(4, 182, 10)),
			Icon = "rbxassetid://116315544877519"
		},
		BlueTrail = {
			Multiplier = 2,
			Price = 1500,
			Color = ColorSequence.new(Color3.fromRGB(0, 73, 190)),
			Icon = "rbxassetid://72675186287041"
		},
		PurpleTrail = {
			Multiplier = 3,
			Price = 5000,
			Color = ColorSequence.new(Color3.fromRGB(136, 0, 190)),
			Icon = "rbxassetid://126782245837521"
		},
		RedTrail = {
			Multiplier = 4,
			Price = 25000,
			Color = ColorSequence.new(Color3.fromRGB(186, 0, 3)),
			Icon = "rbxassetid://131298799241304"
		},
		RainbowTrail = {
			Multiplier = 5,
			Price = 100000,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
			}),
			Icon = "rbxassetid://132750347496620"
		},
		GalaxyTrail = {
			Multiplier = 10,
			Price = 500000,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 50)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150))
			}),
			Icon = "rbxassetid://74943114716072"
		},
		CosmicTrail = {
			Multiplier = 100,
			Price = 5000000,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 100, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
			}),
			Icon = "rbxassetid://129213243546149"
		}
	},
	Auras = {
		GlowAura = {
			name = "GlowAura",
			multiplier = 1.2,
			price = 1000000,
			full_body = true,
			instance = assets:WaitForChild("GlowAura"):FindFirstChildWhichIsA("Attachment"),
			icon = "rbxassetid://96628369089363",
			color = Color3.fromRGB(183, 233, 255)
		},
		WindAura = {
			name = "WindAura",
			multiplier = 1.5,
			price = 5000000,
			instance = assets:WaitForChild("WindAura"):FindFirstChildWhichIsA("Attachment"),
			icon = "rbxassetid://100794940939749",
			color = Color3.fromRGB(104, 111, 149)
		}
	}
}