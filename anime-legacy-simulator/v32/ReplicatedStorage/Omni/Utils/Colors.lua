local v = {
	Rarities = {
		Common = {
			Mode = "Default",
			Color = Color3.new(1, 1, 1),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.533333, 0.533333, 0.533333))
			})
		},
		Uncommon = {
			Mode = "Default",
			Color = Color3.new(0, 1, 0),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(0.439216, 1, 0.4))
			})
		},
		Rare = {
			Mode = "Default",
			Color = Color3.new(0, 0.615686, 1),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 0.615686, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.4, 0.811765, 1))
			})
		},
		Epic = {
			Mode = "Default",
			Color = Color3.new(0.8, 0, 1),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.8, 0, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.882353, 0.454902, 1))
			})
		},
		Legendary = {
			Mode = "Default",
			Color = Color3.new(1, 0.5, 0),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0.5, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0))
			})
		},
		Mythical = {
			Mode = "Rainbow",
			Color = Color3.new(0.615686, 0, 1),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0.701961, 0)),
				ColorSequenceKeypoint.new(0.324, Color3.new(1, 0, 0.564706)),
				ColorSequenceKeypoint.new(0.653, Color3.new(0.615686, 0, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0, 0.764706, 1))
			})
		},
		Secret = {
			Mode = "Matrix",
			Color = Color3.new(1, 0, 0),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
				ColorSequenceKeypoint.new(0.499, Color3.new(1, 0, 0)),
				ColorSequenceKeypoint.new(0.501, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
			})
		},
		Item = {
			Mode = "Wave",
			Color = Color3.new(1, 0.5, 0),
			Wave = Color3.new(1, 0.25, 0),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0.5, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0.25, 0))
			})
		},
		Mount = {
			Mode = "Wave",
			Color = Color3.new(1, 0.933333, 0),
			Wave = Color3.new(0.65098, 1, 0),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0.5, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0.25, 0))
			})
		},
		Gems = {
			Mode = "Wave",
			Color = Color3.new(0.929412, 0.0235294, 1),
			Wave = Color3.new(0.47451, 0.0901961, 0.807843),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.929412, 0.0235294, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.47451, 0.0901961, 0.807843))
			})
		},
		Shiny = {
			Mode = "Wave",
			Color = Color3.new(1, 1, 0),
			Wave = Color3.new(1, 1, 0.5),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0.5))
			})
		},
		Exclusive = {
			Mode = "Wave",
			Color = Color3.new(0.5, 0, 1),
			Wave = Color3.new(1, 0, 0.5),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.5, 0, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0.5))
			})
		}
	},
	Difficulties = {
		["Very Easy"] = Color3.fromRGB(100, 255, 100),
		Easy = Color3.fromRGB(0, 255, 0),
		Medium = Color3.fromRGB(255, 255, 0),
		Hard = Color3.fromRGB(255, 0, 0),
		Insane = Color3.fromRGB(255, 0, 255),
		Boss = Color3.fromRGB(0, 0, 255),
		Secret = Color3.fromRGB(0, 0, 0),
		Ore = Color3.fromRGB(0, 0, 255),
		["Global Boss"] = Color3.fromRGB(0, 255, 255)
	}
}

function v.GetColorSequenceFromRarity(_, p: string)
	local rarity = v.Rarities[p]

	if rarity then
		return rarity.Gradient
	end
end

function v.GetRarityColor(_, p: string)
	local rarity = v.Rarities[p]

	if rarity then
		return rarity.Color or Color3.new(0, 0, 0)
	end

	return Color3.new(0, 0, 0)
end

function v.GetDifficultColor(_, p: string)
	return v.Difficulties[p] or v.Difficulties.Easy
end

function v.ReturnFactoredColor(_, color: Color3, p: number)
	return Color3.new(color.R * p, color.G * p, color.B * p)
end

function v:Lighten(color: Color3, p: number)
	return color:Lerp(Color3.new(1, 1, 1), p)
end

function v:Darken(color: Color3, p: number)
	return color:Lerp(Color3.new(0, 0, 0), p)
end

function v.ShiftHue(_, color: Color3, p: number)
	local HSV, v2, v3 = color:ToHSV()
	local v4 = (HSV + p) % 1
	return Color3.fromHSV(v4, v2, v3)
end

function v.ReturnDarkenedGradientFromColor(_, color: Color3, p: number)
	return ColorSequence.new({ ColorSequenceKeypoint.new(0, v:Darken(color, p)), ColorSequenceKeypoint.new(1, color) })
end

function v.ReturnLightenedGradientFromColor(_, color: Color3, p: number)
	return ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, v:Lighten(color, p)) })
end

return table.freeze(v)