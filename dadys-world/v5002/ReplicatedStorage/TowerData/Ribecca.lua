local Ribecca = {}
Ribecca.Name = "Ribecca"
Ribecca.Icon = "rbxassetid://94294630559443"
Ribecca.VoteIcon = "rbxassetid://111735157461130"
Ribecca.Health = 3
Ribecca.MainCharacter = false
Ribecca.WalkSpeed = 15
Ribecca.RunSpeed = 25
Ribecca.DecodeSpeed = 1
Ribecca.SkillCheckChance = 25
Ribecca.SkillCheckValue = 2
Ribecca.Stealth = 10
Ribecca.Stamina = 150
Ribecca.BoundarySize = 150
Ribecca.BoundarySize2 = 125
Ribecca.DecodeRank = 3
Ribecca.SpeedRank = 3
Ribecca.StaminaRank = 3
Ribecca.StealthRank = 3
Ribecca.SkillCheckRank = 3
Ribecca.CompleteImmunity = true
Ribecca.Ability1Name = "The Undead"
Ribecca.Ability1Type = "Passive"
Ribecca.Ability1Description = "This Toon is immune to all applied debuffs (excluding trinkets). Whenever this Toon's immunity shines, she feels empowered and receives a random buff in its place for 10 seconds."
Ribecca.Cost = 250

function Ribecca.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local texture = config.HurtTexture.Texture
	local texture2 = config.NormalTexture.Texture
	local v = {}

	if blinkingParts then
		for _, objectValue in pairs(blinkingParts:GetChildren()) do
			if not (objectValue:IsA("ObjectValue") and objectValue.Value and objectValue.Value:IsA("BasePart")) then
				continue
			end

			local value = objectValue.Value
			local basePart = value:FindFirstChildWhichIsA("BasePart")
			v[#v + 1] = value

			if basePart then
				v[#v + 1] = basePart
			end
		end
	end

	if instance:FindFirstChild("Head") then
		v[#v + 1] = instance.Head
		local basePart = instance.Head:FindFirstChildWhichIsA("BasePart")

		if basePart then
			v[#v + 1] = basePart
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setHeadTexture(texture3)
		for _, v2 in pairs(v) do
			v2.TextureID = texture3
		end
	end

	setHeadTexture(texture) -- equivalent call inferred; original call site unknown
	task.delay(2, setHeadTexture, texture2)
end

function Ribecca.SpecialSetup(instance)
	instance:SetAttribute("DebuffImmune", true)
end

return Ribecca