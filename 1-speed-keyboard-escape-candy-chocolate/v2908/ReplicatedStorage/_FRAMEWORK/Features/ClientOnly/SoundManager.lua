local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local PluginEnv

if RunService:IsServer() or Common.IsPlugin() then
	PluginEnv = require(ServerStorage.DevPlugin.PluginEnv)
else
	PluginEnv = nil
end

local GameplayDefaults = require(ReplicatedStorage.Config.Shared.GameplayDefaults)
local Environment = require(ReplicatedStorage.Packages["UI-Labs"].Environment)
local Set = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Set)
local StringUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.StringUtils)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = Set.new()
local v2 = {
	Footsteps = {
		FS_Bass = {
			bass_01 = "rbxassetid://9126748907",
			bass_02 = "rbxassetid://9126748813",
			bass_03 = "rbxassetid://9126748580",
			bass_04 = "rbxassetid://9126748691",
			bass_05 = "rbxassetid://9126748431",
			bass_06 = "rbxassetid://9126748324",
			bass_07 = "rbxassetid://9126748239",
			bass_08 = "rbxassetid://9126748185",
			bass_09 = "rbxassetid://9126748045",
			bass_10 = "rbxassetid://9126747958"
		},
		FS_Carpet = {
			carpet_01 = "rbxassetid://9126748130",
			carpet_02 = "rbxassetid://9126747861",
			carpet_03 = "rbxassetid://9126747720",
			carpet_04 = "rbxassetid://9126747529",
			carpet_05 = "rbxassetid://9126747412",
			carpet_06 = "rbxassetid://9126747283",
			carpet_07 = "rbxassetid://9126746732",
			carpet_08 = "rbxassetid://9126746837",
			carpet_09 = "rbxassetid://9126747132",
			carpet_10 = "rbxassetid://9126746984",
			carpet_11 = "rbxassetid://9126746598",
			carpet_12 = "rbxassetid://9126746481",
			carpet_13 = "rbxassetid://9126746371",
			carpet_14 = "rbxassetid://9126746291"
		},
		FS_Concrete = {
			concrete_01 = "rbxassetid://9126746167",
			concrete_02 = "rbxassetid://9126746098",
			concrete_03 = "rbxassetid://9126745995",
			concrete_04 = "rbxassetid://9126745877",
			concrete_05 = "rbxassetid://9126745774",
			concrete_06 = "rbxassetid://9126745574",
			concrete_07 = "rbxassetid://9126745336",
			concrete_08 = "rbxassetid://9126745241",
			concrete_09 = "rbxassetid://9126745445",
			concrete_10 = "rbxassetid://9126745052",
			concrete_11 = "rbxassetid://9126745141",
			concrete_12 = "rbxassetid://9126745676",
			concrete_13 = "rbxassetid://9126744969",
			concrete_14 = "rbxassetid://9126744894",
			concrete_15 = "rbxassetid://9126744639",
			concrete_16 = "rbxassetid://9126744789",
			concrete_17 = "rbxassetid://9126744481"
		},
		FS_Dirt = {
			dirt_01 = "rbxassetid://9126744390",
			dirt_02 = "rbxassetid://9126744718",
			dirt_03 = "rbxassetid://9126744263",
			dirt_04 = "rbxassetid://9126744157",
			dirt_05 = "rbxassetid://9126744066",
			dirt_06 = "rbxassetid://9126744009",
			dirt_07 = "rbxassetid://9126743796",
			dirt_08 = "rbxassetid://9126743938",
			dirt_09 = "rbxassetid://9126743711",
			dirt_10 = "rbxassetid://9126743879",
			dirt_11 = "rbxassetid://9126743613",
			dirt_12 = "rbxassetid://9126743481",
			dirt_13 = "rbxassetid://9126743338",
			dirt_14 = "rbxassetid://9126743086"
		},
		FS_Glass = {
			glass_01 = "rbxassetid://9126742971",
			glass_02 = "rbxassetid://9126742461",
			glass_03 = "rbxassetid://9126742875",
			glass_04 = "rbxassetid://9126742786",
			glass_05 = "rbxassetid://9126743193",
			glass_06 = "rbxassetid://9126742680",
			glass_07 = "rbxassetid://9126742582",
			glass_08 = "rbxassetid://9126742510"
		},
		FS_Grass = {
			grass_01 = "rbxassetid://9126742396",
			grass_02 = "rbxassetid://9126741427",
			grass_03 = "rbxassetid://9126742333",
			grass_04 = "rbxassetid://9126742215",
			grass_05 = "rbxassetid://9126742271",
			grass_06 = "rbxassetid://9126742031",
			grass_07 = "rbxassetid://9126741934",
			grass_08 = "rbxassetid://9126742105",
			grass_09 = "rbxassetid://9126741826",
			grass_10 = "rbxassetid://9126741594",
			grass_11 = "rbxassetid://9126741512",
			grass_12 = "rbxassetid://9126741741",
			grass_13 = "rbxassetid://9126741674"
		},
		FS_Gravel = {
			gravel_01 = "rbxassetid://9126741273",
			gravel_02 = "rbxassetid://9126740393",
			gravel_03 = "rbxassetid://9126741200",
			gravel_04 = "rbxassetid://9126741051",
			gravel_05 = "rbxassetid://9126741128",
			gravel_06 = "rbxassetid://9126740951",
			gravel_07 = "rbxassetid://9126740802",
			gravel_08 = "rbxassetid://9126740724",
			gravel_09 = "rbxassetid://9126740524",
			gravel_10 = "rbxassetid://9126740623"
		},
		FS_Ladder = {
			ladder_01 = "rbxassetid://9126740217",
			ladder_02 = "rbxassetid://9126739039",
			ladder_03 = "rbxassetid://9126740133",
			ladder_04 = "rbxassetid://9126739947",
			ladder_05 = "rbxassetid://9126740044",
			ladder_06 = "rbxassetid://9126740305",
			ladder_07 = "rbxassetid://9126739834",
			ladder_08 = "rbxassetid://9126739622",
			ladder_09 = "rbxassetid://9126739505",
			ladder_10 = "rbxassetid://9126739406",
			ladder_11 = "rbxassetid://9126739332",
			ladder_12 = "rbxassetid://9126739229"
		},
		FS_Massive_Footstep = {
			["Massive Footstep Impact 11 (SFX)"] = "rbxassetid://9116477339",
			["Massive Footstep Impact 12 (SFX)"] = "rbxassetid://9116477578",
			["Massive Footstep Impact 13 (SFX)"] = "rbxassetid://9116477638",
			["Massive Footstep Impact 14 (SFX)"] = "rbxassetid://9116479828",
			["Massive Footstep Impact 15 (SFX)"] = "rbxassetid://9116477856",
			["Massive Footstep Impact 18 (SFX)"] = "rbxassetid://9116480116",
			["Massive Footstep Impact 19 (SFX)"] = "rbxassetid://9116478139",
			["Massive Footstep Impact 2 (SFX)"] = "rbxassetid://9116476632",
			["Massive Footstep Impact 4 (SFX)"] = "rbxassetid://9116476848",
			["Massive Footstep Impact 8 (SFX)"] = "rbxassetid://9116479357"
		},
		FS_Metal_Auto = {
			metal_auto_01 = "rbxassetid://9126739090",
			metal_auto_02 = "rbxassetid://9126738967",
			metal_auto_03 = "rbxassetid://9126738896",
			metal_auto_04 = "rbxassetid://9126738732",
			metal_auto_05 = "rbxassetid://9126738543",
			metal_auto_06 = "rbxassetid://9126738634"
		},
		FS_Metal_Chainlink = {
			metal_chainlink_01 = "rbxassetid://9126738423",
			metal_chainlink_02 = "rbxassetid://9126737791",
			metal_chainlink_03 = "rbxassetid://9126738338",
			metal_chainlink_04 = "rbxassetid://9126738197",
			metal_chainlink_05 = "rbxassetid://9126738113",
			metal_chainlink_06 = "rbxassetid://9126738032",
			metal_chainlink_07 = "rbxassetid://9126737943",
			metal_chainlink_08 = "rbxassetid://9126737853"
		},
		FS_Metal_Grate = {
			metal_grate_01 = "rbxassetid://9126737728",
			metal_grate_02 = "rbxassetid://9126736554",
			metal_grate_03 = "rbxassetid://9126737597",
			metal_grate_04 = "rbxassetid://9126737668",
			metal_grate_05 = "rbxassetid://9126737506",
			metal_grate_06 = "rbxassetid://9126737412",
			metal_grate_07 = "rbxassetid://9126737315",
			metal_grate_08 = "rbxassetid://9126737212",
			metal_grate_09 = "rbxassetid://9126736947",
			metal_grate_10 = "rbxassetid://9126737081",
			metal_grate_11 = "rbxassetid://9126736863",
			metal_grate_12 = "rbxassetid://9126736806",
			metal_grate_13 = "rbxassetid://9126736642",
			metal_grate_14 = "rbxassetid://9126736721"
		},
		FS_Metal_Solid = {
			metal_solid_01 = "rbxassetid://9126736470",
			metal_solid_02 = "rbxassetid://9126734921",
			metal_solid_03 = "rbxassetid://9126736274",
			metal_solid_04 = "rbxassetid://9126736354",
			metal_solid_05 = "rbxassetid://9126736186",
			metal_solid_06 = "rbxassetid://9126736049",
			metal_solid_07 = "rbxassetid://9126735913",
			metal_solid_08 = "rbxassetid://9126735734",
			metal_solid_09 = "rbxassetid://9126735546",
			metal_solid_10 = "rbxassetid://9126735474",
			metal_solid_11 = "rbxassetid://9126735265",
			metal_solid_12 = "rbxassetid://9126735374",
			metal_solid_13 = "rbxassetid://9126735161",
			metal_solid_14 = "rbxassetid://9126735028",
			metal_solid_15 = "rbxassetid://9126735089",
			metal_solid_16 = "rbxassetid://9126734972"
		},
		FS_Mud = {
			mud_01 = "rbxassetid://9126734842",
			mud_02 = "rbxassetid://9126734314",
			mud_03 = "rbxassetid://9126734778",
			mud_04 = "rbxassetid://9126734710",
			mud_05 = "rbxassetid://9126734613",
			mud_06 = "rbxassetid://9126734499",
			mud_07 = "rbxassetid://9126734365",
			mud_08 = "rbxassetid://9126734432",
			mud_09 = "rbxassetid://9126734244"
		},
		FS_Rubber = {
			rubber_01 = "rbxassetid://9126734172",
			rubber_02 = "rbxassetid://9126733896",
			rubber_03 = "rbxassetid://9126734560",
			rubber_04 = "rbxassetid://9126734010",
			rubber_05 = "rbxassetid://9126733324",
			rubber_06 = "rbxassetid://9126733766",
			rubber_07 = "rbxassetid://9126733614",
			rubber_08 = "rbxassetid://9126733493"
		},
		FS_Sand = {
			sand_01 = "rbxassetid://9126733118",
			sand_02 = "rbxassetid://9126733408",
			sand_03 = "rbxassetid://9126733225",
			sand_04 = "rbxassetid://9126732675",
			sand_05 = "rbxassetid://9126732571",
			sand_06 = "rbxassetid://9126732962",
			sand_07 = "rbxassetid://9126732962",
			sand_08 = "rbxassetid://9126732457",
			sand_09 = "rbxassetid://9126732862",
			sand_10 = "rbxassetid://9126732776",
			sand_11 = "rbxassetid://9126732334",
			sand_12 = "rbxassetid://9126732253"
		},
		FS_Snow = {
			snow_01 = "rbxassetid://9126732128",
			snow_02 = "rbxassetid://9126731099",
			snow_03 = "rbxassetid://9126732016",
			snow_04 = "rbxassetid://9126731951",
			snow_05 = "rbxassetid://9126731877",
			snow_06 = "rbxassetid://9126731632",
			snow_07 = "rbxassetid://9126731493",
			snow_08 = "rbxassetid://9126731343",
			snow_09 = "rbxassetid://9126731790",
			snow_10 = "rbxassetid://9126731243",
			snow_11 = "rbxassetid://9126731169",
			snow_12 = "rbxassetid://9126730861"
		},
		FS_Tile = {
			tile_01 = "rbxassetid://9126730713",
			tile_02 = "rbxassetid://9126730782",
			tile_03 = "rbxassetid://9126731037",
			tile_04 = "rbxassetid://9126730980",
			tile_05 = "rbxassetid://9126730651",
			tile_06 = "rbxassetid://9126730563",
			tile_07 = "rbxassetid://9126730279",
			tile_08 = "rbxassetid://9126730403",
			tile_09 = "rbxassetid://9126730056",
			tile_10 = "rbxassetid://9126730172",
			tile_11 = "rbxassetid://9126729836",
			tile_12 = "rbxassetid://9126730472",
			tile_13 = "rbxassetid://9126729938",
			tile_14 = "rbxassetid://9126729706"
		},
		FS_Wood = {
			wood_01 = "rbxassetid://9126931624",
			wood_02 = "rbxassetid://9126931515",
			wood_03 = "rbxassetid://9126931417",
			wood_04 = "rbxassetid://9126931322",
			wood_05 = "rbxassetid://9126931699",
			wood_06 = "rbxassetid://9126931235",
			wood_07 = "rbxassetid://9126931169",
			wood_08 = "rbxassetid://9126931026",
			wood_09 = "rbxassetid://9126930953",
			wood_10 = "rbxassetid://9126930885",
			wood_11 = "rbxassetid://9126930789",
			wood_12 = "rbxassetid://9126930647",
			wood_13 = "rbxassetid://9126930516",
			wood_14 = "rbxassetid://9126930598",
			wood_15 = "rbxassetid://9126930718"
		}
	},
	Woosh = {
		BladeMedium = {
			["Woosh-1"] = "rbxassetid://126412022585723",
			["Woosh-2"] = "rbxassetid://109772028463169",
			["Woosh-3"] = "rbxassetid://110447041425274",
			["Woosh-4"] = "rbxassetid://77130924766423",
			["Woosh-5"] = "rbxassetid://87769013944792",
			["Woosh-6"] = "rbxassetid://78828744286642"
		},
		Clothes = {
			Clothes_Hit = {
				Clothes1_1 = "rbxassetid://8489959487",
				Clothes1_2 = "rbxassetid://8489958644",
				Clothes1_3 = "rbxassetid://8489957538"
			},
			Clothes_Short = {
				Clothes2_1 = "rbxassetid://8489959288",
				Clothes2_2 = "rbxassetid://8489959087",
				Clothes2_3 = "rbxassetid://8489958889"
			}
		},
		LongWooshes = {
			LongWoosh1 = "rbxassetid://93285734614162",
			LongWoosh2 = "rbxassetid://139681668192684"
		},
		Reversed = {
			["Vision Transition 1 (SFX)"] = "rbxassetid://9120438364",
			["Vision Transition 3 (SFX)"] = "rbxassetid://9120438601",
			["Vision Transition 4 (SFX)"] = "rbxassetid://9120438607",
			["Whoosh Suction 8 (SFX)"] = "rbxassetid://9120736816"
		},
		ShortSlides = {
			["MW Player Slide 1"] = "rbxassetid://129832437149454",
			["MW Player Slide 2"] = "rbxassetid://104298925753512",
			["MW Player Slide 3"] = "rbxassetid://97251745910217"
		},
		["Undecided Woosh"] = {
			["Extra Large Woosh"] = "rbxassetid://9119805442",
			["Knife Swing 1"] = "rbxassetid://5789211405",
			["Swish High End Thin Sharp Thick 19 (SFX)"] = "rbxassetid://9119699564",
			["Swish Spin 8 (SFX)"] = "rbxassetid://9119706772",
			["Sword Swing 1"] = "rbxassetid://6230938036",
			["Sword Swing 2"] = "rbxassetid://6603295777",
			["Whoosh Giant 1"] = "rbxassetid://9120725176",
			["Whoosh Giant 2"] = "rbxassetid://9120724932",
			["Whoosh Giant 3"] = "rbxassetid://9120720141",
			["Whoosh Giant 4"] = "rbxassetid://9120727699",
			["Woosh Basic 1"] = "rbxassetid://608537390",
			["Woosh Rapid Light 1"] = "rbxassetid://9113305311"
		},
		Unsorted = {
			PierceWoosh1 = "rbxassetid://8120249833",
			["Sword Slash Sfx"] = "rbxassetid://18511965048"
		},
		WeaponAndSpellPack = {
			Base = {
				Whoosh_1 = "rbxassetid://134729561196486",
				Whoosh_2 = "rbxassetid://118775539477142",
				Whoosh_3 = "rbxassetid://88684370052015",
				Whoosh_4 = "rbxassetid://113831852315712",
				Whoosh_5 = "rbxassetid://94945398085170",
				Whoosh_6 = "rbxassetid://138867994196876",
				Whoosh_7 = "rbxassetid://106092037939790"
			},
			Critical = {
				Whoosh_Critical1 = "rbxassetid://104707346426892",
				Whoosh_Critical2 = "rbxassetid://96356560678205"
			},
			SciFi = {
				Whoosh_SF_Weapon = "rbxassetid://109843738710001"
			},
			Sword = {
				Whoosh_Sword1 = "rbxassetid://97339100934814",
				Whoosh_Sword2 = "rbxassetid://78394932688179"
			}
		},
		["Woosh Short Light"] = {
			["Woosh Short Light 1"] = "rbxassetid://9119737832",
			["Woosh Short Light 2"] = "rbxassetid://9119737164",
			["Woosh Short Light 3"] = "rbxassetid://9119737232",
			["Woosh Short Light 4"] = "rbxassetid://9119737390"
		},
		["Woosh Small Blade"] = {
			["Swing Cutter 1"] = "rbxassetid://8838464430"
		},
		["Woosh Spin"] = {
			["Cyclone Woosh"] = "rbxassetid://6006851551",
			["Woosh Spin Light 1"] = "rbxassetid://9113305107"
		}
	},
	Fighting = {
		HitFist = {
			Hit1 = "rbxassetid://139520673393967",
			Hit2 = "rbxassetid://136811265205147",
			Hit3 = "rbxassetid://140025518477459",
			Hit4 = "rbxassetid://109316755832781",
			Hit5 = "rbxassetid://80809123525734",
			Hit6 = "rbxassetid://75771399170221"
		}
	},
	AdminAbuse = {
		FabAA = {
			Transition = {
				OFF = "rbxassetid://9058751039",
				ON = "rbxassetid://1843027458"
			},
			Voice = {
				E1 = "rbxassetid://111199918694125",
				E2 = "rbxassetid://79060104250659",
				E3 = "rbxassetid://85260119852506"
			},
			Beam = "rbxassetid://137930715361519"
		}
	},
	Legacy = {}
}
local v3 = nil
local clones = {}
local clones2 = {}
local SoundManager = {}
local v4 = nil
local v5 = nil

for k, v6 in GameplayDefaults.SOUNDS do
	if typeof(v6) == "table" and v6.ID then
		v2.Legacy[k] = v6.ID
	end
end

function getEmptySound()
	if v3 then
		return v3
	end

	local sound = Instance.new("Sound")
	sound.Name = "EmptySound"
	sound.RollOffMaxDistance = 500
	sound.RollOffMinDistance = 40
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.Volume = 0
	v3 = sound
	return sound
end

function resolvePath(value)
	if typeof(value) ~= "table" then
		if typeof(value) == "string" then
			if string.match(value, "^rbxassetid://%d+$") then
				return value
			else
				value = value:split(value:find(".", 1, true) and "." or "/")
			end
		else
			error((`Couldn't resolve path argument because it's an unrelated type (expected table or string, gotten {typeof(value)})`))
		end
	end

	local v6 = v2

	for _, item in value do
		if not v6 or typeof(v6) ~= "table" then
			return nil
		end

		v6 = v6[item]
	end

	return v6
end

function prettifyPath(value)
	if typeof(value) == "string" then
		return value
	end

	if typeof(value) == "table" then
		return table.concat(value, ".")
	end

	error((`Couldn't prettify path argument because it's an unrelated type (expected table or string, gotten {typeof(value)})`))
end

function resolveSoundId(value)
	if typeof(value) == "number" or not StringUtils.startsWith(value, "rbxassetid://") then
		return (`rbxassetid://{value}`)
	end

	return value
end

function createPreloadSound(p, instance)
	if clones[p] then
		return clones[p]
	end

	local child = script:FindFirstChild((tostring(p)))

	if child then
		return child
	end

	local clone = instance:Clone()
	clone.Name = tostring(p)
	clone.Archivable = false
	clone.Parent = script
	clones[p] = clone
	return clone
end

function retrieveSound(p)
	local clone = clones2[p]

	if not clone then
		clone = getEmptySound():Clone()
		clone.SoundId = resolveSoundId(p)
		clone.Volume = 0.5
		clones2[p] = clone
	end

	if not RunService:IsServer() or Common.IsPlugin() then
		createPreloadSound(p, clone)
	end

	return clone
end

function collectSoundPaths(items, p: string, list)
	for k, item in items do
		if p ~= "" then
			k = `{p}.{k}`
		end

		local v6

		if typeof(item) == "table" then
			v6 = typeof(item.ID) == "string" or typeof(item.ID) == "number"
		else
			v6 = false
		end

		if typeof(item) == "string" or typeof(item) == "number" or v6 then
			table.insert(list, k)
		elseif typeof(item) == "table" then
			collectSoundPaths(item, k, list)
		end
	end
end

function collectSoundGroupPaths(items, p: string, list)
	for k, item in items do
		if typeof(item) ~= "table" then
			continue
		end

		if p ~= "" then
			k = `{p}.{k}`
		end

		local flag = false

		for _, v7 in item do
			if not (typeof(v7) == "string" or typeof(v7) == "number") then
				continue
			end

			flag = true
			break
		end

		if flag then
			table.insert(list, k)
		end

		collectSoundGroupPaths(item, k, list)
	end
end

function SoundManager.getSound(p)
	if RunService:IsServer() and not Common.IsPlugin() then
		logger:warn("sound is gotten on server, please only get sound on the client. Letting that pass for now.")
	end

	local path = resolvePath(p)

	if typeof(path) == "table" then
		logger:warn((`getSound gotten a {prettifyPath(p)} which seems to lead to a table of sound. Returning an empty sound as a fallback.`))
		return getEmptySound():Clone()
	end

	if path then
		return retrieveSound(path):Clone()
	end

	logger:warn((`couldn't find sound at path {prettifyPath(p)}. Returning an empty sound as a fallback.`))
	return getEmptySound():Clone()
end

function SoundManager.getRandomSoundFromGroup(p)
	if RunService:IsServer() and not Common.IsPlugin() then
		logger:warn("sound is gotten on server, please only get sound on the client. Letting that pass for now.")
	end

	local path = resolvePath(p)

	if typeof(path) == "string" or typeof(path) == "number" then
		logger:warn("getRandomSoundFromGroup gotten a single sound instabce. Returning with getSound as fallback.")
		return SoundManager.getSound(p)
	end

	if not path then
		logger:warn((`couldn't find sound at path {prettifyPath(p)}. Returning an empty sound as a fallback.`))
		return getEmptySound():Clone()
	end

	local v6 = {}

	for _, item in path do
		if typeof(item) ~= "table" then
			table.insert(v6, item)
		end
	end

	if #v6 <= 0 then
		logger:warn((`couldn't find sound at path {prettifyPath(p)} (2). Returning an empty sound as a fallback.`))
		return getEmptySound():Clone()
	end

	local integer = Common.GetRandom():NextInteger(1, #v6)
	return retrieveSound(v6[integer]):Clone()
end

function SoundManager.getAllSoundPaths()
	if v4 then
		return v4
	end

	local v6 = {}
	collectSoundPaths(v2, "", v6)
	table.sort(v6)
	v4 = v6
	return v6
end

function SoundManager.getAllSoundGroupPaths()
	if v5 then
		return v5
	end

	local v6 = {}
	collectSoundGroupPaths(v2, "", v6)
	table.sort(v6)
	v5 = v6
	return v6
end

function SoundManager.preloadSound(p)
	if RunService:IsServer() and not Common.IsPlugin() then
		return
	end

	local path = resolvePath(p)

	if typeof(path) == "table" then
		logger:warn((`preloadSound gotten a {prettifyPath(p)} which seems to lead to a table of sound.`))
	elseif path then
		retrieveSound(path)
	else
		logger:warn((`couldn't find sound at path {prettifyPath(p)} for preloading.`))
	end
end

function SoundManager.preloadAllSound()
	if RunService:IsServer() and not Common.IsPlugin() then
		return
	end

	for _, v6 in SoundManager.getAllSoundPaths() do
		local path = resolvePath(v6)

		if path and typeof(path) ~= "table" then
			retrieveSound(path)
		end
	end
end

function SoundManager.playLocal(p, value: number?, value2: number?, value3: number?)
	if RunService:IsServer() and not Common.IsPlugin() then
		error("Cannot play local on server.")
	end

	local v7 = value2 or 0.1
	local v9

	if typeof((resolvePath(p))) == "table" then
		v9 = SoundManager.getRandomSoundFromGroup(p)
	else
		v9 = SoundManager.getSound(p)
	end

	v9.PlaybackSpeed = 1 + Common.GetRandom():NextNumber(-v7, v7) + (value or 0)
	v9.Volume = value3 or 0.5
	v9.RollOffMaxDistance = 99999999
	v9.RollOffMinDistance = 99999998
	v9.Parent = Workspace.Terrain

	if Common.IsPlugin() then
		SoundManager.listenInPlugin(v9)
	end

	Debris:AddItem(v9, v9.TimeLength == 0 and 60 or v9.TimeLength * 4)
	v9:Play()
end

function SoundManager.stopAllSoundInPlugin()
	v:forEach(function(instance)
		instance:Destroy()
	end)
	v:clear()
end

function SoundManager.listenInPlugin(instance, p)
	if not Common.IsPlugin() then
		return
	end

	local instance2 = p or instance.Parent

	if instance2 and (instance2:IsA("BasePart") or instance2:IsA("Attachment")) and instance2 ~= Workspace.Terrain then
		local part = Instance.new("Part")
		v:add(part)
		part.Anchored = true
		part.Size = createVector(0.2, 0.2, 0.2)
		local cFrame

		if instance2:IsA("BasePart") then
			cFrame = instance2.CFrame
		else
			cFrame = instance2.WorldCFrame
		end

		part.CFrame = cFrame
		instance.Parent = part
		local v7

		if instance2:IsA("Attachment") and instance2.Parent ~= nil and instance2.Parent:IsA("BasePart") then
			v7 = instance2.Parent
		else
			v7 = instance2
		end

		v7:GetPropertyChangedSignal("CFrame"):Connect(function()
			local parent = part
			local cFrame2

			if instance2:IsA("BasePart") then
				cFrame2 = instance2.CFrame
			else
				cFrame2 = instance2.WorldCFrame
			end

			parent.CFrame = cFrame2
		end)
		instance.Destroying:Connect(function()
			part:Destroy()
		end)
		Debris:AddItem(part, 60)
		instance = part
	end

	local parent2

	if Environment.IsStory() then
		parent2 = Environment.PluginWidget
	else
		parent2 = PluginEnv.App.UI
	end

	instance.Parent = parent2
	v:add(instance)
end

return SoundManager