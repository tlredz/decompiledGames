local Finn = {}
Finn.Health = 3
Finn.MainCharacter = false
Finn.WalkSpeed = 15
Finn.RunSpeed = 25
Finn.DecodeSpeed = 1
Finn.SkillCheckChance = 25
Finn.SkillCheckValue = 2.5
Finn.Stealth = 10
Finn.Stamina = 125
Finn.BoundarySize = 200
Finn.Name = "Finn"
Finn.Icon = "rbxassetid://118315386021284"
Finn.VoteIcon = "rbxassetid://18715617403"
Finn.Render = "rbxassetid://134145409873107"
Finn.DecodeRank = 3
Finn.SpeedRank = 3
Finn.StaminaRank = 2
Finn.StealthRank = 3
Finn.SkillCheckRank = 4
Finn.Ability1Name = "Reel In"
Finn.Ability1Type = "Passive"
Finn.Ability1Description = "This Toon gains a 35% Movement Speed boost when any Machine is completed for 10 seconds."
Finn.Cost = 500
Finn.Requirement1 = { "Coin", 500 }
Finn.Requirement2 = { "CompleteGenerator", 15 }
Finn.MasterySkin = "VintageFinn"
Finn.MasteryRequirements = {
	{
		Name = "BuyDandyStoreItem",
		Requirement = 5
	},
	{
		Name = "TravelDistance",
		Requirement = 55000
	},
	{
		Name = "PickUpItem",
		Requirement = 30
	},
	{
		Name = "SurviveFloor",
		Requirement = 30
	},
	{
		Name = "UseItem",
		Requirement = 30
	},
	{
		Name = "CompleteGenerator",
		Requirement = 45
	}
}
Finn.RightHandBone = "Fingers.R"
Finn.LatchedBoneOffset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0)

function Finn.OnLoad(instance)
	task.spawn(function()
		local humanoid = instance:WaitForChild("Humanoid")
		local particleEmitter = instance:WaitForChild("Head"):WaitForChild("Particle"):WaitForChild("ParticleEmitter")
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			local v = humanoid.MoveDirection.Magnitude >= 0.5
			local anchored = humanoidRootPart.Anchored == true
			particleEmitter.Enabled = v and not anchored
		end)
	end)
end

function Finn.HurtAnimation(instance)
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

Finn.PlayFunctions = {}
return Finn