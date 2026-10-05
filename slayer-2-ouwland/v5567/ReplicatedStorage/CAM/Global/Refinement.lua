local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local v = {
	[0] = 1,
	1.05,
	1.1,
	1.2,
	1.3,
	1.4,
	1.55,
	1.7,
	1.9,
	2,
	3
}
local v2 = {}
local Refinement = {
	MaxLevel = 10,
	GreatStep = 3,
	GuardItem = "Refinement Guard",
	GuardGreatMultiplier = 1.5,
	SmeltRate = {
		From = "Refinement Ore",
		FromCount = 5,
		To = "Mythic Refinement Ore",
		ToCount = 1
	},
	RankedShare = 0.5
}

for k, v3 in v do
	v2[k] = 1 + (v3 - 1) / 2
end

local v3 = {
	[0] = {
		Wen = 125,
		Ore = "Refinement Ore",
		OreCount = 2,
		FailBp = 0,
		SuccessBp = 9000,
		GreatBp = 1000
	},
	[1] = {
		Wen = 250,
		Ore = "Refinement Ore",
		OreCount = 3,
		FailBp = 500,
		SuccessBp = 8500,
		GreatBp = 1000
	},
	[2] = {
		Wen = 500,
		Ore = "Refinement Ore",
		OreCount = 5,
		FailBp = 1200,
		SuccessBp = 8000,
		GreatBp = 800
	},
	[3] = {
		Wen = 1000,
		Ore = "Refinement Ore",
		OreCount = 8,
		FailBp = 2500,
		SuccessBp = 6900,
		GreatBp = 600
	},
	[4] = {
		Wen = 2000,
		Ore = "Refinement Ore",
		OreCount = 12,
		FailBp = 4500,
		SuccessBp = 5100,
		GreatBp = 400
	},
	[5] = {
		Wen = 3250,
		Ore = "Mythic Refinement Ore",
		OreCount = 1,
		FailBp = 6500,
		SuccessBp = 3250,
		GreatBp = 250
	},
	[6] = {
		Wen = 5000,
		Ore = "Mythic Refinement Ore",
		OreCount = 2,
		FailBp = 7850,
		SuccessBp = 2000,
		GreatBp = 150
	},
	[7] = {
		Wen = 7500,
		Ore = "Mythic Refinement Ore",
		OreCount = 2,
		FailBp = 9150,
		SuccessBp = 800,
		GreatBp = 50
	},
	[8] = {
		Wen = 12500,
		Ore = "Mythic Refinement Ore",
		OreCount = 3,
		FailBp = 9450,
		SuccessBp = 550,
		GreatBp = 0
	},
	[9] = {
		Wen = 25000,
		Ore = "Mythic Refinement Ore",
		OreCount = 4,
		FailBp = 9925,
		SuccessBp = 75,
		GreatBp = 0
	}
}
local v4 = {}

for k, v5 in v3 do
	if v5.FailBp == 0 then
		v4[k] = v5
	else
		local greatBp = math.round(v5.GreatBp * Refinement.GuardGreatMultiplier)
		v4[k] = {
			Wen = v5.Wen,
			Ore = v5.Ore,
			OreCount = v5.OreCount,
			FailBp = v5.FailBp,
			SuccessBp = v5.SuccessBp - (greatBp - v5.GreatBp),
			GreatBp = greatBp
		}
	end
end

local v5 = {}

for k, v6 in {
	{
		SuccessBp = 9500,
		Guards = 1
	},
	{
		SuccessBp = 9000,
		Guards = 2
	},
	{
		SuccessBp = 8000,
		Guards = 3
	},
	{
		SuccessBp = 7000,
		Guards = 4
	},
	{
		SuccessBp = 6000,
		Guards = 5
	},
	{
		SuccessBp = 5000,
		Guards = 7
	},
	{
		SuccessBp = 4000,
		Guards = 9
	},
	{
		SuccessBp = 3000,
		Guards = 11
	},
	{
		SuccessBp = 2000,
		Guards = 13
	},
	{
		SuccessBp = 1500,
		Guards = 15
	}
} do
	local v7 = v3[k - 1]
	v5[k] = {
		Wen = v7.Wen,
		Ore = v7.Ore,
		OreCount = v7.OreCount,
		SuccessBp = v6.SuccessBp,
		Guards = v6.Guards
	}
end

function Refinement.GetMultiplier(p: number?)
	return v[math.clamp(math.floor(tonumber(p) or 0), 0, Refinement.MaxLevel)]
end

function Refinement.GetStatMultiplier(p: string, p2: string, p3: number?, p4)
	local refineStats = Refinement.GetRefineStats(p)
	local index = table.find(refineStats, p2)

	if index == nil then
		return 1
	end

	local v6 = math.clamp(math.floor(tonumber(p3) or 0), 0, Refinement.MaxLevel)
	local item = Items[p]
	local v7

	if item == nil then
		v7 = false
	else
		v7 = item.Stats ~= nil
	end

	local secondaryRefineShare

	if item ~= nil then
		secondaryRefineShare = item.SecondaryRefineShare
	end

	local v8

	if index == 1 and not v7 then
		v8 = v[v6]
	elseif secondaryRefineShare == nil then
		v8 = v2[v6]
	else
		v8 = 1 + (v[v6] - 1) * secondaryRefineShare
	end

	if p4 ~= nil and CombatMode.IsRanked(p4) then
		return 1 + (v8 - 1) * Refinement.RankedShare
	end

	return v8
end

function Refinement.ResolveOreCost(p, p2)
	if p2.Ore == Refinement.SmeltRate.To then
		local v6 = math.min(Refinement.GetHeldCount(p, p2.Ore), p2.OreCount)
		local v7 = p2.OreCount - v6

		if not (v7 <= 0) then
			local v8 = v7 * Refinement.SmeltRate.FromCount
			local v9 = {
				[Refinement.SmeltRate.From] = v8
			}

			if v6 > 0 then
				v9[p2.Ore] = v6
			end

			return v9, v8
		end
	end

	return {
		[p2.Ore] = p2.OreCount
	}, 0
end

function Refinement.GetRung(p: number, flag: boolean?)
	if flag then
		return v4[p]
	end

	return v3[p]
end

function Refinement.GetTransfer(p: number)
	return v5[p]
end

function Refinement.GetHeldMultiplier(p, p2: string)
	local get_equipped_tool = Character_info_provider.Get_equipped_tool(p)

	if typeof(get_equipped_tool) ~= "Instance" or get_equipped_tool.Name ~= p2 then
		return 1
	end

	local refineLevel = get_equipped_tool:FindFirstChild("RefineLevel")

	if refineLevel == nil then
		return 1
	end

	return (Refinement.GetMultiplier(refineLevel.Value))
end

function Refinement.IsRefinable(p: string)
	local item = Items[p]

	if item == nil then
		return false
	end

	if item.Refinable ~= nil then
		return item.Refinable == true
	end

	if item.HasCombat ~= true or item.ActiveToolStats == nil then
		return false
	end

	for _, v6 in Refinement.GetRefineStats(p) do
		if (item.ActiveToolStats[v6] or 0) ~= 0 then
			return true
		end
	end

	return false
end

function Refinement.GetHeldCount(p, p2: string)
	local heldItem = Utility.HeldItem(p, p2)

	if heldItem == nil then
		return 0
	end

	local amount = heldItem:FindFirstChild("Amount")
	return amount ~= nil and amount.Value or 1
end

local v6 = { "Additional Damage" }

function Refinement.GetRefineStats(p: string)
	local item = Items[p]
	return item ~= nil and item.RefineStats or v6
end

for _, v7 in { v3, v4 } do
	for k, v8 in v7 do
		local v9

		if v8.SuccessBp >= 0 then
			v9 = v8.FailBp + v8.SuccessBp + v8.GreatBp == 10000
		else
			v9 = false
		end

		assert(v9, (`Refinement rung {k}: odds must sum to 10000 basis points`))
	end
end

for i = 1, Refinement.MaxLevel do
	local v7 = v5[i]
	local v8

	if v7 == nil or not (v7.SuccessBp >= 0 and v7.SuccessBp <= 10000) then
		v8 = false
	else
		v8 = v7.Guards >= 1
	end

	assert(v8, (`Refinement transfer {i}: needs a row with SuccessBp 0..10000 and at least 1 Guard`))
end

return Refinement