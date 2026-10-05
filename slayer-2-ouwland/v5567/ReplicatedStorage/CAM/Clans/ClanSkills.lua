local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
require(ReplicatedStorage.CAM.Global.Types.ItemTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local parentModule = require(script.Parent)
local v = nil

local function itemRequirements()
	if v == nil then
		local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
		v = ItemRequirements
	end

	return v
end

local ClanSkillIcons = require(script.Parent.ClanSkillIcons)
local placeholder = ClanSkillIcons.Placeholder

local function iconFor(p: string)
	local skill = ClanSkillIcons.Skills[p]

	if skill == nil or skill == "" then
		return placeholder
	end

	return skill
end

local ClanSkills = {
	TOOL_NAME = "Clan Skills"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function blockingOnly()
	return {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		}
	}
end

local function toSkillData(skill)
	local v2 = {
		Name = skill.name,
		Key = skill.key,
		CoolDown = skill.cooldown or 1,
		CooldownGroup = skill.cooldownGroup,
		icon = 0,
		Max_Hold = 0,
		Stamina = 0,
		SkillStats = 0,
		PerformanceStats = 0,
		ToolbarStats = 0,
		ActiveToolStats = 0,
		Requirements = 0,
		RequiresModeBar = 0,
		RequiresAura = 0
	}
	local name = skill.name
	local skill2 = ClanSkillIcons.Skills[name]

	if skill2 == nil or skill2 == "" then
		skill2 = placeholder
	end

	v2.icon = skill2
	v2.Max_Hold = skill.maxHold
	v2.Stamina = skill.stamina
	v2.SkillStats = skill.skillStats
	v2.PerformanceStats = skill.performanceStats
	v2.ToolbarStats = skill.toolbarStats
	v2.ActiveToolStats = skill.activeToolStats
	v2.Requirements = skill.requirements
	v2.RequiresModeBar = skill.mode and true or nil
	v2.RequiresAura = skill.requiresAura
	return v2
end

local function buildSkills(p)
	local result = blockingOnly() -- equivalent call inferred; original call site unknown

	for _, skill in p.skills do
		if skill.aura == nil and skill.requirements == nil and skill.requiresAura == nil then
			table.insert(result, (toSkillData(skill)))
		end
	end

	for _, skill in p.skills do
		if skill.aura ~= nil and skill.requirements == nil and skill.requiresAura == nil then
			table.insert(result, (toSkillData(skill)))
		end
	end

	for _, skill in p.skills do
		if skill.requirements ~= nil and skill.requiresAura == nil then
			table.insert(result, (toSkillData(skill)))
		end
	end

	for _, skill in p.skills do
		if skill.requiresAura ~= nil then
			table.insert(result, (toSkillData(skill)))
		end
	end

	return result
end

ClanSkills.SkillSets = {}

for k, v2 in parentModule.GetAll() do
	if #v2.skills > 0 then
		ClanSkills.SkillSets[k] = {
			Skills = buildSkills(v2),
			SkillCategory = k
		}
	end
end

function ClanSkills.SkillsFor(p: string?, p2)
	local v2

	if p ~= nil then
		v2 = ClanSkills.SkillSets[p] or nil
	end

	local v3 = v2 == nil and blockingOnly() or v2.Skills or blockingOnly()

	if p2 == nil then
		return v3
	end

	local data = Utility.GetData(p2)
	local result = {}

	for _, v4 in v3 do
		if v4.Requirements ~= nil then
			if v == nil then
				local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
				v = ItemRequirements
			end

			if not v.Passes(data, v4.Requirements) then
				continue
			end
		end

		table.insert(result, v4)
	end

	return result
end

ClanSkills.AuraSkills = {}
ClanSkills.AurasByClan = {}
ClanSkills.ModeByClan = {}

for k, v2 in parentModule.GetAll() do
	for _, skill in v2.skills do
		if skill.aura ~= nil then
			ClanSkills.AuraSkills[skill.name] = skill.aura
			local skills = ClanSkills.AurasByClan[k]

			if skills == nil then
				skills = {}
				ClanSkills.AurasByClan[k] = skills
			end

			table.insert(skills, skill)
		end

		if skill.mode and ClanSkills.ModeByClan[k] == nil then
			ClanSkills.ModeByClan[k] = skill
		end
	end
end

function ClanSkills.AurasFor(p: string?)
	return p ~= nil and ClanSkills.AurasByClan[p] or {}
end

function ClanSkills.HasSkills(p: string?)
	return p ~= nil and ClanSkills.SkillSets[p] ~= nil
end

function ClanSkills.ModeFor(p: string?)
	return p ~= nil and ClanSkills.ModeByClan[p] or nil
end

function ClanSkills.HasModeBar(p: string?)
	return ClanSkills.ModeFor(p) ~= nil
end

return ClanSkills