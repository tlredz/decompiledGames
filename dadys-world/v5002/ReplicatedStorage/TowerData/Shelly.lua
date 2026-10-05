local Shelly = {
	Health = 2,
	MainCharacter = true,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 3,
	Stealth = 10,
	Stamina = 125,
	BoundarySize = 250,
	Name = "Shelly",
	Icon = "rbxassetid://18199050281",
	VoteIcon = "rbxassetid://18199050044",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 2,
	StealthRank = 3,
	SkillCheckRank = 5,
	Ability1Name = "Inspiration",
	Ability1Type = "Active",
	Ability1Description = "This Toon can boost the Extraction Speed of a selected Toon by 75% for 15 seconds. Has a Cooldown of 60.",
	Ability2Name = "Problem Solver",
	Ability2Type = "Passive",
	Ability2Description = "This Toon gains a 25% Movement Speed boost when any Machine is completed for 10 seconds."
}
local Debris = game:GetService("Debris")
game:GetService("TweenService")
game:GetService("Players")
game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")
Shelly.ActiveAbility = true
Shelly.PlayerAbility = true
Shelly.PlayerRadius = 60
Shelly.AbilityIcon = "rbxassetid://18209649932"
Shelly.AbilityCooldown = 60
Shelly.AbilityDuration = 15
Shelly.CustomAbilitySound = script.Sound

function Shelly.HurtAnimation(instance)
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function canseetarget(folder, ancestor, p, p2, p3)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local folders = {}
	local filterDescendantsInstances = {}
	local position = p.Position
	local v2 = (p2.Position - p.Position).Unit * p3
	local raycastParams = RaycastParams.new()

	if model then
		model:WaitForChild("Monsters")

		for _, folder2 in pairs(model.Monsters:GetChildren()) do
			if table.find(folders, folder2) then
				continue
			end

			for _, part in pairs(folder2:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(filterDescendantsInstances, part)
				end
			end

			table.insert(folders, folder2)
		end
	end

	for _, folder2 in pairs(workspace.Elevators:GetChildren()) do
		if table.find(folders, folder2) then
			continue
		end

		for _, part in pairs(folder2:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(filterDescendantsInstances, part)
			end
		end

		table.insert(folders, folder2)
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(filterDescendantsInstances, part)
		end
	end

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		if child ~= ancestor then
			table.insert(filterDescendantsInstances, child)
		end
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = game.Workspace:Raycast(position, v2, raycastParams)

	if raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(ancestor) then
		return true
	end

	return false
end

function Shelly.UseActiveAbility(_, instance, p, instance2)
	instance:WaitForChild("Config")
	instance:WaitForChild("Decoding")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local humanoid = instance:WaitForChild("Humanoid")

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

	if not instance2 or instance2.Parent == nil then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	local humanoid2 = instance2:WaitForChild("Humanoid")

	if humanoid.Health <= 0 or humanoid2.Health <= 0 then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	local primaryPart = instance2.PrimaryPart
	local _ = instance.PrimaryPart
	local _ = (p.Position - primaryPart.Position).Magnitude
	local v = {
		Outcome = true,
		Reason = instance2.Name
	}
	currentCooldown.Value = cooldown.Value
	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

	if instance and instance.Parent ~= nil then
		local shellyEffect = ReplicatedStorage.Parts.RenderModules.ShellyEffect
		ReplicatedStorage.Events.RenderObject:FireAllClients(shellyEffect, { instance })
	end

	local success, result = pcall(function()
		if instance2 then
			local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
			local humanoidRootPart = instance2:WaitForChild("HumanoidRootPart")
			local v2 = StatModifierManager.ApplyModifier(instance2, "DecodeSpeedModifier", 1.75, "ShellyInspiration", {
				category = "ability"
			})
			task.delay(Shelly.AbilityDuration, function()
				if v2 then
					StatModifierManager.RemoveModifier(instance2, "DecodeSpeedModifier", v2)
				end
			end)
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = game.ReplicatedStorage.Parts.BuffParticles.DecodeSpeed.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = game.ReplicatedStorage.Parts.BuffParticles.DecodeSpeed.Glow:Clone()
			clone2.Parent = attachment
			clone2.Enabled = true
			Debris:AddItem(clone, Shelly.AbilityDuration + 1)
			Debris:AddItem(clone2, Shelly.AbilityDuration + 1)
			Debris:AddItem(attachment, Shelly.AbilityDuration + 1)
			task.delay(Shelly.AbilityDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
					clone2.Enabled = false
				end
			end)
		end
	end)

	if not success then
		warn(result)
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
	return v
end

return Shelly