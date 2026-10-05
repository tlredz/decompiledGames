local Rodger = {
	Name = "Rodger",
	Icon = "rbxassetid://17095240566",
	VoteIcon = "rbxassetid://17552098075",
	Render = "rbxassetid://89777920295115",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 12.5,
	RunSpeed = 22.5,
	DecodeSpeed = 1.2,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 10,
	Stamina = 150,
	BoundarySize = 150,
	DecodeRank = 4,
	SpeedRank = 2,
	StaminaRank = 3,
	StealthRank = 3,
	SkillCheckRank = 3,
	Ability1Name = "Detective",
	Ability1Type = "Passive",
	Ability1Description = "This Toon gains twice the amount of Research from Capsules and encountering Twisteds.",
	MasterySkin = "VintageRodger",
	Cost = 1000
}
Rodger.Requirement1 = { "Coin", Rodger.Cost }
Rodger.Requirement2 = { "Research", 50, "Any" }
Rodger.MasteryRequirements = {
	{
		Name = "CollectResearch",
		Requirement = 1000
	},
	{
		Name = "TravelDistance",
		Requirement = 75000
	},
	{
		Name = "PickUpCapsule",
		Requirement = 125
	},
	{
		Name = "EncounterMonster",
		Requirement = 100
	},
	{
		Name = "PickUpItem",
		Requirement = 60
	},
	{
		Name = "UseItem",
		Requirement = 60
	}
}
Rodger.RightHandBone = "forearm_stretch.r"
Rodger.LatchedBoneOffset = CFrame.new(0, -0.1, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)

function Rodger.HurtAnimation(instance)
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

	local function setHeadTexture(texture3)
		for _, part in pairs(v) do
			if part:FindFirstChild("Decal") then
				part.Decal.Texture = texture3
			elseif part:IsA("MeshPart") then
				part.TextureID = texture3
			end
		end
	end

	setHeadTexture(texture)
	task.delay(2, setHeadTexture, texture2)
end

function Rodger.SpecialSetup(_) end

Rodger.PlayFunctions = {}
return Rodger