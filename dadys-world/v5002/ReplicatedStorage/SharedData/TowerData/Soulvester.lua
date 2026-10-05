local function setFaceTexture(instance, texture)
	instance:WaitForChild("Config")
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local v = {}

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			table.insert(v, objectValue.Value)

			if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
				table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
			end
		end
	else
		local head = instance:FindFirstChild("Head")

		if not head then
			warn("No Head found in character and no BlinkingParts folder.")
			return
		end

		table.insert(v, head)

		if head:FindFirstChild("Head") then
			table.insert(v, head.Head)
		end
	end

	for _, part in ipairs(v) do
		if part:IsA("BasePart") then
			part.TextureID = texture
		end
	end
end

local Soulvester = {
	Name = "Soulvester",
	Icon = "rbxassetid://77290390868770",
	VoteIcon = "rbxassetid://75364947263421",
	Render = "rbxassetid://89403622984033",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 10,
	RunSpeed = 20,
	DecodeSpeed = 1.5,
	SkillCheckChance = 25,
	SkillCheckValue = 3,
	Stealth = 10,
	Stamina = 100,
	BoundarySize = 250,
	DecodeRank = 5,
	SpeedRank = 1,
	StaminaRank = 1,
	StealthRank = 3,
	SkillCheckRank = 5,
	LightToon = true,
	IchorLeakImmune = true,
	Ability1Name = "Soul Shield",
	Ability1Type = "Active",
	Ability1Description = "This Toon spends a heart to guard an ally, teleporting to block the next damage they would take and stunning the attacking Twisted for 1.5s. This Toon gains 1-Star Speed boost while guarding and 3-Star boost for 2s after defending.",
	ActiveAbility = true,
	PlayerAbility = true,
	PlayerRadius = 60,
	AbilityIcon = "rbxassetid://72170203663441",
	AbilityCooldown = 45,
	ClearTargetDuringCooldown = true,
	CustomAbilitySound = {
		SoundId = "rbxassetid://104775450784771",
		Volume = 1,
		Exclusive = true
	},
	TargetVisual = {
		text = "GUARD",
		image = "rbxassetid://121908174722814"
	},
	HolidayTower = true,
	Halloween = true,
	Cost = 700,
	Requirement1 = { "Pumpkins", 700 },
	Requirement2 = { "Research", 50, "SoulvesterMonster" },
	MasterySkin = "VintageSoulvester",
	MasteryRequirements = {
		{
			Name = "SurviveFloor",
			Requirement = 50
		},
		{
			Name = "UseItem",
			Requirement = 50
		},
		{
			Name = "TravelDistance",
			Requirement = 50000
		},
		{
			Name = "CompleteGenerator",
			Requirement = 100
		},
		{
			Name = "SurviveFloorWithToon",
			Requirement = 10,
			Tower = "Connie"
		},
		{
			Name = "BlackOut",
			Requirement = 5
		}
	},
	RightHandBone = "R_hand",
	LatchedBoneOffset = CFrame.new(0, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0),
	HurtAnimation = function(instance)
		local config = instance:FindFirstChild("Config")
		local hurtTexture = config and config:FindFirstChild("HurtTexture")
		local normalTexture = config and config:FindFirstChild("NormalTexture")

		if hurtTexture and normalTexture then
			setFaceTexture(instance, hurtTexture.Texture)
			task.wait(2)
			setFaceTexture(instance, normalTexture.Texture)
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function guardModule()
	local ServerStorage = game:GetService("ServerStorage")
	local serverItemModules = ServerStorage:FindFirstChild("ServerItemModules")
	return serverItemModules and serverItemModules:FindFirstChild("SoulvesterGuard") or nil
end

function Soulvester.SpecialSetup(instance)
	instance:SetAttribute("IchorPuddleImmune", true)
	local v = guardModule() -- equivalent call inferred; original call site unknown

	if not v then
		return
	end

	local success, result = pcall(function()
		local module = require(v)
		module.setupCharacter(instance)
	end)

	if not success then
		warn("Soulvester: guard setup failed:", result)
	end
end

function Soulvester.UseActiveAbility(p, p2, p3, p4)
	local v = guardModule() -- equivalent call inferred; original call site unknown

	if not v then
		return {
			Outcome = false,
			Reason = "You can't use your Ability right now!"
		}
	end

	local success, result = pcall(function()
		local module = require(v)
		return module.cast(p, p2, p3, p4)
	end)

	if success then
		return result
	end

	warn("Soulvester: guard cast failed:", result)
	return {
		Outcome = false,
		Reason = "You can't use your Ability right now!"
	}
end

Soulvester.PlayFunctions = {}
return Soulvester