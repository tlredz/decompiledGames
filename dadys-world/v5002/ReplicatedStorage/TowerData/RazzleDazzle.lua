return {
	Name = "Razzle & Dazzle",
	Icon = "rbxassetid://17450142263",
	VoteIcon = "rbxassetid://17450142402",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 10,
	RunSpeed = 20,
	DecodeSpeed = 1.5,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 10,
	Stamina = 150,
	BoundarySize = 150,
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 3,
	SkillCheckRank = 3,
	Ability1Name = "Comedy/Tragedy",
	Ability1Type = "Passive",
	Ability1Description = "This Toon switches between Movement Speed on odd numbered Floors, and Extraction Speed on even numbered Floors.",
	Cost = 1250,
	Requirement1 = { "Coin", 1250 },
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		local blinkingParts = instance:FindFirstChild("BlinkingParts")
		local v = {}

		if blinkingParts and #blinkingParts:GetChildren() > 0 then
			for _, objectValue in ipairs(blinkingParts:GetChildren()) do
				if not objectValue:IsA("ObjectValue") then
					continue
				end

				local value = objectValue.Value

				if not value then
					continue
				end

				table.insert(v, value)

				if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
					table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
				end

				for _, part in ipairs(v) do
					if part:IsA("BasePart") then
						part.TextureID = config.HurtTexture.Texture
					end
				end
			end
		else
			local v2 = {
				instance:FindFirstChild("UpperTorso"),
				instance:FindFirstChild("EyeL"),
				instance:FindFirstChild("EyeR")
			}

			for _, v3 in ipairs(v2) do
				if not v3 then
					continue
				end

				table.insert(v, v3)
				v3.TextureID = config.HurtTexture.Texture
			end
		end

		task.wait(2)

		if instance.Parent ~= nil then
			for _, v2 in ipairs(v) do
				v2.TextureID = config.NormalTexture.Texture
			end
		end
	end
}