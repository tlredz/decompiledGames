local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.WeightRandom)
local v2 = require3(ReplicatedStorage2.Shared.RNG.PlaytimeLuck)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
require3(script.Types)
local emoteTypes = ReplicatedStorage2.Shared.EmoteTypes
local list = {
	{
		Rarity = "Common",
		Color = Color3.fromRGB(255, 255, 255),
		Chance = 10,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote193
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(37, 121, 255),
		Chance = 50,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote183,
		VFX = "MeditationWater",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(255, 60, 60),
		Chance = 500,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote184,
		VFX = "MeditationFire",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(65, 255, 78),
		Chance = 25,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote185,
		VFX = "MeditationNature",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 219, 37),
		Chance = 2000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote186,
		VFX = "MeditationElectric",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(159, 159, 159),
		Chance = 5,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote187
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(244, 255, 44),
		Chance = 30,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote188,
		VFX = "SparklingClap",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(87, 252, 255),
		Chance = 200,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote189,
		VFX = "FrostyClap",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(242, 55, 255),
		Chance = 250,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote190,
		VFX = "HeartClap",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(255, 150, 58),
		Chance = 50000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote198,
		VFX = "SolarCharge",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(137, 52, 255),
		Chance = 100000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote191,
		VFX = "CosmicCharge",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Common",
		Color = Color3.fromRGB(114, 217, 255),
		Chance = 1000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote194,
		VFX = "SnowAngel",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 255, 255),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		Chance = 2500,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote195,
		VFX = "DarkAngel",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(47, 127, 255),
		Chance = 2500,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote196,
		VFX = "WaterAngel",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(194, 53, 255),
		Chance = 3000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote197,
		VFX = "CosmicAngel",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(255, 255, 255),
		Chance = 10000000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote492,
		VFX = "Emote492",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(29, 131, 255),
		Chance = 7500000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote493,
		VFX = "Emote493",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(34, 207, 255),
		Chance = 500000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote280,
		VFX = "OceanEmbrace",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(194, 53, 255),
		Chance = 5000000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote200,
		VFX = "AuroraSpirit",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 149, 19),
		Chance = 5000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote201,
		VFX = "HotHands",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 255, 255),
		Chance = 5000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote202,
		VFX = "FrostHands",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(180, 245, 174),
		Chance = 7500,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote203,
		VFX = "HunterHands",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(220, 43, 255),
		Chance = 10000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote204,
		VFX = "VoidBolt",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(46, 234, 255),
		Chance = 10000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote205,
		VFX = "ShockBolt",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 208, 38),
		Chance = 10000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote206,
		VFX = "SkiesAblaze",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(151, 220, 141),
		Chance = 250000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote502,
		VFX = "Emote502",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(132, 255, 123),
		Chance = 100000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote208,
		VFX = "MatrixInfusion",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(133, 249, 255),
		Chance = 200000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote211,
		VFX = "VoidShield",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(255, 81, 75),
		Chance = 1000000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote209,
		VFX = "SinisterAwakening",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(215, 159, 101),
		Chance = 2500000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote210,
		VFX = "CelestialAwakening",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(255, 52, 52),
		Chance = 150000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote217,
		VFX = "ElementalMark",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(140, 127, 241),
		Chance = 75000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote218,
		VFX = "DimensionalPit",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(255, 82, 82),
		Chance = 66666,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote282,
		VFX = "EvilSummon",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(255, 82, 82),
		Chance = 350000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote354,
		VFX = "Emote354",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(133, 249, 255),
		Chance = 15000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote355,
		VFX = "Emote355",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(255, 25, 255),
		Chance = 750000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote356,
		VFX = "Emote356",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 16, 243),
		Chance = 20000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote500,
		VFX = "Emote500",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 60, 239),
		Chance = 33333,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote501,
		VFX = "Emote501",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(144, 231, 255),
		Chance = 250000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote207,
		VFX = "CelestialLevitation",
		Play = require3(emoteTypes.EnableAndEmit),
		Disabled = true
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(184, 41, 255),
		Chance = 7500000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote216,
		VFX = "MythicalEnchanter",
		Play = require3(emoteTypes.Passive),
		Disabled = true
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(255, 89, 48),
		Chance = 10000000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote199,
		VFX = "PhoenixRebirth",
		Play = require3(emoteTypes.Passive),
		Disabled = true
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(159, 159, 159),
		Chance = 40000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote866,
		VFX = "Emote866",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(106, 255, 98),
		Chance = 150000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote867,
		VFX = "Emote867",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(159, 159, 159),
		Chance = 40000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote868,
		VFX = "Emote868",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(255, 75, 75),
		Chance = 50000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote869,
		VFX = "Emote869",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(255, 75, 75),
		Chance = 40000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote870,
		VFX = "Emote870",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Legendary",
		Color = Color3.fromRGB(255, 75, 75),
		Chance = 40000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote871,
		VFX = "Emote871",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(255, 166, 106),
		Chance = 1500000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote872,
		VFX = "Emote872",
		Play = require3(emoteTypes.Passive)
	},
	{
		Rarity = "Secret",
		Color = Color3.fromRGB(61, 171, 255),
		Chance = 3000000,
		Emote = ReplicatedStorage2.Misc.Emotes.Emote873,
		VFX = "Emote873",
		Play = require3(emoteTypes.Passive)
	}
}
local chances = {}

for k, v5 in list do
	if not v5.Disabled then
		chances[k] = 1 / v5.Chance
	end

	if v5.Rarity ~= "Secret" then
		local _ = v5.Rarity == "Legendary"
	end
end

chances[0] = 2

local function getPicker(instance, p: number?)
	local rNGLuck = instance:GetAttribute("RNGLuck") or 0

	if p then
		rNGLuck += p
	end

	if instance.MembershipType == Enum.MembershipType.Premium then
		rNGLuck += 1
	end

	local joinTime = instance:GetAttribute("JoinTime")

	if joinTime then
		local v5 = workspace:GetServerTimeNow() - joinTime

		for _, v6 in v2 do
			if v6.Time <= v5 then
				rNGLuck += v6.Luck
			end
		end
	end

	return v.getPicker(chances, rNGLuck, 0.00001), v.getWeights(chances, rNGLuck, 0.00001)
end

local mappedIds = {}

for _, v6 in list do
	mappedIds[v6.Emote.Name] = v6
end

return {
	NothingChance = 2,
	List = list,
	MappedIds = mappedIds,
	RarityColors = {
		Common = Color3.fromRGB(153, 155, 159),
		Rare = Color3.fromRGB(123, 255, 83),
		Legendary = Color3.fromRGB(255, 249, 82),
		Secret = Color3.fromRGB(0, 0, 0)
	},
	Chances = chances,
	getPicker = getPicker
}