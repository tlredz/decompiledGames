require(script.Parent.SpinnerTypes)
local v = {
	Common = table.freeze({
		UnderGlowColor = Color3.fromRGB(179, 179, 179),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(179, 179, 179)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(179, 179, 179))
		})
	}),
	Uncommon = table.freeze({
		UnderGlowColor = Color3.fromRGB(92, 140, 211),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(92, 140, 211)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(173, 209, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(92, 140, 211))
		})
	}),
	Rare = table.freeze({
		UnderGlowColor = Color3.fromRGB(140, 82, 255),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 82, 255)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(204, 168, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 82, 255))
		})
	}),
	Legendary = table.freeze({
		UnderGlowColor = Color3.fromRGB(213, 43, 228),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(213, 43, 228)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 141, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 43, 228))
		})
	}),
	Mythical = table.freeze({
		UnderGlowColor = Color3.fromRGB(238, 47, 50),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(238, 47, 50)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 133, 136)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 47, 50))
		})
	}),
	Premium = table.freeze({
		UnderGlowColor = Color3.fromRGB(221, 188, 0),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(221, 188, 0)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 231, 105)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(221, 188, 0))
		})
	}),
	Bronze = table.freeze({
		UnderGlowColor = Color3.fromRGB(138, 96, 5),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 96, 5)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 191, 54)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 96, 5))
		})
	}),
	Silver = table.freeze({
		UnderGlowColor = Color3.fromRGB(164, 164, 164),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(103, 103, 103)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(164, 164, 164)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(103, 103, 103))
		})
	}),
	Gold = table.freeze({
		UnderGlowColor = Color3.fromRGB(255, 199, 29),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 199, 29)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 239, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
		})
	}),
	Platinum = table.freeze({
		UnderGlowColor = Color3.fromRGB(213, 213, 213),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(197, 197, 197)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(237, 237, 237)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(197, 197, 197))
		})
	}),
	Default = table.freeze({
		UnderGlowColor = Color3.fromRGB(0, 136, 255),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 136, 255)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(76, 172, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 136, 255))
		})
	}),
	Pink = table.freeze({
		UnderGlowColor = Color3.fromRGB(255, 170, 255),
		HeaderTextColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 255)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(186, 124, 186)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 255))
		})
	})
}
return table.freeze(v)