local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local v = {
	Kevin_DJiceninja = {
		UserID = 1544275061,
		Cosmetics = { "Hyper Sniper", "Apex Pistols", "Bat Daggers" }
	},
	SooHui_PH2 = {
		UserID = 1796756117,
		Cosmetics = { "Spaceship Launcher", "Boba Gun", "Riptide Katana" }
	},
	mozzywalkstheplank = {
		UserID = 10763717,
		Cosmetics = {
			"Keyttle Axe",
			"Spider Web",
			"Energy Shield",
			"Wrapped Freeze Ray",
			"Keyshot",
			"Waffle Cone",
			"Fish Scales",
			"Neapolitan",
			"Tidal",
			"Spectralized",
			"Sundae Launcher",
			"Coconut Launcher",
			"Palm Scythe",
			"Crab Claws",
			"Splattered",
			"Enerkey Rifle",
			"Enerkey Pistols"
		}
	},
	Invicibrow = {
		UserID = 7207159625,
		Cosmetics = {
			"Gearnade Launcher",
			"Squid Launcher",
			"Notebook Satchel",
			"Mega Drill",
			"Masterpiece"
		}
	},
	NPC2Z = {
		UserID = 446253736,
		Cosmetics = { "Water Balloon", "Soul Grenade", "Bounce House" }
	},
	NSK0815 = {
		UserID = 3746614610,
		Cosmetics = { "Bag o' Money", "Ban Axe" }
	},
	tazd = {
		UserID = 343054539,
		Cosmetics = { "Medkitty" }
	},
	TheMonkeyMasterSeb = {
		UserID = 4830771682,
		Cosmetics = { "Hourglass" }
	},
	ayroyuusho123 = {
		UserID = 4382977409,
		Cosmetics = { "Fighter Jet" }
	},
	myxushi = {
		UserID = 436956865,
		Cosmetics = { "Mimic Axe" }
	},
	S3ntraMyst1c = {
		UserID = 3751863229,
		Cosmetics = { "Cerulean Axe", "Repulsor" }
	},
	StrangerHades0 = {
		UserID = 4942063762,
		Cosmetics = { "Event Horizon" }
	},
	ACrystalPirate = {
		UserID = 2592938109,
		Cosmetics = { "Neon Lights", "Regal" }
	},
	MunchFish = {
		UserID = 1544233658,
		Cosmetics = { "Candy Apple" }
	},
	BobbVX = {
		UserID = 301707243,
		Cosmetics = { "Cardboard" }
	},
	Z0Z_Gaming = {
		UserID = 874685655,
		Cosmetics = { "Diamond" }
	},
	nekoanims = {
		UserID = 780350915,
		Cosmetics = { "Hammered Copper", "Honeycomb" }
	},
	SpunkyKatane = {
		UserID = 1325102532,
		Cosmetics = { "Jolly Man", "Plasma Distortion" }
	},
	TylkonTylko = {
		UserID = 4192733792,
		Cosmetics = { "Beloved Bow" }
	},
	Salllu_78 = {
		UserID = 1142556567,
		Cosmetics = { "Key Spray" }
	},
	emiiluumii = {
		UserID = 5010662019,
		Cosmetics = { "Arch Molotov" }
	},
	Galaxywolfibrar = {
		UserID = 1511223890,
		Cosmetics = { "Lighthouse" }
	},
	bladesof_fir3 = {
		UserID = 5239484609,
		Cosmetics = { "Chark Kebab" }
	},
	["99kRom"] = {
		UserID = 724399676,
		Cosmetics = { "Palmshot" }
	},
	Kisasage = {
		UserID = 7156056199,
		Cosmetics = { "Hazard Sign" }
	},
	T0Wa_chan = {
		UserID = 1442276929,
		Cosmetics = { "Snowblob" }
	},
	Juanicho2021 = {
		UserID = 2660279857,
		Cosmetics = { "Plunger" }
	},
	konenro = {
		UserID = 10960176795,
		Cosmetics = { "Arcade Claw" }
	},
	fertmeny = {
		UserID = 660553399,
		Cosmetics = { "Genie Lamp" }
	},
	FishingFlare = {
		UserID = 4163861479,
		Cosmetics = { "Starforge Maul", "Starforge Permafrost" }
	},
	["0RAFO9"] = {
		UserID = 260550404,
		Cosmetics = { "Keythe" }
	}
}
local ConceptsLibrary = {
	CONCEPT_REWARD_NAME = "Scribble",
	Leaderboard = {},
	Conceptors = {}
}

function ConceptsLibrary:GetConceptors(p)
	local result = {}

	for k, conceptor in pairs(ConceptsLibrary.Conceptors) do
		if table.find(conceptor.CosmeticConcepts, p) then
			table.insert(result, k)
		end
	end

	return result
end

function ConceptsLibrary:GetConceptScore(p)
	local conceptor = ConceptsLibrary.Conceptors[tostring(p)]

	if not conceptor then
		return 0
	end

	local total = 0

	for _, cosmeticConcept in pairs(conceptor.CosmeticConcepts) do
		local count = #ConceptsLibrary:GetConceptors(cosmeticConcept)

		if count == 0 then
			warn("??? Conceptors for cosmetic " .. cosmeticConcept .. " == 0")
		else
			total += 1 / count
		end
	end

	return total
end

function ConceptsLibrary.GetNextMilestone(_, p)
	for k, milestone in pairs(ConceptsLibrary.Milestones) do
		if p < milestone[1] then
			return milestone, ConceptsLibrary.Milestones[k - 1]
		end
	end
end

local function add_conceptor(userID, cosmetics)
	local v2

	if typeof(userID) == "number" then
		v2 = userID ~= 0
	else
		v2 = false
	end

	assert(v2)
	local v3 = {}

	for i = #cosmetics, 1, -1 do
		local v4 = cosmetics[i]

		if CosmeticLibrary.Cosmetics[v4] then
			assert(not v3[v4], "Item entered in more than once: " .. v4)
			v3[v4] = true
		else
			table.remove(cosmetics, i)
			task.spawn(error, "Item doesnt exist: " .. v4)
		end
	end

	local v4 = {
		UserID = userID,
		CosmeticConcepts = cosmetics or {}
	}
	ConceptsLibrary.Conceptors[tostring(v4.UserID)] = v4
	local v5 = {
		key = tostring(userID),
		value = nil
	}
	table.insert(ConceptsLibrary.Leaderboard, v5)
end

for _, v2 in pairs(v) do
	add_conceptor(v2.UserID, v2.Cosmetics)
end

local function sort_leaderboard()
	for _, v2 in pairs(ConceptsLibrary.Leaderboard) do
		v2.value = ConceptsLibrary:GetConceptScore(v2.key)
	end

	table.sort(ConceptsLibrary.Leaderboard, function(a, b)
		return a.value > b.value
	end)
	local v2 = {}

	for _, v3 in pairs(v) do
		if v2[v3.UserID] then
			error("[CONCEPTS] Duplicate User ID:", v3.UserID)
		end

		v2[v3.UserID] = true
	end
end

sort_leaderboard()
return ConceptsLibrary