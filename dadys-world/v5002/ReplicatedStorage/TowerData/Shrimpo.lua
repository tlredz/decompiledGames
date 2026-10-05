return {
	Name = "Shrimpo",
	Icon = "rbxassetid://17560978429",
	VoteIcon = "rbxassetid://17560978585",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 10,
	RunSpeed = 20,
	DecodeSpeed = 0.75,
	SkillCheckChance = 25,
	SkillCheckValue = 1,
	Stealth = -99,
	Stamina = 100,
	BoundarySize = 50,
	DecodeRank = 1,
	SpeedRank = 1,
	StaminaRank = 1,
	StealthRank = 1,
	SkillCheckRank = 1,
	Ability1Name = "Bully",
	Ability1Type = "Passive",
	Ability1Description = "Stealth is drastically lower than any other Toon. Only play this Toon if you are looking for a challenge.",
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		instance.Head.TextureID = config.HurtTexture.Texture

		if instance.Head:FindFirstChild("Head") then
			instance.Head.Head.TextureID = config.HurtTexture.Texture
		end

		task.wait(2)

		if instance.Parent ~= nil then
			instance.Head.TextureID = config.NormalTexture.Texture

			if instance.Head:FindFirstChild("Head") then
				instance.Head.Head.TextureID = config.NormalTexture.Texture
			end
		end
	end
}