local Waxwell = {
	Name = "Waxwell",
	VoteIcon = "rbxassetid://89032041952425",
	VoteIconSize = UDim2.fromScale(1.5, 1.5),
	Icon = "rbxassetid://109938376189951",
	Render = "rbxassetid://70589553078234",
	GeneratorOffset = {
		Y = -0.07,
		Z = 0.14
	},
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 20,
	RunSpeed = 30,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 3,
	Stealth = 5,
	Stamina = 100,
	BoundarySize = 250,
	DecodeRank = 2,
	SpeedRank = 5,
	StaminaRank = 1,
	StealthRank = 2,
	SkillCheckRank = 5,
	Ability1Name = "Ignite",
	Ability1Type = "Active",
	Ability1Description = "This Toon ignites, removing his Tired debuff and creating a flame trail for 10 seconds. Touching the trail grants Toons the Ignited buff, causing ability cooldowns to recover 2x as fast for 5 seconds. Has a cooldown of 60.",
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://95655923611922",
	AbilityCooldown = 60,
	AbilityDuration = 10,
	CustomAbilitySound = {
		Path = "Sounds.Toon.Waxwell.Ability"
	},
	RightHandBone = "R_hand_jnt",
	Cost = 3500
}
Waxwell.Requirement1 = { "Coin", Waxwell.Cost }
Waxwell.Requirement2 = { "Research", 50, "WaxwellMonster" }
Waxwell.Requirement3 = { "Mastery", 50, "Goob" }
Waxwell.MasteryRequirements = {
	{
		Name = "ActiveAbilityActivate",
		Requirement = 80
	},
	{
		Name = "BlackOut",
		Requirement = 8
	},
	{
		Name = "SurviveFloorWithTrinket",
		Requirement = 1,
		Number = 10,
		Trinket = "CherishedBlanket",
		DisplayText = "Complete Floor 10 with the Cherished Blanket equipped!"
	},
	{
		Name = "TravelDistance",
		Requirement = 111000
	},
	{
		Name = "CompleteDuoGenerator",
		Requirement = 60,
		DisplayText = "Complete %d Duo Machines with another Player!"
	},
	{
		Name = "UseItemSpecific",
		Requirement = 30,
		Item = "Instructions",
		DisplayText = "Use %d Instructions!"
	}
}
Waxwell.MasterySkin = "VintageWaxwell"
Waxwell.RightHandBone = "R_hand_jnt"

function Waxwell.HurtAnimation(instance)
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

local v = { "VFXAttachment", "LightAttachment" }

local function isHeadFxAttachment(attachment)
	if not attachment:IsA("Attachment") then
		return false
	end

	for _, v2 in ipairs(v) do
		if string.sub(attachment.Name, 1, #v2) == v2 then
			return true
		end
	end

	return false
end

function Waxwell.OnLoad(instance)
	task.spawn(function()
		local rootPart = instance and instance:FindFirstChild("RootPart")
		local root_jnt = rootPart and rootPart:FindFirstChild("root_jnt")
		local torso_jnt = root_jnt and root_jnt:FindFirstChild("torso_jnt")
		local chest_jnt = torso_jnt and torso_jnt:FindFirstChild("chest_jnt")
		local head_jnt = chest_jnt and chest_jnt:FindFirstChild("head_jnt")

		if not head_jnt then
			return
		end

		for _, child in ipairs(head_jnt:GetChildren()) do
			if not isHeadFxAttachment(child) then
				continue
			end

			for _, child2 in ipairs(child:GetChildren()) do
				if child2:IsA("ParticleEmitter") or child2:IsA("Light") then
					child2.Enabled = false
				end
			end
		end
	end)
end

function Waxwell.SpecialSetup(p)
	local ServerStorage = game:GetService("ServerStorage")
	local serverItemModules = ServerStorage:FindFirstChild("ServerItemModules")
	local waxwellVariants = serverItemModules and serverItemModules:FindFirstChild("WaxwellVariants")

	if not waxwellVariants then
		return
	end

	local success, result = pcall(function()
		local module = require(waxwellVariants)
		module.setupCharacter(p)
	end)

	if not success then
		warn("Waxwell: variant setup failed:", result)
	end
end

function Waxwell.UseActiveAbility(_, instance, _, _)
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if not (workspace.CurrentRoom:FindFirstChildOfClass("Model") and workspace.Info.FloorActive.Value == true) then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	local success, result = pcall(function()
		local ServerStorage = game:GetService("ServerStorage")
		require(ServerStorage.ServerItemModules.EmberTrail).AsRequested(instance)
	end)

	if not success then
		warn("Waxwell: Ember Trail cast failed:", result)
		return {
			Outcome = false,
			Reason = "Couldn't light the trail!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		local lastTime = os.clock()

		while instance and instance.Parent do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v3 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait((math.max(0.01, v3)))
			end
		end
	end)
	return {
		Outcome = true
	}
end

Waxwell.PlayFunctions = {}
return Waxwell