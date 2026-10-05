local v = {
	Common = ColorSequence.new(Color3.fromRGB(236, 236, 236), Color3.fromRGB(168, 168, 168)),
	Uncommon = ColorSequence.new(Color3.fromRGB(126, 208, 110), Color3.fromRGB(45, 110, 40)),
	Rare = ColorSequence.new(Color3.fromRGB(96, 182, 255), Color3.fromRGB(16, 86, 166)),
	Epic = ColorSequence.new(Color3.fromRGB(192, 112, 255), Color3.fromRGB(86, 12, 146)),
	Legendary = ColorSequence.new(Color3.fromRGB(255, 222, 112), Color3.fromRGB(190, 140, 20)),
	Mythic = ColorSequence.new(Color3.fromRGB(255, 142, 220), Color3.fromRGB(190, 30, 140)),
	Secret = ColorSequence.new(Color3.fromRGB(206, 206, 255), Color3.fromRGB(58, 58, 92)),
	Exotic = ColorSequence.new(Color3.fromRGB(122, 255, 152), Color3.fromRGB(20, 140, 60)),
	Unreal = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 50, 180)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(16, 10, 22)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 32, 96))
	})
}
local v2 = {
	Common = Color3.fromRGB(226, 226, 226),
	Uncommon = Color3.fromRGB(146, 226, 130),
	Rare = Color3.fromRGB(126, 196, 255),
	Epic = Color3.fromRGB(206, 146, 255),
	Legendary = Color3.fromRGB(255, 226, 132),
	Mythic = Color3.fromRGB(255, 162, 226),
	Secret = Color3.fromRGB(216, 216, 255),
	Exotic = Color3.fromRGB(142, 255, 172),
	Unreal = Color3.fromRGB(196, 168, 255)
}
local colorSequence = ColorSequence.new(Color3.fromRGB(112, 112, 122), Color3.fromRGB(54, 54, 64))
local color = Color3.fromRGB(170, 170, 180)
local RarityTheme = {}

function RarityTheme.gradientFor(p: string)
	return v[p] or colorSequence
end

function RarityTheme.textColorFor(p: string)
	return v2[p] or color
end

function RarityTheme.labelFor(value: string)
	return string.upper(value)
end

return RarityTheme