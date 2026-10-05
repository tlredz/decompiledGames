local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ItemTypes)
require(ReplicatedStorage.CAM.Global.Types.SkillStatsTypes)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local stats = {}
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeKey(value: string)
	local v2 = string.lower(value)

	if v2 == "dontcancelonplayover" then
		return "dont_cancel_on_play_over"
	end

	return v2
end

local function normalizeStats(items)
	local result = {}

	for k, item in items do
		local v2 = tostring(k)
		result[normalizeKey(v2)] = item
	end

	return result
end

local function setSkillStats(p: string, p2, flag: boolean?)
	if stats[p] ~= nil and flag ~= true then
		return false
	end

	local stats2 = normalizeStats(p2)
	local ranked = stats2.ranked
	stats2.ranked = nil
	stats[p] = stats2
	v[p] = nil

	if typeof(ranked) ~= "table" then
		return true
	end

	local clone = table.clone(stats2)

	for k, v2 in normalizeStats(ranked) do
		if v2 == false then
			v2 = nil
		end

		clone[k] = v2
	end

	v[p] = clone
	return true
end

local function registerSkillData(p, flag: boolean?)
	if p == nil then
		return
	end

	local name = p.Name

	if name == nil or name == "" then
		return
	end

	if p.SkillStats ~= nil then
		setSkillStats(name, p.SkillStats, flag)
	end
end

local function registerSkillEntry(skill, override: boolean?)
	if skill.State then
		if skill ~= nil then
			local name = skill.Name

			if name ~= nil and name ~= "" and skill.SkillStats ~= nil then
				setSkillStats(name, skill.SkillStats, override)
			end
		end

		for _, v2 in skill do
			if typeof(v2) ~= "table" then
				continue
			end

			local name = v2.Name or skill.Name

			if not (name ~= nil and name ~= "") then
				continue
			end

			local skillStats = v2.SkillStats

			if skillStats ~= nil then
				setSkillStats(name, skillStats, override)
			end
		end
	else
		if skill == nil then
			return
		end

		local name = skill.Name

		if name ~= nil then
			if name == "" then
				return
			end

			if skill.SkillStats ~= nil then
				setSkillStats(name, skill.SkillStats, override)
			end
		end
	end
end

local SkillStats = {
	Icons = {
		iframe = "http://www.roblox.com/asset/?id=13865751098",
		stun_bypass_skill = "http://www.roblox.com/asset/?id=14826942730",
		cancel_bypass = "http://www.roblox.com/asset/?id=14797470620",
		skills_to_play_over = "http://www.roblox.com/asset/?id=15443500438",
		strict_stun = "rbxassetid://15658788148",
		counter = "http://www.roblox.com/asset/?id=15687677061"
	},
	RegisterItemSet = function(items, p)
		if items == nil then
			return
		end

		local override = p and p.Override

		for _, item in items do
			if not (item and item.Skills) then
				continue
			end

			for _, skill in item.Skills do
				registerSkillEntry(skill, override)
			end
		end
	end,
	Get = function(p: string, character)
		local v2 = v[p]

		if v2 ~= nil and character ~= nil then
			local playerFromCharacter = Players:GetPlayerFromCharacter(character)

			if playerFromCharacter ~= nil and CombatMode.IsRanked(playerFromCharacter) then
				return v2
			end
		end

		return stats[p]
	end
}

for k, v2 in {
	Blocking = {
		stun_bypass_skill = true
	},
	Dash = {
		skills_to_play_over = {
			Blocking = true
		},
		dont_cancel_on_play_over = {
			Blocking = true
		}
	}
} do
	setSkillStats(k, v2, true)
end

local CAM = ReplicatedStorage.CAM
local global = CAM.Global
SkillStats.RegisterItemSet(require(global.Collectibles.Items))
SkillStats.RegisterItemSet(require(global.Powers.Breathings))
SkillStats.RegisterItemSet(require(global.Powers.DemonArts))
SkillStats.RegisterItemSet(require(global.Powers.FightingStyles))
local registerItemSet = SkillStats.RegisterItemSet
local ClanSkills = require(CAM.Clans.ClanSkills)
registerItemSet(ClanSkills.SkillSets)
local PlayerProgression = require(global.PlayerProgression)
local skills = {}

for _, grantedSkill in PlayerProgression.GrantedSkills do
	table.insert(skills, grantedSkill.Skill)
end

SkillStats.RegisterItemSet({
	LadderGrants = {
		Skills = skills
	}
})
return SkillStats