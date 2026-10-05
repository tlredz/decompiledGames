local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local parentModule = require(script.Parent)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Crow = require(ReplicatedStorage.Items.Misc.Crow)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local BossHunts = {}
local v = {
	Common = 0.25,
	UnCommon = 0.3,
	Rare = 0.35,
	Epic = 0.45,
	Legendary = 0.55,
	Mythic = 0.7
}
BossHunts.BandLevel = 125
BossHunts.Bands = { "High", "Low" }
BossHunts.MaxOpen = 5
local v2 = { 0.5, 0.75 }
BossHunts.Category = "BossHunt"
BossHunts.Sides = {
	Muzan = {
		Race = { "Demon", "Hybrid" },
		Voice = {
			Icon = BunchaIcons.MuzanIcon
		},
		Completion = "Good. One less of them."
	},
	Crow = {
		Race = { "Slayer", "Hybrid" },
		Voice = {
			Icon = Crow.Icon,
			Sound = "PS2crowquestUIcaw"
		},
		Completion = "The Corps has its answer."
	}
}
local v3 = {
	Slayer = "mission"
}
local v4 = {
	Slayer = "Defeat"
}

function BossHunts.Title(p: string, p2: string?)
	return (`{v4[p2] or "Eliminate"} {p}`)
end

function BossHunts.Noun(p: string?, flag: boolean?)
	local v5 = v3[p] or "hunt"

	if flag then
		return string.upper((string.sub(v5, 1, 1))) .. string.sub(v5, 2)
	end

	return v5
end

BossHunts.Hunts = {
	{
		Code = "Saneri",
		Side = "Muzan",
		Tier = "Mythic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Shinora",
		Side = "Muzan",
		Tier = "Mythic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Rengu",
		Side = "Muzan",
		Tier = "Mythic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Giyen",
		Side = "Muzan",
		Tier = "Legendary",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Gyorei",
		Side = "Muzan",
		Tier = "Legendary",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Zentaro",
		Side = "Muzan",
		Tier = "Legendary",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Obari",
		Side = "Muzan",
		Tier = "Epic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Tengai",
		Side = "Muzan",
		Tier = "Epic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Gyutai",
		Side = "Crow",
		Tier = "Mythic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Akazo",
		Side = "Crow",
		Tier = "Mythic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Reaper",
		Side = "Crow",
		Tier = "Mythic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Enru",
		Side = "Crow",
		Tier = "Legendary",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Nezura",
		Side = "Crow",
		Tier = "Legendary",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Sumari",
		Side = "Crow",
		Tier = "Epic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Yahari",
		Side = "Crow",
		Tier = "Epic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Datai",
		Side = "Crow",
		Tier = "Epic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "Domae",
		Side = "Crow",
		Tier = "Epic",
		Level = 200,
		MinLevel = 125
	},
	{
		Code = "FlameTrainee",
		Npc = "Flame Trainee",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "ThunderTrainee",
		Npc = "Thunder Trainee",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "WaterTrainee",
		Npc = "Water Trainee Sabito",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "WindTrainee",
		Npc = "Wind Trainee",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "StoneTrainee",
		Npc = "Stone Trainee",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "SerpentTrainee",
		Npc = "Serpent Trainee",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "InsectTrainee",
		Npc = "Insect Trainee",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "SoundTrainee",
		Npc = "Sound Trainee",
		Side = "Muzan",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "TaiChiTrainee",
		Npc = "Tai Chi Trainee Suzume",
		Side = "Muzan",
		Tier = "UnCommon",
		Level = 85,
		MinLevel = 65,
		MaxLevel = 125
	},
	{
		Code = "MotherBear",
		Npc = "Mother Bear",
		Side = "Crow",
		Tier = "Common",
		Level = 85,
		MinLevel = 45,
		MaxLevel = 125
	},
	{
		Code = "Hoyuzo",
		Side = "Crow",
		Tier = "Rare",
		Level = 85,
		MinLevel = 50,
		MaxLevel = 125
	},
	{
		Code = "SoryuTrainee",
		Npc = "Soryu Trainee Goki",
		Side = "Crow",
		Tier = "UnCommon",
		Level = 85,
		MinLevel = 62,
		MaxLevel = 125
	},
	{
		Code = "ReaperTrainee",
		Npc = "Reaper Trainee Kuzan",
		Side = "Crow",
		Tier = "Rare",
		Level = 85,
		MinLevel = 100,
		MaxLevel = 125
	}
}

function BossHunts.Npc(p)
	return p.Npc or p.Code
end

function BossHunts.Entry(p: string)
	for _, hunt in BossHunts.Hunts do
		if BossHunts.Npc(hunt) == p then
			return hunt
		end
	end

	return nil
end

function BossHunts.Band(p)
	if p.MaxLevel == nil then
		return "High"
	end

	return "Low"
end

function BossHunts.Rewards(p)
	local v5 = v[p.Tier]

	if v5 == nil then
		return {
			Exp = 0,
			Wen = 0
		}
	end

	local exp = math.round(v5 * gameSettings.expPerLevel * p.Level)
	return {
		Exp = exp,
		Wen = math.round(exp * gameSettings.wenPerExp)
	}
end

function BossHunts.MaxLevelMastery(p)
	return (math.round(BossHunts.Rewards(p).Exp * gameSettings.expPerMasteryDefault / gameSettings.expPerLevel))
end

function BossHunts.Factor(p)
	if BossHunts.Sides[p.Side] == nil then
		return 1
	end

	local count = 0

	for _, v5 in Players:GetPlayers() do
		if BossHunts.Eligible(p, v5) then
			count += 1
		end
	end

	return v2[count] or 1
end

function BossHunts.Eligible(data, p)
	local side = BossHunts.Sides[data.Side]

	if side == nil then
		return false
	end

	local data2 = Utility.GetData(p)

	if data2 == nil or table.find(side.Race, data2.Race.Value) == nil then
		return false
	end

	local v5 = data2.Exp.Goal.Value / gameSettings.expPerLevel
	return data.MinLevel <= v5 and (data.MaxLevel == nil or v5 <= data.MaxLevel)
end

function BossHunts.QuestName(p: string)
	return (`Eliminate {p}`)
end

function BossHunts.Definitions()
	local result = {}

	for _, hunt in BossHunts.Hunts do
		local side = BossHunts.Sides[hunt.Side]
		local npc = BossHunts.Npc(hunt)
		local formatted = `Defeat {npc}`
		result[BossHunts.QuestName(npc)] = {
			OfferNpc = false,
			KillCreditShare = 0.1,
			QuestInstance = parentModule.Quest(
				BossHunts.QuestName(npc),
				parentModule.QuestTask(formatted, 1, hunt.Code)
			),
			Rewards = BossHunts.Rewards(hunt),
			MaxLevelMastery = BossHunts.MaxLevelMastery(hunt),
			Timer = 1800,
			NoCancel = true,
			Requirements = {
				Race = side.Race,
				Level = hunt.MinLevel,
				MaxLevel = hunt.MaxLevel
			},
			Category = "BossHunt",
			Markers = {
				[formatted] = {
					Npc = npc
				}
			},
			CompletionNotify = {
				Icon = side.Voice.Icon,
				Sound = side.Voice.Sound,
				Text = side.Completion
			}
		}
	end

	return result
end

return BossHunts