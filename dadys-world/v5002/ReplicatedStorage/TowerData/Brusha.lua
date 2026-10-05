local Brusha = {
	Name = "Brusha",
	Icon = "rbxassetid://81392832907739",
	VoteIcon = "rbxassetid://79585152543624",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 2.5,
	Stealth = 5,
	Stamina = 150,
	BoundarySize = 200,
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 2,
	SkillCheckRank = 4,
	Ability1Name = "Artistic Inspiration",
	Ability1Type = "Active",
	Ability1Description = "This Toon can paint her artwork on nearby machines, inspiring extracting Toons with 25% faster Extraction Speed and a 15% higher Skill Check chance. Has a cooldown of 15.",
	Cost = 1250,
	Requirement1 = { "Coin", 1250 },
	Requirement2 = { "Research", 25, "BrushaMonster" },
	MasterySkin = "VintageBrusha",
	MasteryRequirements = {
		{
			Name = "SurviveFloor",
			Requirement = 25
		},
		{
			Name = "ActiveAbilityActivate",
			Requirement = 100
		},
		{
			Name = "CompleteGenerator",
			Requirement = 65
		},
		{
			Name = "TravelDistance",
			Requirement = 40000
		},
		{
			Name = "BuyDandyStoreItem",
			Requirement = 20
		},
		{
			Name = "SurviveFloorWithToon",
			Requirement = 5,
			Tower = "Tisha"
		}
	},
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://100313081858390",
	AbilityCooldown = 15,
	CustomAbilitySound = "rbxassetid://9117188688",
	ClientOnlySound = true,
	PassiveAbility = false,
	PaintAnimationId = "rbxassetid://115333524911186",
	PaintStartAnimationId = "rbxassetid://97174260659481",
	PaintEndAnimationId = "rbxassetid://129092207051880",
	PaintInfo = {
		Colors = {
			Color3.fromRGB(55, 9, 63),
			Color3.fromRGB(88, 21, 98),
			Color3.fromRGB(108, 36, 83),
			Color3.fromRGB(146, 75, 119),
			Color3.fromRGB(156, 54, 120)
		},
		Sequence = {
			{
				Image = "rbxassetid://130192982471686",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://83170807528315",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://140724415401724",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://135449854565794",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://102098391714612",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://81024192267618",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://96872825061929",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://1207650546102350",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://97082368527502",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	OnLoad = function(instance)
		instance:SetAttribute("PaintingTexture", "rbxassetid://87702688922899")
	end
}
local v = nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getBrushaAbility()
	if v then
		return v
	end

	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local gameplay = modules and modules:FindFirstChild("Gameplay")
	local brushaAbility = gameplay and gameplay:FindFirstChild("BrushaAbility")

	if not brushaAbility then
		warn("Brusha: BrushaAbility module not found — ability unavailable")
		return nil
	end

	local success, result = pcall(require, brushaAbility)

	if success then
		v = result
		return v
	end

	warn("Brusha: BrushaAbility failed to load:", result)
	return nil
end

function Brusha.UseActiveAbility(p, instance, _)
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if instance:WaitForChild("Decoding").Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	if not workspace:WaitForChild("Info"):WaitForChild("FloorActive").Value or instance:WaitForChild("Stats"):WaitForChild("InElevator").Value then
		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	end

	local brushaAbility = getBrushaAbility()

	if not brushaAbility then
		return {
			Outcome = false,
			Reason = "You can't use that Ability right now!"
		}
	end

	local nearestMachine, _, v2 = brushaAbility.FindNearestMachine(instance)

	if not nearestMachine then
		return {
			Outcome = false,
			Reason = v2 and "This machine is already buffed!" or "Get closer to a Machine to use that Ability!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		while instance and instance.Parent and currentCooldown.Value > 0 do
			task.wait(0.1)
			currentCooldown.Value = math.max(0, currentCooldown.Value - 0.1)
		end
	end)
	brushaAbility.Activate(p, instance, nearestMachine)
	return {
		Outcome = true,
		Reason = "Painting the Machine..."
	}
end

function Brusha.UpdatePassive(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if child.Name == "RingRanger" or child.Name == "RingRangerParent" then
			child:Destroy()
		end
	end

	local quickLinks = instance:FindFirstChild("QuickLinks")

	if not quickLinks then
		return
	end

	local ringRangerModel = quickLinks:FindFirstChild("RingRangerModel")

	if ringRangerModel then
		local value = ringRangerModel.Value

		if value then
			value:Destroy()
		end

		ringRangerModel.Value = nil
	end

	local notebookDecal = quickLinks:FindFirstChild("NotebookDecal") or quickLinks:FindFirstChild("NotebookArtImage")
	local value = notebookDecal and notebookDecal.Value

	if value and value:IsA("Decal") then
		value.Transparency = 1
	end
end

function Brusha.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local v2 = {}

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local value = objectValue.Value

			if not value then
				continue
			end

			table.insert(v2, value)

			if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
				table.insert(v2, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
			end

			for _, part in ipairs(v2) do
				if part:IsA("BasePart") then
					part.TextureID = config.HurtTexture.Texture
				end
			end
		end
	else
		local v3 = { instance:FindFirstChild("Head"), instance:FindFirstChild("UpperTorso") }

		for _, v4 in ipairs(v3) do
			if not v4 then
				continue
			end

			table.insert(v2, v4)
			v4.TextureID = config.HurtTexture.Texture

			if not v4:FindFirstChild("Head") then
				continue
			end

			table.insert(v2, v4.Head)
			v4.Head.TextureID = config.HurtTexture.Texture
		end
	end

	task.wait(2)

	if instance.Parent ~= nil then
		for _, v3 in ipairs(v2) do
			if v3 and v3.Parent then
				v3.TextureID = config.NormalTexture.Texture
			end
		end
	end
end

return Brusha