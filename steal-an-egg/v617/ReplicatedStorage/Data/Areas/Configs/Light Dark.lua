require(script.Parent.Parent.Types)
local dropTable = {
	{ "Dove", 37.51 },
	{ "Lamb", 26.27 },
	{ "Moth", 16.83 },
	{ "Peacock", 13.96 },
	{ "Jellyfish", 4.36 },
	{ "Centaur", 0.74 },
	{ "Pegasus", 0.31 },
	{ "ArchAngel", 0.02 }
}
local dropTable2 = {
	{ "Flame Sprite", 37.51 },
	{ "Toro", 26.27 },
	{ "Imp", 16.83 },
	{ "Demon Hound", 13.96 },
	{ "Dark Gargoyle", 4.36 },
	{ "RazorFang", 0.74 },
	{ "Skeleton Horse", 0.31 },
	{ "World Burner", 0.02 }
}

local function poolOf(items)
	local result = {}

	for _, item in items do
		table.insert(result, item[1])
	end

	return result
end

local dropTable3 = table.move(dropTable2, 1, #dropTable2, #dropTable + 1, table.clone(dropTable))
local v4 = {
	Color = Color3.fromRGB(196, 148, 255),
	DisplayName = "Angels & Demons",
	DropTable = dropTable3,
	Emoji = "☯️",
	GuardId = "Light Dark",
	Icon = "rbxassetid://129135259472825",
	IndexBatGearId = "Light Dark Staff",
	Lighting = nil,
	Rarity = 0,
	Reveal = 0,
	SubBiomes = 0,
	_id = "Light Dark"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v4.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.LightDark
v4.Reveal = {
	Flag = "LightDarkReveal",
	RevealSubBiome = "Mixed"
}
local pool = {}
local v6 = {
	Id = "Light",
	DisplayName = "Angels",
	Emoji = "👼",
	Weight = 45,
	Pool = 0,
	DropTable = 0,
	LuckRolls = 1,
	Color = 0,
	Gradient = 0,
	Props = "Light",
	Vfx = nil,
	Lighting = nil,
	Announcement = "☀️ The Light has risen over the Angels & Demons biome!",
	GuardIds = 0
}
local dropTable4 = {
	{ "Moth", 23.23 },
	{ "Peacock", 19.27 },
	{ "Jellyfish", 6.02 },
	{ "Centaur", 1.02 },
	{ "Pegasus", 0.43 },
	{ "ArchAngel", 0.03 },
	{ "Imp", 23.23 },
	{ "Demon Hound", 19.27 },
	{ "Dark Gargoyle", 6.02 },
	{ "RazorFang", 1.02 },
	{ "Skeleton Horse", 0.43 },
	{ "World Burner", 0.03 }
}
local subBiomes = {}

for _, v9 in dropTable do
	table.insert(pool, v9[1])
end

v6.Pool = pool
v6.DropTable = dropTable
v6.Color = Color3.fromRGB(255, 255, 255)
v6.Gradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(214, 226, 255))
})
v6.GuardIds = { "Light Dark Light" }
local pool2 = {}
local v10 = {
	Id = "Dark",
	DisplayName = "Demons",
	Emoji = "😈",
	Weight = 45,
	Pool = 0,
	DropTable = 0,
	LuckRolls = 1,
	Color = 0,
	Gradient = 0,
	Props = "Dark",
	Vfx = nil,
	Lighting = nil,
	Announcement = "🌑 The Dark has fallen over the Angels & Demons biome!",
	GuardIds = 0
}

for _, v11 in dropTable2 do
	table.insert(pool2, v11[1])
end

v10.Pool = pool2
v10.DropTable = dropTable2
v10.Color = Color3.fromRGB(224, 46, 46)
v10.Gradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 92, 92)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(186, 18, 18))
})
v10.GuardIds = { "Light Dark Dark" }
local pool3 = {}
local v12 = {
	Id = "Mixed",
	DisplayName = "Angels & Demons",
	Emoji = "☯️",
	Weight = 10,
	Pool = 0,
	DropTable = 0,
	LuckRolls = 1,
	Color = 0,
	Gradient = 0,
	Props = "MixedRealm",
	HidesZoneFloor = true,
	Vfx = nil,
	Lighting = nil,
	Announcement = "🌗 A rare Mixed night! The rarest Angels & Demons eggs share the biome tonight!",
	GuardIds = 0
}

for _, v13 in dropTable4 do
	table.insert(pool3, v13[1])
end

v12.Pool = pool3
v12.DropTable = dropTable4
v12.Color = Color3.fromRGB(255, 150, 150)
v12.Gradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.42, Color3.fromRGB(255, 246, 246)),
	ColorSequenceKeypoint.new(0.58, Color3.fromRGB(255, 92, 92)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(186, 18, 18))
})
v12.GuardIds = { "Light Dark Mixed" }
subBiomes[1], subBiomes[2], subBiomes[3] = v6, v10, v12
v4.SubBiomes = subBiomes
return table.freeze(v4)