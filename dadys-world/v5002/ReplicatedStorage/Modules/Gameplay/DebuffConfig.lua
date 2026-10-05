local DebuffConfig = {}
local v = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X"
}
local v2 = {
	Speed = Color3.fromRGB(255, 240, 30),
	Stealth = Color3.fromRGB(35, 178, 255),
	DecodeSpeed = Color3.fromRGB(129, 66, 255),
	Stamina = Color3.fromRGB(56, 255, 42),
	SkillCheck = Color3.fromRGB(255, 120, 30)
}
DebuffConfig.Definitions = {
	Slow = {
		displayName = "Slowness",
		icon = "rbxassetid://17887980484",
		color = Color3.fromRGB(158, 148, 44),
		refreshable = true,
		managedByManager = true,
		showInOverheadGui = true,
		isBuff = false
	},
	Tired = {
		displayName = "Tiredness",
		icon = "rbxassetid://17889130264",
		color = Color3.fromRGB(51, 158, 46),
		refreshable = true,
		managedByManager = true,
		showInOverheadGui = true,
		isBuff = false
	},
	Confused = {
		displayName = "Confusion",
		icon = "rbxassetid://17889450280",
		color = Color3.fromRGB(100, 52, 158),
		refreshable = false,
		managedByManager = true,
		showInOverheadGui = true,
		isBuff = false
	},
	Illness = {
		displayName = "Illness",
		icon = "rbxassetid://83230097328815",
		color = Color3.fromRGB(139, 69, 19),
		refreshable = true,
		managedByManager = true,
		showInOverheadGui = true,
		isBuff = false
	},
	TreadmillDazed = {
		displayName = "Dazed",
		icon = "rbxassetid://125152464787251",
		color = Color3.fromRGB(52, 91, 158),
		refreshable = false,
		managedByManager = true,
		showInOverheadGui = false,
		isBuff = false
	},
	Energized = {
		displayName = "Energized",
		icon = "rbxassetid://132742259361191",
		color = Color3.fromRGB(232, 252, 48),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		isBuff = true
	},
	Dazed = {
		displayName = "Dazed",
		icon = "rbxassetid://125152464787251",
		color = Color3.fromRGB(52, 91, 158),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		isBuff = false
	},
	Ignited = {
		displayName = "Ignited",
		icon = "rbxassetid://117346103442117",
		color = Color3.fromRGB(255, 96, 24),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		hideStageNumeral = true,
		isBuff = true
	},
	Guarded = {
		displayName = "Guarded",
		icon = "rbxassetid://77637387117626",
		color = Color3.fromRGB(96, 140, 210),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		hideStageNumeral = true,
		isBuff = true
	},
	GuardBurst = {
		displayName = "Guard Burst",
		icon = "rbxassetid://132742259361191",
		color = Color3.fromRGB(120, 200, 255),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	HurtBurst = {
		displayName = "Hurt Burst",
		icon = "rbxassetid://132742259361191",
		color = Color3.fromRGB(255, 110, 110),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	GuardEscort = {
		displayName = "Escorted",
		icon = "rbxassetid://132742259361191",
		color = Color3.fromRGB(150, 230, 150),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	GuardStance = {
		displayName = "Guard Stance",
		icon = "rbxassetid://77637387117626",
		color = Color3.fromRGB(230, 200, 90),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		showInStatsPanel = false,
		isBuff = true
	},
	Untargetable = {
		displayName = "Untargetable",
		icon = "rbxassetid://121908174722814",
		color = Color3.fromRGB(200, 200, 230),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		hideStageNumeral = true,
		isBuff = true
	},
	SugarRush = {
		halloween = true,
		displayName = "Sugar Rush III",
		icon = "rbxassetid://95680177081121",
		color = Color3.fromRGB(255, 66, 236),
		rainbow = true,
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ShrinkRig = {
		halloween = true,
		displayName = "Bite-sized!",
		icon = "rbxassetid://108692990829241",
		color = Color3.fromRGB(120, 220, 255),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		hideStageNumeral = true,
		isBuff = false
	},
	LabSpeed = {
		displayName = "Lab Speed",
		icon = "rbxassetid://132742259361191",
		color = Color3.fromRGB(255, 170, 80),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	ArtisticInspiration = {
		displayName = "Artistic Inspiration",
		icon = "rbxassetid://100313081858390",
		color = Color3.fromRGB(255, 150, 40),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = false,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemSpeedCandy = {
		halloween = true,
		displayName = "Speed Candy",
		icon = "rbxassetid://17713663434",
		color = v2.Speed,
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemStealthCandy = {
		halloween = true,
		displayName = "Stealth Candy",
		icon = "rbxassetid://18702541024",
		color = v2.Stealth,
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemStaminaCandy = {
		halloween = true,
		displayName = "Stamina Candy",
		icon = "rbxassetid://122723121767996",
		color = v2.Stamina,
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemSkillCheckCandy = {
		halloween = true,
		displayName = "Skill Check Candy",
		icon = "rbxassetid://18702541120",
		color = v2.SkillCheck,
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemExtractionSpeedCandy = {
		halloween = true,
		displayName = "Extraction Speed Candy",
		icon = "rbxassetid://108547367119591",
		color = v2.DecodeSpeed,
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemInstructions = {
		displayName = "Instructions",
		icon = "rbxassetid://17602982694",
		color = Color3.fromRGB(90, 200, 255),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemProteinBar = {
		halloween = true,
		displayName = "Protein Bar",
		icon = "rbxassetid://17725435324",
		color = Color3.fromRGB(100, 210, 130),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemStopwatch = {
		displayName = "Stopwatch",
		icon = "rbxassetid://17728670202",
		color = Color3.fromRGB(255, 220, 90),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemChocolate = {
		halloween = true,
		displayName = "Chocolate",
		icon = "rbxassetid://17727840139",
		color = Color3.fromRGB(100, 210, 130),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemChocolateBox = {
		halloween = true,
		displayName = "Box o' Chocolates",
		icon = "rbxassetid://18853148499",
		color = Color3.fromRGB(100, 210, 130),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemBonBon = {
		displayName = "Bon Bon",
		icon = "rbxassetid://130335597602610",
		color = Color3.fromRGB(255, 120, 200),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemEjectButton = {
		halloween = true,
		displayName = "Eject Button",
		icon = "rbxassetid://17727492281",
		color = Color3.fromRGB(255, 170, 80),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemGumball = {
		halloween = true,
		displayName = "Gumballs",
		icon = "rbxassetid://17728443666",
		color = Color3.fromRGB(255, 120, 200),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemJawbreaker = {
		halloween = true,
		displayName = "Jawbreaker",
		icon = "rbxassetid://128185500990835",
		color = Color3.fromRGB(255, 120, 200),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemChristmasCookie = {
		displayName = "Christmas Cookie",
		icon = "rbxassetid://121366170175008",
		color = Color3.fromRGB(255, 170, 80),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemDandyEasterEggs = {
		displayName = "Dandy's Easter Eggs",
		icon = "rbxassetid://93072687798827",
		color = Color3.fromRGB(255, 170, 80),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemDandyCorn = {
		halloween = true,
		displayName = "Dandy Corn",
		icon = "rbxassetid://96842798690508",
		color = Color3.fromRGB(255, 170, 80),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = true
	},
	GourdySugarRush = {
		displayName = "Sugar Rush",
		icon = "rbxassetid://99809413682710",
		color = Color3.fromRGB(255, 140, 40),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	CatsFeet = {
		halloween = true,
		displayName = "Cat's Feet",
		icon = "rbxassetid://18702541024",
		color = Color3.fromRGB(150, 130, 230),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	SmoothDial = {
		halloween = true,
		displayName = "Smooth Dial",
		icon = "rbxassetid://17728670202",
		color = Color3.fromRGB(255, 220, 90),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	RibeccaEmpoweredSpeed = {
		color = v2.Speed,
		displayName = "Empowered: Speed",
		icon = "rbxassetid://94294630559443",
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	RibeccaEmpoweredStealth = {
		color = v2.Stealth,
		displayName = "Empowered: Stealth",
		icon = "rbxassetid://94294630559443",
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	RibeccaEmpoweredDecodeSpeed = {
		color = v2.DecodeSpeed,
		displayName = "Empowered: Extraction Speed",
		icon = "rbxassetid://94294630559443",
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	RibeccaEmpoweredStaminaRegen = {
		color = v2.Stamina,
		displayName = "Empowered: Stamina Regeneration",
		icon = "rbxassetid://94294630559443",
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	RibeccaEmpoweredSkillCheck = {
		color = v2.SkillCheck,
		displayName = "Empowered: Skill Check",
		icon = "rbxassetid://94294630559443",
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	IronStomach = {
		halloween = true,
		displayName = "Iron Stomach",
		icon = "rbxassetid://6794188517",
		color = Color3.fromRGB(220, 220, 220),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		hideStageNumeral = true,
		isBuff = true
	},
	Chomped = {
		halloween = true,
		displayName = "Chomped",
		icon = "rbxassetid://17887980484",
		color = Color3.fromRGB(120, 170, 220),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = false
	},
	Latched = {
		halloween = true,
		displayName = "Latched",
		icon = "rbxassetid://17887980484",
		color = Color3.fromRGB(120, 170, 220),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = false
	},
	BlottGrab = {
		halloween = true,
		displayName = "Grabbed",
		icon = "rbxassetid://17887980484",
		color = Color3.fromRGB(110, 90, 160),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = false
	},
	Marked = {
		halloween = true,
		displayName = "Marked",
		icon = "rbxassetid://18537864423",
		color = Color3.fromRGB(230, 60, 60),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = true,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = false
	},
	ItemSmokeBomb = {
		halloween = true,
		displayName = "Smoke Bomb",
		icon = "rbxassetid://17727273649",
		color = Color3.fromRGB(180, 180, 190),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		hideStageNumeral = true,
		isBuff = true
	},
	ItemAirHorn = {
		displayName = "Air Horn",
		icon = "rbxassetid://18537864423",
		color = Color3.fromRGB(230, 90, 60),
		refreshable = false,
		managedByManager = false,
		showInOverheadGui = false,
		showInStatusHud = true,
		showInStatsPanel = false,
		stacks = true,
		hideStageNumeral = true,
		isBuff = false
	}
}

function DebuffConfig.Get(p)
	return DebuffConfig.Definitions[p]
end

function DebuffConfig.IsRefreshable(p)
	local definition = DebuffConfig.Definitions[p]
	return definition ~= nil and definition.refreshable == true
end

function DebuffConfig.ShowsInOverheadGui(p)
	local definition = DebuffConfig.Definitions[p]
	return definition ~= nil and definition.showInOverheadGui == true
end

function DebuffConfig.ShowsInStatusHud(p)
	local definition = DebuffConfig.Definitions[p]

	if not definition then
		return false
	end

	if definition.showInStatusHud == nil then
		return definition.showInOverheadGui == true
	end

	return definition.showInStatusHud == true
end

function DebuffConfig.Stacks(p)
	local definition = DebuffConfig.Definitions[p]
	return definition ~= nil and definition.stacks == true
end

function DebuffConfig.ShowsInStatsPanel(p)
	local definition = DebuffConfig.Definitions[p]

	if definition then
		return definition.showInStatsPanel ~= false
	end

	return false
end

function DebuffConfig.GetStageNumeral(p)
	return v[p] or ""
end

function DebuffConfig.GetManagedNames()
	local result = {}

	for k, definition in pairs(DebuffConfig.Definitions) do
		if definition.managedByManager then
			table.insert(result, k)
		end
	end

	return result
end

function DebuffConfig.GetDisplayableNames()
	local result = {}

	for k, definition in pairs(DebuffConfig.Definitions) do
		if definition.showInOverheadGui then
			table.insert(result, k)
		end
	end

	return result
end

function DebuffConfig.GetStatusHudNames()
	local result = {}

	for k in pairs(DebuffConfig.Definitions) do
		if DebuffConfig.ShowsInStatusHud(k) then
			table.insert(result, k)
		end
	end

	return result
end

return DebuffConfig