return {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 2.5,
	Stealth = 10,
	Stamina = 125,
	BoundarySize = 200,
	Name = "Finn",
	Icon = "rbxassetid://18715594549",
	VoteIcon = "rbxassetid://18715617403",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 2,
	StealthRank = 3,
	SkillCheckRank = 4,
	Ability1Name = "Reel In",
	Ability1Type = "Passive",
	Ability1Description = "This Toon gains a 35% Movement Speed boost when any Machine is completed for 10 seconds.",
	HurtAnimation = function(instance)
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
}