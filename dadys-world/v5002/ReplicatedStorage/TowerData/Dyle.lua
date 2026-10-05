return {
	Name = "Dyle",
	Cost = 999999999999999,
	Icon = "rbxassetid://84437337491548",
	VoteIcon = "rbxassetid://136930469700070",
	DevTower = true,
	Lethal = true,
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 20,
	RunSpeed = 30,
	DecodeSpeed = 1.5,
	SkillCheckChance = 15,
	Stealth = 20,
	Stamina = 200,
	BoundarySize = 120,
	BoundarySize2 = 200,
	SkillCheckValue = 3,
	DecodeRank = 5,
	SpeedRank = 5,
	StaminaRank = 5,
	StealthRank = 5,
	SkillCheckRank = 5,
	Ability1Name = "Dyle's World",
	Ability1Type = "Passive",
	Ability1Description = "The star of the show.",
	Requirement1 = { "Coin", 999999999999999 },
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