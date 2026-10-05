local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Stats = require(script.Parent.Stats)
local SkillTreeConfig = require(script.SkillTreeConfig)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local Clans = require(ReplicatedStorage.CAM.Clans)
local ClanSkills = require(ReplicatedStorage.CAM.Clans.ClanSkills)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local SkillTreeholder = {
	Default = {
		{
			Name = "Character",
			IsBranch = true,
			Locked = false,
			AdditionalOffset = 0.47123889803846897,
			Icon = "rbxassetid://99091529957184",
			{
				Name = "Innate Skills",
				IsBranch = true,
				Locked = false,
				Icon = "rbxassetid://79876196724691",
				{
					Name = "Double Jump",
					Icon = "rbxassetid://125038522401568"
				},
				{
					Name = "Wall Climb",
					Icon = "rbxassetid://92792306247710"
				}
			},
			{
				Name = "Stats",
				IsBranch = true,
				Locked = false,
				RotationBias = 0.7853981633974483,
				Icon = "rbxassetid://101406410024507"
			}
		}
	},
	RequirementsSolver = {
		SkillPoints = require(script.Requirements.SkillPoints),
		Mastery = require(script.Requirements.Mastery),
		Boss = require(script.Requirements.Boss)
	}
}
local v2 = {
	Blocking = true
}

for k, v3 in SkillTreeConfig do
	local v4 = nil
	local v5 = nil

	for i = 1, math.floor(gameSettings.maxLevel / v3.Ratio) do
		local statValue = Stats.GetStatValue(v3.Value, i, v3.IsRatio)
		local v6

		if v3.IsRatio or v4 == nil then
			v6 = statValue
		else
			v6 = statValue - v4 or statValue
		end

		local v7 = math.round(v6 * 100) / 100
		local v8 = {
			Name = k,
			Icon = v3.Icon,
			ProgressionIndex = i,
			DisplayName = `{v3.Prefix or v3.IsRatio and "" or "+"}{v7}{v3.Postfix or ""} {k}`
		}

		if v5 == nil then
			v8.IsBranch = true
			table.insert(SkillTreeholder.Default[1][2], v8)
			v5 = v8
		else
			table.insert(v5, v8)
		end

		v4 = statValue
	end
end

function SkillTreeholder.GetPowers(localPlayer)
	if localPlayer == nil then
		localPlayer = Players.LocalPlayer
	end

	if localPlayer == nil then
		return
	end

	local data = Utility.GetData(localPlayer)

	if data == nil then
		return
	end

	local v3 = {}
	local v4 = {
		Weapons = {},
		Power = {},
		Clan = {}
	}

	for _, v5 in Utility.ItemBags(data) do
		for _, child in ipairs(v5:GetChildren()) do
			local item = Items[child.Name]

			if not ItemRequirements.SatisfiesEquip(data, child.Name) then
				continue
			end

			local skillCategory = item ~= nil and item.SkillCategory or child.Name
			local v6 = Items[skillCategory] or item

			if item == nil or item.Skills == nil or not (#item.Skills ~= 1 or item.Skills[1].Name ~= "Blocking") or v3[skillCategory] then
				continue
			end

			v3[skillCategory] = true
			table.insert(v4.Weapons, {
				Name = skillCategory,
				Icon = v6.Icon,
				Skills = v6.Skills
			})
		end
	end

	if (data.Race.Value == "Demon" or data.Race.Value == "Hybrid") and DemonArts[data.Powers.DemonArt.Value] ~= nil and DemonArts[data.Powers.DemonArt.Value].CustomPower ~= true then
		local demonArt = DemonArts[data.Powers.DemonArt.Value]
		table.insert(v4.Power, {
			Name = data.Powers.DemonArt.Value,
			Icon = demonArt.Icon,
			Skills = demonArt.Skills
		})
	end

	if (data.Race.Value == "Slayer" or data.Race.Value == "Human" or data.Race.Value == "Hybrid") and Breathings[data.Powers.Breathing.Value] ~= nil and Breathings[data.Powers.Breathing.Value].CustomPower ~= true then
		local breathing = Breathings[data.Powers.Breathing.Value]
		table.insert(v4.Power, {
			Name = data.Powers.Breathing.Value,
			Icon = breathing.Icon,
			Skills = breathing.Skills
		})
	end

	local fightingStyle = data.Powers:FindFirstChild("FightingStyle")
	local v5

	if fightingStyle ~= nil then
		v5 = FightingStyles[fightingStyle.Value] or nil
	end

	if v5 ~= nil and ItemRequirements.Passes(data, v5.Requirements) then
		table.insert(v4.Power, {
			Name = fightingStyle.Value,
			Icon = v5.Icon,
			Skills = v5.Skills
		})
	end

	local clan = data:FindFirstChild("Clan")
	local name

	if clan ~= nil then
		name = clan.Value or nil
	end

	if ClanSkills.HasSkills(name) then
		local clan2 = Clans.GetClan(name)
		table.insert(v4.Clan, {
			Name = name,
			Icon = clan2 ~= nil and clan2.icon or Items[ClanSkills.TOOL_NAME].Icon,
			Skills = ClanSkills.SkillsFor(name, localPlayer)
		})
	end

	return v4
end

function SkillTreeholder.GetBranches()
	local clone = table.clone(SkillTreeholder.Default)
	local powers = SkillTreeholder.GetPowers()

	if powers == nil then
		return clone
	end

	if #powers.Power > 0 then
		for _, v3 in ipairs(powers.Power) do
			local v4 = {
				Name = v3.Name,
				IsBranch = true,
				Locked = false,
				Icon = v3.Icon
			}

			for _, skill in ipairs(v3.Skills) do
				if not v2[skill.Name] then
					table.insert(v4, {
						Name = skill.Name
					})
				end
			end

			table.insert(clone, v4)
		end
	end

	if #powers.Weapons > 0 then
		for _, weapon in ipairs(powers.Weapons) do
			local v3 = {
				Name = weapon.Name,
				Locked = false,
				Icon = weapon.Icon,
				IsBranch = true
			}

			for _, skill in ipairs(weapon.Skills) do
				if not v2[skill.Name] then
					table.insert(v3, {
						Name = skill.Name
					})
				end
			end

			table.insert(clone, v3)
		end
	end

	if #powers.Clan > 0 then
		for _, v3 in ipairs(powers.Clan) do
			local v4 = {
				Name = v3.Name,
				Locked = false,
				Icon = v3.Icon,
				IsBranch = true
			}

			for _, skill in ipairs(v3.Skills) do
				if not v2[skill.Name] then
					table.insert(v4, {
						Name = skill.Name
					})
				end
			end

			table.insert(clone, v4)
		end
	end

	return clone
end

function SkillTreeholder.ResetTree(p, p2: string?)
	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	local skillPointsSpent = data:FindFirstChild("SkillPointsSpent")

	for _, child in data.SkillTreeUnlockedList:GetChildren() do
		if not (p2 == nil or child.Name == p2) then
			continue
		end

		local child2 = skillPointsSpent and skillPointsSpent:FindFirstChild(child.Name)

		if child2 == nil then
			for i = 1, child.Value do
				local requirementsAt, v3 = Stats.GetRequirementsAt(p, child.Name, i)

				for k, v4 in requirementsAt do
					if not SkillTreeholder.RequirementsSolver[k].Persistent then
						SkillTreeholder.RequirementsSolver[k].Reset(p, v3, v4)
					end
				end
			end
		else
			SkillTreeholder.RequirementsSolver.SkillPoints.Reset(p, child.Name, child2.Value)
			child2:Destroy()
		end

		child:Destroy()
	end
end

function SkillTreeholder.ResetPowerBranch(p, childName: string)
	local data = Utility.GetData(p)

	if data == nil then
		return nil
	end

	local powers = data:FindFirstChild("Powers")
	local child

	if powers ~= nil then
		child = powers:FindFirstChild(childName) or nil
	end

	local value

	if child ~= nil then
		value = child.Value or nil
	end

	if value == nil or value == "" then
		return nil
	end

	SkillTreeholder.ResetTree(p, value)
	return value
end

function SkillTreeholder.TransferBranch(p, childName: string, name: string)
	local data = Utility.GetData(p)

	if data == nil or childName == name then
		return
	end

	local skillTreeUnlockedList = data.SkillTreeUnlockedList
	local child = skillTreeUnlockedList:FindFirstChild(childName)

	if child == nil then
		return
	end

	local v3 = (ClanSkills.SkillSets[name] or DemonArts[name] or Breathings[name] or FightingStyles[name]) == nil and 0 or math.min(
		child.Value,
		Stats.GetMaxIndexForCategory(name)
	)
	local child2 = skillTreeUnlockedList:FindFirstChild(name)

	if v3 == 0 or child2 ~= nil and v3 <= child2.Value then
		SkillTreeholder.ResetTree(p, childName)
		return
	end

	SkillTreeholder.ResetTree(p, name)
	local v4 = 0

	for i = v3 + 1, child.Value do
		v4 += Stats.GetRequirementsAt(p, childName, i).SkillPoints or 0
	end

	local skillPointsSpent = data:FindFirstChild("SkillPointsSpent")
	local child3 = skillPointsSpent and skillPointsSpent:FindFirstChild(childName)

	if child3 ~= nil then
		v4 = math.min(v4, child3.Value)
		local v5 = skillPointsSpent:FindFirstChild(name)

		if v5 == nil then
			v5 = Instance.new("IntValue")
			v5.Name = name
			v5.Parent = skillPointsSpent
		end

		v5.Value += child3.Value - v4
		child3:Destroy()
	end

	data.SkillPoints.Value += v4
	local intValue = Instance.new("IntValue")
	intValue.Name = name
	intValue.Value = v3
	intValue.Parent = skillTreeUnlockedList
	child:Destroy()
end

return SkillTreeholder