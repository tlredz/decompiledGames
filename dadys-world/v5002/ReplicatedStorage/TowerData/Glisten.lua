local Glisten = {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1.5,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 5,
	Stamina = 150,
	BoundarySize = 100,
	Name = "Glisten",
	Icon = "rbxassetid://18787102103",
	VoteIcon = "rbxassetid://18787101859",
	DecodeRank = 5,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 2,
	SkillCheckRank = 2,
	Ability1Name = "Reflection",
	Ability1Type = "Active",
	Ability1Description = "This Toon can travel through a mirror, instantly teleporting to a targeted Toon regardless of line of sight. Has a cooldown of 100."
}
game:GetService("TweenService")
game:GetService("Debris")

function Glisten.HurtAnimation(instance)
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

Glisten.ActiveAbility = true
Glisten.PlayerAbility = true
Glisten.PlayerRadius = 80
Glisten.AbilityIcon = "rbxassetid://18839978493"
Glisten.AbilityCooldown = 100
Glisten.CustomAbilitySound = script.Sound
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebuffManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Gameplay"):WaitForChild("DebuffManager"))

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

function Glisten.UseActiveAbility(p, instance, p2, instance2)
	instance:WaitForChild("Config")
	local decoding = instance:WaitForChild("Decoding")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local humanoid = instance:WaitForChild("Humanoid")
	local removeCharacterAntiExploitModule = game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule")

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

	if decoding.Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
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

	removeCharacterAntiExploitModule:Fire(p, true)
	local primaryPart = instance2.PrimaryPart
	local primaryPart2 = instance.PrimaryPart
	local magnitude = (p2.Position - primaryPart.Position).Magnitude
	local v = {
		Outcome = true,
		Reason = instance2.Name
	}

	if Glisten.PlayerRadius < magnitude then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	CFrame.lookAt(p2.Position, primaryPart.Position)
	local v2 = humanoid.HipHeight + primaryPart2.Size.Y / 2
	local v3 = humanoid2.HipHeight + primaryPart.Size.Y / 2
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

		if instance and instance.Parent ~= nil then
			local v4 = { instance, primaryPart, primaryPart2.CFrame }
			local glistenPortal = ReplicatedStorage.Parts.RenderModules.GlistenPortal
			ReplicatedStorage.Events.RenderObject:FireAllClients(glistenPortal, v4)
		end
	end)
	instance.PrimaryPart:SetNetworkOwner(nil)
	instance:PivotTo(primaryPart.CFrame * CFrame.new(0, -v3 + v2, 0))
	instance.PrimaryPart:SetNetworkOwner(p)
	DebuffManager.ApplyConfusion(instance, 3, 10, {
		allowRefreshOnEqual = true,
		source = "Glisten"
	})
	task.spawn(function()
		task.wait(2)
		removeCharacterAntiExploitModule:Fire(p, false)
	end)
	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v5 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v5)
			end
		end
	end)
	return v
end

return Glisten