local Teagan = {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 5,
	Stamina = 175,
	BoundarySize = 150,
	Name = "Teagan",
	Icon = "rbxassetid://18183438182",
	VoteIcon = "rbxassetid://18183437933",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 4,
	StealthRank = 2,
	SkillCheckRank = 3,
	Ability1Name = "Tea Time",
	Ability1Type = "Active",
	Ability1Description = "This Toon can spend 75 Tapes to heal themself by 1 Heart. Has a Cooldown of 100."
}
game:GetService("Debris")
game:GetService("TweenService")
game:GetService("Players")
game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")

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

function Teagan.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	setFaceTexture(instance, config.HurtTexture.Texture)
	task.wait(2)

	if instance.Parent ~= nil then
		setFaceTexture(instance, config.NormalTexture.Texture)
	end
end

Teagan.ActiveAbility = true
Teagan.AbilityIcon = "rbxassetid://18185982499"
Teagan.AbilityCooldown = 100
Teagan.AbilityCost = 75
Teagan.CustomAbilitySound = script.Sound

function Teagan.ClientAbility(_, _) end

function Teagan.UseActiveAbility(_, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local humanoid = instance:WaitForChild("Humanoid")
	instance:WaitForChild("HumanoidRootPart")
	local survivalPoints = workspace.Info.PlayerStats:FindFirstChild(instance.Name):WaitForChild("SurvivalPoints")
	local abilityCost = ability1:WaitForChild("AbilityCost")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if workspace.Info.FloorActive.Value ~= true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if survivalPoints.Value < abilityCost.Value then
		return {
			Outcome = false,
			Reason = "You don't have enough Tapes!"
		}
	end

	if humanoid.Health >= humanoid.MaxHealth then
		return {
			Outcome = false,
			Reason = "Can't use that Ability at full Health!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

		if instance and instance.Parent ~= nil then
			local particles = instance:WaitForChild("Head"):WaitForChild("Particles")
			particles.ParticleEmitter:Emit(10)
			particles.ParticleEmitter2:Emit(10)
		end
	end)
	local child = instance and workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints2 = child:WaitForChild("SurvivalPoints")

		if survivalPoints2.Value >= abilityCost.Value then
			survivalPoints2.Value -= abilityCost.Value

			if survivalPoints2.Value <= 0 then
				survivalPoints2.Value = 0
			end

			humanoid.Health += 1
		end
	end

	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v3 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v3)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Teagan