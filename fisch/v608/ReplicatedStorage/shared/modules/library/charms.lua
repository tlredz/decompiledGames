local count = 0

local function inc()
	count += 1
	return count
end

local swiftnessCharm = {
	ShortName = "Swiftness",
	Icon = "rbxassetid://136594788108497",
	Color = Color3.fromRGB(164, 195, 232),
	Order = 0,
	TargetStat = "Lure",
	BaseStatBoost = 1,
	StatBoostPerLevel = 1,
	IdolName = "Hayate Idol",
	IdolTag = "SwiftnessIdol",
	IdolZone = "Skycrest",
	Hint = "Complete the Hayate Idol's first 5 quests to unlock"
}
count += 1
swiftnessCharm.Order = count
local fortuneCharm = {
	ShortName = "Fortune",
	Icon = "rbxassetid://127616480328932",
	Color = Color3.fromRGB(108, 171, 79),
	Order = 0,
	TargetStat = "Luck",
	BaseStatBoost = 2,
	StatBoostPerLevel = 2,
	IdolName = "Ebisu Idol",
	IdolTag = "FortuneIdol",
	IdolZone = "Skycrest",
	Hint = "Complete the Ebisu Idol's first 5 quests to unlock"
}
count += 1
fortuneCharm.Order = count
local enduranceCharm = {
	ShortName = "Endurance",
	Icon = "rbxassetid://89016904991149",
	Color = Color3.fromRGB(218, 104, 103),
	Order = 0,
	TargetStat = "Control",
	BaseStatBoost = 0.015,
	StatBoostPerLevel = 0.0025,
	IdolName = "Fudo Idol",
	IdolTag = "EnduranceIdol",
	IdolZone = "Skycrest",
	Hint = "Complete the Fudo Idol's first 5 quests to unlock"
}
count += 1
enduranceCharm.Order = count
local relaxationCharm = {
	ShortName = "Relaxation",
	Icon = "rbxassetid://128629011009345",
	Color = Color3.fromRGB(224, 149, 59),
	Order = 0,
	TargetStat = "Resilience",
	BaseStatBoost = 1,
	StatBoostPerLevel = 1,
	IdolName = "Nagomi Idol",
	IdolTag = "RelaxationIdol",
	IdolZone = "Skycrest",
	Hint = "Complete the Nagomi Idol's first 5 quests to unlock"
}
count += 1
relaxationCharm.Order = count
local brawnCharm = {
	ShortName = "Brawn",
	Icon = "rbxassetid://133117035816705",
	Color = Color3.fromRGB(75, 141, 142),
	Order = 0,
	TargetStat = "Strength",
	BaseStatBoost = 1000,
	StatBoostPerLevel = 1000,
	IdolName = "Goriki Idol",
	IdolTag = "BrawnIdol",
	IdolZone = "Skycrest",
	Hint = "Complete the Goriki Idol's first 5 quests to unlock"
}
count += 1
brawnCharm.Order = count
local rushCharm = {
	ShortName = "Rush",
	Icon = "rbxassetid://111467438627174",
	Color = Color3.fromRGB(235, 199, 54),
	Order = 0,
	TargetStat = "ProgressSpeed",
	BaseStatBoost = 1,
	StatBoostPerLevel = 1,
	IdolName = "Shunsoku Idol",
	IdolTag = "RushIdol",
	IdolZone = "Skycrest",
	Hint = "Complete the Shunsoku Idol's first 5 quests to unlock"
}
count += 1
rushCharm.Order = count
local pesterCharm = {
	ShortName = "Pester",
	Icon = "rbxassetid://128250028410271",
	Color = Color3.fromRGB(160, 34, 7),
	Order = 0,
	TargetStat = "Disturbance",
	BaseStatBoost = 0.2,
	StatBoostPerLevel = 0.2,
	IdolName = "Amanojaku Idol",
	IdolTag = "PesterIdol",
	IdolZone = "Skycrest",
	Hint = "Complete the Amanojaku Idol's first 5 quests to unlock"
}
count += 1
pesterCharm.Order = count
local titanicCharm = {
	ShortName = "Titanic",
	Icon = "rbxassetid://91859037583865",
	Color = Color3.fromRGB(49, 52, 255),
	Order = 0,
	TargetStat = "WeightBoost",
	BaseStatBoost = 1,
	StatBoostPerLevel = 1,
	Hint = "Complete all Tropical Ascension quests for all Idols to unlock",
	IdolLevelRequirement = 50
}
count += 1
titanicCharm.Order = count
local flashCharm = {
	ShortName = "Flash",
	Icon = "rbxassetid://83442494431256",
	Color = Color3.fromRGB(149, 88, 255),
	Order = 0,
	TargetStat = "ForcedProgressSpeed",
	BaseStatBoost = 0.8,
	StatBoostPerLevel = 0.3,
	Hint = "Complete all Raging Ascension quests for all Idols to unlock",
	IdolLevelRequirement = 80
}
count += 1
flashCharm.Order = count
local Charms = {
	["Swiftness Charm"] = swiftnessCharm,
	["Fortune Charm"] = fortuneCharm,
	["Endurance Charm"] = enduranceCharm,
	["Relaxation Charm"] = relaxationCharm,
	["Brawn Charm"] = brawnCharm,
	["Rush Charm"] = rushCharm,
	["Pester Charm"] = pesterCharm,
	["Titanic Charm"] = titanicCharm,
	["Flash Charm"] = flashCharm
}

for k, v10 in Charms do
	v10.Name = k
end

return Charms