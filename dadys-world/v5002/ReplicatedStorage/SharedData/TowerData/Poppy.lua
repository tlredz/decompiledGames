return {
	Name = "Poppy",
	Cost = 250,
	Requirement1 = { "Coin", 250 },
	MasterySkin = "VintagePoppy",
	Icon = "rbxassetid://16882258451",
	VoteIcon = "rbxassetid://16846452024",
	Render = "rbxassetid://79076191140865",
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
	Ability1Name = "Panic Pop",
	Ability1Type = "Passive",
	Ability1Description = "This Toon receives a 50% Speed boost for 3 seconds when attacked.",
	MasteryRequirements = {
		{
			Name = "PassiveAbilityActivate",
			Requirement = 30
		},
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
			Requirement = 30
		}
	},
	RightHandBone = "handBone_R",
	LatchedBoneOffset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 1.9198621771937625, 0),
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