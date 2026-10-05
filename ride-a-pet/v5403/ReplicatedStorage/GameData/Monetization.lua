local Monetization = {
	AutoCollect = 1940707069,
	InfiniteRadar = 1941979126,
	InstantHatch = 1939909078,
	InfiniteBackpack = 1942165040,
	AutoCollectGift = 3612796573,
	InfiniteRadarGift = 3612796531,
	InstantHatchGift = 3690161232,
	InfiniteBackpackGift = 3612796648,
	SkipGrowth = 3611872297,
	SkipGrowthAll = 3611872338,
	SkipEggGrowth1 = 3713083397,
	SkipEggGrowth2 = 3713083424,
	SkipEggGrowth3 = 3713083447,
	SkipEggGrowth4 = 3713083551,
	SkipEggGrowth5 = 3713083607,
	SkipEggGrowthAll = 3713085161,
	SkipFuse = 3715749051,
	Restock = 3636314151,
	Rebirth1 = 3611734481,
	Rebirth2 = 3611734505,
	Rebirth3 = 3611734523,
	Rebirth4 = 3713946205,
	Rebirth5 = 3713946231,
	Rebirth6 = 3713946265,
	x10LuckUpgrade = 3707811213,
	x10LuckUpgrade2 = 3707811249,
	x10LuckUpgrade3 = 3707811283,
	UpgradeLuck = 3611726378,
	x10OfflineCash = 3611849769,
	x1DragonEgg = 3612795621,
	x3DragonEgg = 3612795687,
	x10DragonEgg = 3612795720,
	x50DragonEgg = 3612795742,
	x1GiantEgg = 3612796102,
	x3GiantEgg = 3612796121,
	x10GiantEgg = 3612796173,
	x50GiantEgg = 3612796213,
	["100K"] = 3613132713,
	["1M"] = 3613132742,
	["1B"] = 3613132765,
	x10DragonFruit = 3634975639,
	x3DragonFruit = 3634972103,
	x1DragonFruit = 3634967939,
	x10MagicApple = 3634965857,
	x3MagicApple = 3634963835,
	x1MagicApple = 3634960338,
	x10Meat = 3634956944,
	x3Meat = 3634953988,
	x1Meat = 3634942095,
	x10Bone = 3634938864,
	x3Bone = 3634936967,
	x1Bone = 3634933469,
	x10Grass = 3634931341,
	x3Grass = 3634929386,
	x1Grass = 3634925420,
	x10NameTag = 3715897515,
	x3NameTag = 3715897469,
	x1NameTag = 3715897381,
	x10EternalRadar = 3709608026,
	x3EternalRadar = 3709607958,
	x1EternalRadar = 3709607922,
	x10AngelicRadar = 3634922025,
	x3AngelicRadar = 3634918183,
	x1AngelicRadar = 3634914292,
	x10MagicRadar = 3634902703,
	x3MagicRadar = 3634897015,
	x1MagicRadar = 3634892524,
	x10CrystalRadar = 3634886031,
	x3CrystalRadar = 3634883884,
	x1CrystalRadar = 3634878366,
	x10RoyalRadar = 3634874271,
	x3RoyalRadar = 3634869761,
	x1RoyalRadar = 3634866638,
	x10AdvancedRadar = 3634862772,
	x3AdvancedRadar = 3634857497,
	x1AdvancedRadar = 3634835638,
	x10EternalLantern = 3634826184,
	x3EternalLantern = 3634823870,
	x1EternalLantern = 3634814841,
	x10MagicLantern = 3634809293,
	x3MagicLantern = 3634806588,
	x1MagicLantern = 3634801834,
	x10RoyalLantern = 3634798727,
	x3RoyalLantern = 3634795603,
	x1RoyalLantern = 3634792726,
	x10CoolLantern = 3634788041,
	x3CoolLantern = 3634784369,
	x1CoolLantern = 3634778554,
	x10BasicLantern = 3634773682,
	x3BasicLantern = 3634768162,
	x1BasicLantern = 3634754603,
	SkipGrowthTiers = {
		{
			MaxMinutes = 60,
			Product = "SkipEggGrowth1"
		},
		{
			MaxMinutes = 120,
			Product = "SkipEggGrowth2"
		},
		{
			MaxMinutes = 240,
			Product = "SkipEggGrowth3"
		},
		{
			MaxMinutes = 480,
			Product = "SkipEggGrowth4"
		},
		{
			MaxMinutes = 1e999,
			Product = "SkipEggGrowth5"
		}
	}
}

function Monetization.SkipTierFor(p)
	local v = math.max(tonumber(p) or 0, 0) / 60

	for _, skipGrowthTier in Monetization.SkipGrowthTiers do
		if v <= skipGrowthTier.MaxMinutes then
			return skipGrowthTier
		end
	end

	return Monetization.SkipGrowthTiers[#Monetization.SkipGrowthTiers]
end

function Monetization.RebirthProductFor(p)
	local v = math.max(0, (math.floor(tonumber(p) or 0))) + 1
	local v2 = nil
	local v3 = nil
	local v4 = nil

	for k, v5 in pairs(Monetization) do
		local v6

		if type(k) == "string" then
			v6 = tonumber(k:match("^Rebirth(%d+)$"))
		else
			v6 = false
		end

		if not (v6 and type(v5) == "number" and v5 > 0) then
			continue
		end

		local v7 = math.abs(v6 - v)

		if not (not v2 or v7 < v2 or v7 == v2 and v6 < v3) then
			continue
		end

		v4 = k
		v3 = v6
		v2 = v7
	end

	return v4 and Monetization[v4], v4
end

return Monetization