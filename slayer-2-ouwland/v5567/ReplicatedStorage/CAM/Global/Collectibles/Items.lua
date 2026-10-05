local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local global = CAM:WaitForChild("Global")
local powers = global:WaitForChild("Powers")
local items = ReplicatedStorage:WaitForChild("Items")
local PlayerProfile = require(global:WaitForChild("PlayerProfile"))
require(global.Types.ItemTypes)
local Items = {}

for _, v in ipairs(items:QueryDescendants("ModuleScript:not([$ignore])")) do
	local name = v.Name
	local module = require(v)
	Items[name] = module
	local folder = v:FindFirstAncestorOfClass("Folder")

	if Items[v.Name].Category == nil then
		Items[v.Name].Category = folder == nil and "Items" or folder.Name or "Items"
	end

	if Items[v.Name].InventoryCategory ~= nil then
		continue
	end

	local category

	if folder ~= nil then
		category = folder:GetAttribute("Category")
	end

	local v2 = Items[v.Name]

	if type(category) ~= "string" or category == "" then
		category = folder == nil and "Items" or folder.Name
	end

	v2.InventoryCategory = category
end

function doSkillThing(category: string, data, value: string, p2: number)
	if not PlayerProfile.skill_info[data.Name] then
		PlayerProfile.skill_info[data.Name] = {
			Cooldown = data.CoolDown,
			Icon = data.icon or nil,
			Max_Hold_Time = data.Max_Hold or nil,
			UnholdStatus = data.UnholdStatus,
			CoolDownName = data.CoolDownName,
			CooldownGroup = data.CooldownGroup,
			SkillTreeRequirements = data.SkillTreeRequirements,
			Boss = data.Boss,
			Stamina = data.Stamina,
			RequiresModeBar = data.RequiresModeBar,
			RequiresAura = data.RequiresAura,
			Index = p2,
			CategoryType = value or "Weapon",
			Category = category
		}
	end
end

function lookInside(p: string, data, p2: string)
	if data == nil or p == nil then
		return
	end

	if PlayerProfile.mastery_categories._index == nil then
		PlayerProfile.mastery_categories._index = {}
	end

	if not PlayerProfile.mastery_categories._index[p] then
		PlayerProfile.mastery_categories._index[p] = true
		table.insert(PlayerProfile.mastery_categories, p)
	end

	if type(data.Mastery) == "string" then
		PlayerProfile.mastery_name_set[data.Mastery] = true
	end

	if data.Skills then
		local skillCategory = data.SkillCategory or p
		local count = 0

		if data.Skills[1].Name == "Blocking" then
			count += 1
		end

		for k, skill in data.Skills do
			if PlayerProfile.skill_info[skill.Name] then
				continue
			end

			if skill.State then
				for _, v in pairs(skill) do
					if typeof(v) ~= "table" then
						continue
					end

					v.CoolDownName = v.CoolDownName or skill.Name
					doSkillThing(skillCategory, v, p2, k - count)
				end
			else
				doSkillThing(skillCategory, skill, p2, k - count)
			end
		end
	end
end

local DemonArts, v, v2 = require(powers.DemonArts)

for k, demonArt in DemonArts, v, v2 do
	lookInside(k, demonArt, "Evil Art")
end

local Breathings, v3, v4 = require(powers.Breathings)

for k, breathing in Breathings, v3, v4 do
	lookInside(k, breathing, "Breathing")
end

local FightingStyles, v5, v6 = require(powers.FightingStyles)

for k, fightingStyle in FightingStyles, v5, v6 do
	lookInside(k, fightingStyle, "Fighting Style")
end

local PlayerProgression = require(global:WaitForChild("PlayerProgression"))

for k, grantedSkill in PlayerProgression.GrantedSkills do
	doSkillThing(k, grantedSkill.Skill, "Progression", 1)
end

for k, v7 in Items do
	lookInside(k, v7, "Weapon")
end

local ClanSkills = require(CAM:WaitForChild("Clans"):WaitForChild("ClanSkills"))

for k, skillSet in ClanSkills.SkillSets do
	lookInside(k, skillSet, "Clan")
end

return Items