require(script.Parent.Types)
local v = {
	["1"] = {
		Name = "Reel Boost",
		Job = "Fishing",
		Description = "Increases progress gained and reduces progress lost while skill is active.",
		RequiredCharge = 3,
		SkillTime = 10,
		Rarity = 1,
		ChargeOnCatch = 1
	},
	["2"] = {
		Name = "Instant Reaction",
		Job = "Fishing",
		Description = "Instantly reacts to any fish biting the line while skill is active.",
		RequiredCharge = 3,
		SkillTime = 20,
		Rarity = 2,
		ChargeOnCatch = 1
	},
	["3"] = {
		Name = "Lucky Cast",
		Job = "Fishing",
		Description = "Increases chance for finding rare fish while skill is active.",
		RequiredCharge = 5,
		SkillTime = 60,
		Rarity = 5,
		ChargeOnCatch = 1
	},
	["4"] = {
		Name = "Calming Technique",
		Job = "Fishing",
		Description = "Calms fish while skill is active, making them move slower.",
		RequiredCharge = 5,
		SkillTime = 5,
		Rarity = 2,
		ChargeOnCatch = 1
	},
	["5"] = {
		Name = "Conserve Bait",
		Job = "Fishing",
		Description = "30% Chance for bait to not be consumed while skill is active.",
		RequiredCharge = 10,
		SkillTime = 120,
		Rarity = 4,
		ChargeOnCatch = 1
	},
	["6"] = {
		Name = "Experience Sharing",
		Job = "Fishing",
		Description = "Shares 10% of all fishing-related experience gained with nearby players while skill is active. Additionally, the user will also receive this bonus experience.",
		RequiredCharge = 5,
		SkillTime = 120,
		Rarity = 3,
		ChargeOnCatch = 1
	}
}

for _, v2 in v do
	v2.Mastery = 1
	v2.Cooldown = 1
end

local function getSkillFromName(p: string)
	for _, v2 in v do
		if v2.Name == p then
			return v2
		end
	end

	return nil
end

local v2 = {
	["1"] = {
		Name = "Fishing Rod",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	},
	["2"] = {
		Name = "Gold Rod",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	},
	["3"] = {
		Name = "Shell Rod",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	},
	["4"] = {
		Name = "Shark Rod",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	},
	["5"] = {
		Name = "Treasure Rod",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	},
	["6"] = {
		Name = "Admin Rod",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	},
	["7"] = {
		Name = "Shark (Corrupted)",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	},
	["8"] = {
		Name = "Shell (Celestial)",
		MaxMastery = 100,
		DefaultSkill = "Reel Boost"
	}
}
local v3 = nil
v3 = {
	GenericToolNames = {
		Fishing = "Fishing Rod"
	},
	GetJobToolInfo = function(p: string)
		for k, v4 in v2 do
			if v4.Name == p then
				return v4, (tostring(k))
			end
		end

		return nil
	end,
	GetSkillInfoFromId = function(p: number)
		return v[p] or v["1"]
	end,
	GetSkillIdFromName = function(p: string)
		for k, v4 in v do
			if v4.Name == p then
				return (tostring(k))
			end
		end
	end,
	GetJobToolIdFromName = function(p: string)
		for k, v4 in v2 do
			if v4.Name == p then
				return (tostring(k))
			end
		end

		return nil
	end,
	GetSkillInfo = function(p: string)
		for _, v4 in v do
			if v4.Name == p then
				return v4
			end
		end

		return nil
	end,
	GetSkillChargeAlpha = function(instance)
		return instance:GetAttribute("SkillChargeAlpha")
	end,
	GetSkillName = function(instance)
		local scrollModifier_Skill = instance:GetAttribute("ScrollModifier_Skill")

		if scrollModifier_Skill then
			return v3.GetSkillInfo(scrollModifier_Skill).Name
		end

		return v3.GetSkillInfoFromId(instance:GetAttribute("SkillId")).Name
	end,
	GetSkill = function(instance)
		local scrollModifier_Skill = instance:GetAttribute("ScrollModifier_Skill")

		if scrollModifier_Skill then
			return v3.GetSkillInfo(scrollModifier_Skill)
		end

		return v3.GetSkillInfoFromId(instance:GetAttribute("SkillId"))
	end,
	GetInfo = function(p)
		return v3.GetJobToolInfo(p.Name)
	end,
	GetAllSkills = function()
		return v
	end,
	GetSkillRarityColor = function(p: number)
		if p == 4 then
			return Color3.new(0.74902, 0.65098, 1)
		elseif p == 5 then
			return Color3.new(1, 0.843137, 0)
		end
	end,
	GetSkillsOfJobType = function(p: string)
		local result = {}

		for k, v4 in v do
			if v4.Job == p then
				result[k] = v4
			end
		end

		return result
	end
}
return v3