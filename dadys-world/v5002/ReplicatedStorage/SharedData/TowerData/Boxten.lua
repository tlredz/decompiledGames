return {
	Cost = 250,
	Requirement1 = { "Coin", 250 },
	MasterySkin = "VintageBoxten",
	Name = "Boxten",
	Icon = "rbxassetid://16987982359",
	VoteIcon = "rbxassetid://16987982180",
	Render = "rbxassetid://103382765559521",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
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
	Ability1Name = "Wind-Up",
	Ability1Type = "Passive",
	Ability1Description = "This Toon gains 6% more Extraction Speed for every alive Toon in the round. Maxes at 48%.",
	MasteryRequirements = {
		{
			Name = "TravelDistance",
			Requirement = 50000
		},
		{
			Name = "PickUpItem",
			Requirement = 30
		},
		{
			Name = "SurviveFloor",
			Requirement = 25
		},
		{
			Name = "UseItem",
			Requirement = 30
		},
		{
			Name = "CompleteGenerator",
			Requirement = 50
		},
		{
			Name = "SurviveFloorWithParty",
			Requirement = 1,
			Number = 8
		}
	},
	RightHandBone = "R_hand",
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
	end,
	PlayFunctions = {}
}