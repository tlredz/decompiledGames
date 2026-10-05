local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local PlayerProfile = require(ReplicatedStorage.CAM.Global.PlayerProfile)
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)
require(ReplicatedStorage.CAM.Global.Types.ItemTypes)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)
local Clans = require(ReplicatedStorage.CAM.Clans)
local ClanSkills = require(ReplicatedStorage.CAM.Clans.ClanSkills)
local MasterySource = require(ReplicatedStorage.CAM.Global.Collectibles.MasterySource)
local FightingStyles2 = require(ReplicatedStorage.CAM.Global.Collectibles.FightingStyles)
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local Stats = {}
local v = {
	SkillPoints = {
		Start = 3,
		IncrementAmount = 3,
		TreeIndexFactor = 1
	}
}
local mastery2 = {
	Start = 14,
	IncrementAmount = 1,
	TreeIndexFactor = 13,
	PositionOffset = -1
}

function Stats.GetStatValue(p, value: number, flag: boolean?)
	local v3 = value or 1
	local v4 = flag and v3 or v3 - 1
	local v5 = p or 1 + (gameSettings.defaultSkillStatIncrementFactor or 0) * v4

	if typeof(v5) ~= "table" then
		return v5
	end

	if v5.Custom ~= nil and v5.Custom[v3] then
		return v5.Custom[v3]
	end

	local stepFactor = v5.StepFactor or gameSettings.defaultSkillStatIncrementFactor or 0
	local stepAccel = v5.StepAccel or 0
	return (v5.Start or 1) + stepFactor * v4 + stepAccel * (v4 * (v4 - 1) / 2)
end

function Stats.IsSkillUnlocked(p, category: string, value: number?)
	if p == nil or category == nil then
		return false
	end

	if gameSettings.manuallyUnlockedSkills[category] then
		return true
	end

	local data = Utility.GetData(p)

	if data == nil then
		return false
	end

	local skillInfoFor = Stats.GetSkillInfoFor(p, category)

	if skillInfoFor ~= nil and skillInfoFor.CategoryType == "Clan" and Clans.TestClans[skillInfoFor.Category] ~= nil then
		return true
	end

	local CustomPower = require(ReplicatedStorage.CAM.Global.CustomPower)

	if CustomPower.Holds(p, category) then
		return true
	end

	if skillInfoFor ~= nil then
		category = skillInfoFor.Category or category
	end

	local index = skillInfoFor ~= nil and skillInfoFor.Index or value or 1
	local skillTreeUnlockedList = data:FindFirstChild("SkillTreeUnlockedList")
	local child = skillTreeUnlockedList and skillTreeUnlockedList:FindFirstChild(category)
	return child ~= nil and index <= child.Value
end

local function buildRequirements(data, p: string, p2: number)
	local skillTreeRule

	if data ~= nil then
		if data.CategoryType == "Breathing" or data.CategoryType == "Evil Art" or data.CategoryType == "Fighting Style" then
			skillTreeRule = Breathings[data.Category] ~= nil and Breathings[data.Category].SkillTreeRule or DemonArts[data.Category] ~= nil and DemonArts[data.Category].SkillTreeRule

			if not skillTreeRule then
				if FightingStyles[data.Category] == nil then
					skillTreeRule = false
				else
					skillTreeRule = FightingStyles[data.Category].SkillTreeRule
				end
			end
		elseif SkillTreeConfig[p] == nil then
			if Items[data.Category] == nil then
				skillTreeRule = false
			else
				skillTreeRule = Items[data.Category].SkillTreeRule
			end
		else
			local v3 = SkillTreeConfig[p]
			skillTreeRule = v3.Rule and {
				SkillPoints = v3.Rule
			}
		end
	end

	local clone = skillTreeRule or v

	if data ~= nil and (data.CategoryType == "Breathing" or data.CategoryType == "Evil Art" or data.CategoryType == "Weapon" or data.CategoryType == "Fighting Style") then
		local masterySource = MasterySource(data.Category)

		if masterySource and masterySource.Mastery ~= false and clone.Mastery == nil then
			clone = table.clone(clone)
			clone.Mastery = mastery2
		end
	end

	local result = {}

	for k, v3 in clone do
		local v4 = p2 + (v3.PositionOffset or 0)

		if v4 <= 0 then
			continue
		end

		local v5 = math.round(v3.Start + (v3.CustomPosValues ~= nil and v3.CustomPosValues[v4] or (v3.IncrementAmount or gameSettings.defaultSkillTreeItemPointIncrement) * ((v3.TreeIndexFactor or 1) * (v4 - 1))))

		if v5 > 0 then
			result[k] = v5
		end
	end

	if data ~= nil and data.Boss ~= nil then
		result.Boss = data.Boss
	end

	return result
end

local function nodeInfoAt(p, p2: string, p3: number)
	if SkillTreeConfig[p2] ~= nil then
		return p2, SkillTreeConfig[p2]
	end

	local v3 = ClanSkills.SkillSets[p2] or Breathings[p2] or DemonArts[p2] or FightingStyles[p2]

	if v3 == nil then
		for k, v4 in PlayerProfile.skill_info do
			if v4.Category == p2 and v4.Index == p3 then
				return k, v4
			end
		end

		local item = Items[p2]
		local v4

		if item ~= nil then
			v4 = item.Skills ~= nil and item.Skills[p3] or nil
		end

		if v4 == nil then
			return nil, nil
		end

		return v4.Name, Stats.GetSkillInfo(v4.Name)
	else
		local count = 0

		for _, skill in v3.Skills do
			if skill.Name == "Blocking" then
				continue
			end

			count += 1

			if count == p3 then
				return skill.Name, Stats.GetSkillInfoFor(p, skill.Name)
			end
		end

		return nil, nil
	end
end

function Stats.GetRequirementsAt(p, p2: string, p3: number)
	local v3, v4 = nodeInfoAt(p, p2, p3)
	return v4 ~= nil and v4.SkillTreeRequirements or buildRequirements(v4, p2, p3), v3 or p2
end

function Stats.GetRequirements(p, childName: string, value: number?)
	if p == nil or childName == nil then
		return
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	local skillInfoFor = Stats.GetSkillInfoFor(p, childName)
	local category

	if skillInfoFor == nil then
		category = childName
	else
		category = skillInfoFor.Category or childName
	end

	local v3 = skillInfoFor == nil and 1 or skillInfoFor.Index or value or 1
	local isSkillUnlocked = Stats.IsSkillUnlocked(p, childName, v3)
	local skillTreeRequirements = skillInfoFor and skillInfoFor.SkillTreeRequirements or buildRequirements(
		skillInfoFor,
		category,
		v3
	)

	if isSkillUnlocked and skillTreeRequirements and skillTreeRequirements.Mastery then
		local v4 = skillInfoFor and MasterySource(skillInfoFor.Category)

		if v4 and v4.Mastery ~= false then
			local mastery

			if type(v4.Mastery) == "string" then
				mastery = v4.Mastery
			elseif type(v4.Mastery) == "table" then
				mastery = v4.Mastery.Value or skillInfoFor.Category
			else
				mastery = skillInfoFor.Category
			end

			local incrementAmount = type(v4.Mastery) == "table" and v4.Mastery.IncrementAmount or gameSettings.expPerMasteryDefault
			local child = data.MasteryProgressionList:FindFirstChild(mastery)
			local v5 = 0

			if child then
				local goal = child:FindFirstChild("Goal")

				if goal then
					v5 = math.floor(goal.Value / incrementAmount)
				end
			end

			if v5 < skillTreeRequirements.Mastery then
				skillTreeRequirements = {
					Mastery = skillTreeRequirements.Mastery
				}
				isSkillUnlocked = false
			end
		end
	end

	if isSkillUnlocked and skillTreeRequirements and skillTreeRequirements.Boss then
		local CustomPower = require(ReplicatedStorage.CAM.Global.CustomPower)

		if not CustomPower.Holds(p, childName) then
			local boss = data.MetRequirements.Boss

			if boss:FindFirstChild(childName) == nil and boss:FindFirstChild(nodeInfoAt(p, category, v3) or childName) == nil then
				skillTreeRequirements = {
					Boss = skillTreeRequirements.Boss
				}
				isSkillUnlocked = false
			end
		end
	end

	return skillTreeRequirements, isSkillUnlocked
end

Stats.LOADOUT_CHANGED_AT = "LoadoutChangedAt"
Stats.LOADOUT_SETTLE = 2
local v3 = {
	Breathing = {
		Human = true,
		Slayer = true,
		Hybrid = true
	},
	["Evil Art"] = {
		Demon = true,
		Hybrid = true
	}
}
local v4 = {
	Breathing = "Breathing",
	["Evil Art"] = "DemonArt"
}
local v5 = {
	Breathing = Breathings,
	["Evil Art"] = DemonArts
}

function Stats.SourceCheck(p, skill2: string)
	local grantedSkill = PlayerProgression.GrantedSkills[skill2]
	local side

	if grantedSkill ~= nil then
		side = grantedSkill.Side
	end

	if side == nil then
		local v6 = PlayerProfile.skill_info[skill2]

		if v6 == nil or v6.CategoryType == nil or v6.Category == nil then
			return true
		end

		local categoryType = v6.CategoryType

		if categoryType ~= "Weapon" and categoryType ~= "Breathing" and categoryType ~= "Evil Art" and categoryType ~= "Fighting Style" and categoryType ~= "Clan" then
			return true
		end

		local data = Utility.GetData(p)

		if data == nil then
			return true
		end

		local inventory = data:FindFirstChild("Inventory")
		local v7

		if inventory ~= nil then
			v7 = inventory:FindFirstChild("Inventory") or nil
		end

		if v7 == nil then
			return true
		end

		local powers = data:FindFirstChild("Powers")
		local race = data:FindFirstChild("Race")
		local race2

		if race == nil then
			race2 = nil
		else
			race2 = race.Value or nil
		end

		for k, childName in v4 do
			local child

			if powers ~= nil then
				child = powers:FindFirstChild(childName) or nil
			end

			local v8

			if child ~= nil then
				v8 = v5[k][child.Value] or nil
			end

			if not (type(v8) == "table" and v8.CustomPower == true and type(v8.Skills) == "table") then
				continue
			end

			for _, skill in v8.Skills do
				if skill.Name == skill2 then
					return true
				end

				if skill.State ~= true then
					continue
				end

				for _, v9 in skill do
					if typeof(v9) == "table" and v9.Name == skill2 then
						return true
					end
				end
			end
		end

		local function fail()
			local clan = data:FindFirstChild("Clan")
			local breathing

			if powers ~= nil then
				breathing = powers:FindFirstChild("Breathing") or nil
			end

			local demonArt

			if powers ~= nil then
				demonArt = powers:FindFirstChild("DemonArt") or nil
			end

			local fightingStyle

			if powers ~= nil then
				fightingStyle = powers:FindFirstChild("FightingStyle") or nil
			end

			local v9 = {
				Skill = skill2,
				SkillCategory = v6.Category,
				SkillCategoryType = categoryType,
				Race = race2,
				Breathing = 0,
				EvilArt = 0,
				FightingStyle = 0,
				Clan = 0
			}
			local breathing2

			if breathing ~= nil then
				breathing2 = breathing.Value or nil
			end

			v9.Breathing = breathing2
			local evilArt

			if demonArt ~= nil then
				evilArt = demonArt.Value or nil
			end

			v9.EvilArt = evilArt
			local fightingStyle2

			if fightingStyle ~= nil then
				fightingStyle2 = fightingStyle.Value or nil
			end

			v9.FightingStyle = fightingStyle2
			local clan2

			if clan ~= nil then
				clan2 = clan.Value or nil
			end

			v9.Clan = clan2
			return false, v9
		end

		if categoryType == "Weapon" then
			local heldItem = Utility.HeldItem(data, v6.Category)

			if heldItem ~= nil and ItemRequirements.SatisfiesEquip(data, heldItem.Name) then
				return true
			end

			local flag = false

			for _, v8 in Utility.HeldEntries(data) do
				local item = Items[v8.Name]

				if not (v8.Name == v6.Category or item ~= nil and item.SkillCategory == v6.Category) then
					continue
				end

				if ItemRequirements.SatisfiesEquip(data, v8.Name) then
					return true
				else
					flag = true
				end
			end

			if flag then
				return false
			end

			return fail()
		elseif categoryType == "Breathing" or categoryType == "Evil Art" then
			local child

			if powers ~= nil then
				child = powers:FindFirstChild(v4[categoryType]) or nil
			end

			local value2

			if child ~= nil then
				value2 = child.Value or nil
			end

			if value2 ~= v6.Category or race2 ~= nil and v3[categoryType][race2] ~= true then
				return fail()
			end

			local v8 = v5[categoryType][value2]

			for _, v9 in Utility.HeldEntries(data) do
				local item = Items[v9.Name]
				local v10

				if item ~= nil then
					v10 = item[v4[categoryType]] or nil
				end

				if v10 ~= nil and Resolve.LaneCarries(v10, value2) and (v8 == nil or v8.Category == nil or v8.Category == item.Category) then
					return true
				end
			end

			return fail()
		elseif categoryType == "Fighting Style" then
			if FightingStyles2.For(p) == v6.Category then
				return true
			end

			local fightingStyle

			if powers ~= nil then
				fightingStyle = powers:FindFirstChild("FightingStyle") or nil
			end

			if fightingStyle == nil or fightingStyle.Value ~= v6.Category then
				return fail()
			end

			return false
		else
			if categoryType ~= "Clan" then
				return true
			end

			if Utility.HeldItem(data, ClanSkills.TOOL_NAME) == nil then
				return fail()
			end

			local clan = data:FindFirstChild("Clan")
			local skillsFor = ClanSkills.SkillsFor
			local v8

			if clan ~= nil then
				v8 = clan.Value or nil
			end

			for _, v9 in skillsFor(v8, p) do
				if v9.Name == skill2 then
					return true
				end

				if v9.State ~= true then
					continue
				end

				for _, v10 in v9 do
					if typeof(v10) == "table" and v10.Name == skill2 then
						return true
					end
				end
			end

			return fail()
		end
	else
		if PlayerProgression.Get(p, side) == nil or PlayerProgression.HasGrantedSkill(p, skill2) then
			return true
		end

		return false, {
			Skill = skill2,
			SkillCategory = `{side} ladder`,
			SkillCategoryType = "Progression"
		}
	end
end

function Stats.GetSkillInfo(p: string)
	if p == nil then
		return
	else
		return SkillTreeConfig[p] or PlayerProfile.skill_info[p]
	end
end

function Stats.GetSkillInfoFor(p, p2: string)
	local skillInfo = Stats.GetSkillInfo(p2)

	if skillInfo == nil or skillInfo.CategoryType ~= "Clan" or p == nil then
		return skillInfo
	end

	local data = Utility.GetData(p)
	local clan

	if data ~= nil then
		clan = data:FindFirstChild("Clan") or nil
	end

	local category

	if clan ~= nil then
		category = clan.Value or nil
	end

	if category == nil or category == skillInfo.Category then
		return skillInfo
	end

	local skillSet = ClanSkills.SkillSets[category]

	if skillSet == nil then
		return skillInfo
	end

	local count = 0

	for _, skill in skillSet.Skills do
		if skill.Name == "Blocking" then
			continue
		end

		count += 1

		if skill.Name ~= p2 then
			continue
		end

		local clone = table.clone(skillInfo)
		clone.Category = category
		clone.Index = count
		return clone
	end

	return skillInfo
end

function Stats.GetMaxIndexForCategory(p: string)
	if SkillTreeConfig[p] ~= nil then
		return (math.floor(gameSettings.maxLevel / SkillTreeConfig[p].Ratio))
	end

	local v6 = ClanSkills.SkillSets[p] or Breathings[p] or DemonArts[p] or FightingStyles[p]

	if v6 == nil then
		local item = Items[p]

		if item ~= nil and item.Skills ~= nil then
			return #item.Skills
		end

		local index = 0

		for _, v7 in PlayerProfile.skill_info do
			if not (v7.Category == p and typeof(v7.Index) == "number" and index < v7.Index) then
				continue
			end

			index = v7.Index
		end

		if index > 0 then
			return index
		end

		return 1
	else
		local count = 0

		for _, skill in v6.Skills do
			if skill.Name ~= "Blocking" then
				count += 1
			end
		end

		return count
	end
end

function Stats.GetSkillCategory(p: string)
	if p == nil then
		return
	end

	if PlayerProfile.skill_info[p] == nil then
		return nil
	end

	return PlayerProfile.skill_info[p].CategoryType
end

return Stats