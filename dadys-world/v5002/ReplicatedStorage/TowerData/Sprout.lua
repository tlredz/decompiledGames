local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("Players")
game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")
local Sprout = {
	Health = 2,
	MainCharacter = true,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 10,
	Stamina = 200,
	BoundarySize = 100,
	Name = "Sprout",
	Icon = "rbxassetid://18551044543",
	VoteIcon = "rbxassetid://18551033828",
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 5,
	StealthRank = 3,
	SkillCheckRank = 2,
	Ability1Name = "Baked Sweets",
	Ability1Type = "Active",
	Ability1Description = "This Toon can heal a targeted Toon by 1 Heart at the cost of Tapes. Has a Cooldown of 100. Tape cost scales with the number of Healing Toons in the round.",
	Ability2Name = "Overprotective",
	Ability2Type = "Passive",
	Ability2Description = "This Toon can see where all other alive Toons are, along with their current Health status.",
	ActiveAbility = true,
	PlayerAbility = true,
	PlayerRadius = 60,
	AbilityIcon = "rbxassetid://18555366888",
	AbilityCooldown = 100,
	AbilityCost = 100,
	AbilityDuration = 15,
	HealCooldown = true,
	CustomAbilitySound = script.Sound,
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		local blinkingParts = instance:FindFirstChild("BlinkingParts")
		local v = {}

		if blinkingParts and #blinkingParts:GetChildren() > 0 then
			for _, objectValue in ipairs(blinkingParts:GetChildren()) do
				if not objectValue:IsA("ObjectValue") then
					continue
				end

				local value = objectValue.Value

				if not value then
					continue
				end

				table.insert(v, value)

				if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
					table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
				end

				for _, part in ipairs(v) do
					if part:IsA("BasePart") then
						part.TextureID = config.HurtTexture.Texture
					end
				end
			end
		else
			local v2 = {
				instance:FindFirstChild("UpperTorso"),
				instance:FindFirstChild("EyeL"),
				instance:FindFirstChild("EyeR")
			}

			for _, v3 in ipairs(v2) do
				if not v3 then
					continue
				end

				table.insert(v, v3)
				v3.TextureID = config.HurtTexture.Texture
			end
		end

		task.wait(2)

		if instance.Parent ~= nil then
			for _, v2 in ipairs(v) do
				v2.TextureID = config.NormalTexture.Texture
			end
		end
	end,
	ClientAbility = function(_, instance)
		local inGamePlayers = workspace.InGamePlayers

		if inGamePlayers then
			local children = inGamePlayers:GetChildren()
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

			for _, v in pairs(children) do
				if not (v:GetChildren()[1] and v ~= instance) then
					continue
				end

				local v2 = v

				local function CreatePopUp()
					local humanoid = v2:FindFirstChild("Humanoid")

					if not humanoid then
						return
					end

					local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
					local humanoidRootPart2 = v2:FindFirstChild("HumanoidRootPart")

					if not (humanoidRootPart and humanoidRootPart2) then
						return
					end

					local clone = script.HeartIcon:Clone()
					local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
					clone.Size = UDim2.new(math.clamp(magnitude / 10, 2, 15), 0, math.clamp(magnitude / 10, 2, 15), 0)
					local maxHealth = humanoid.MaxHealth
					local health = humanoid.Health
					Color3.fromRGB(255, 0, 4)
					Color3.fromRGB(255, 126, 128)
					Color3.fromRGB(255, 255, 255)
					local heart3 = clone.Frame.Heart3
					local heart2 = clone.Frame.Heart2
					local heart1 = clone.Frame.Heart1

					if humanoid.MaxHealth == 2 then
						heart3 = humanoid.Health == 1 and heart1 or heart3
					elseif humanoid.MaxHealth >= 3 then
						if humanoid.Health == 1 and heart1 then
							heart3 = heart1
						elseif humanoid.Health < humanoid.MaxHealth then
							heart3 = heart2 or heart3
						end
					end

					heart3.Visible = true
					clone.Parent = humanoidRootPart2
					TweenService:Create(heart3, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(clone, 1.5)
				end

				CreatePopUp()
				task.wait()
			end
		end
	end
}
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

function Sprout.UseActiveAbility(_, instance, p, instance2)
	instance:WaitForChild("Config")
	instance:WaitForChild("Decoding")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local humanoid = instance:WaitForChild("Humanoid")
	local survivalPoints = workspace.Info.PlayerStats:FindFirstChild(instance.Name):WaitForChild("SurvivalPoints")
	local abilityCost = ability1:WaitForChild("AbilityCost")

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

	if workspace.Info.GameStats.HealCooldown.Value == true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability right now!"
		}
	end

	if survivalPoints.Value < abilityCost.Value then
		return {
			Outcome = false,
			Reason = "You don't have enough Tapes!"
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

	if humanoid2.Health >= humanoid2.MaxHealth then
		return {
			Outcome = false,
			Reason = "Can't use Ability on Toons with full Health!"
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
		local sproutCupcake = ReplicatedStorage.Parts.RenderModules.SproutCupcake
		ReplicatedStorage.Events.RenderObject:FireAllClients(sproutCupcake, { instance, instance2 })
	end

	local success, result = pcall(function()
		if instance2 and humanoid2 then
			humanoid2.Health += 1

			if humanoid2.Health >= humanoid2.MaxHealth then
				humanoid2.Health = humanoid2.MaxHealth
			end

			if survivalPoints.Value >= abilityCost.Value then
				survivalPoints.Value -= abilityCost.Value

				if survivalPoints.Value <= 0 then
					survivalPoints.Value = 0
				end
			end
		end
	end)

	if success then
		local function adjustcost()
			local children = workspace.InGamePlayers:GetChildren()
			local count = 0

			for _, v2 in pairs(children) do
				v2:WaitForChild("Config"):WaitForChild("ModuleName")
				local abilities = v2:WaitForChild("Abilities")

				if not (abilities:FindFirstChild("Ability1") and abilities:WaitForChild("Ability1"):FindFirstChild("HealCooldown")) then
					continue
				end

				count += 1
			end

			return (math.max(count, 1) - 1) * 10 + 15
		end

		local v2 = adjustcost()
		print(v2)

		if workspace.Info.GameStats.HealCooldown.Value ~= true then
			workspace.Info.GameStats.HealCooldown.Value = true
			task.delay(v2, function()
				workspace.Info.GameStats.HealCooldown.Value = false
			end)
		end
	else
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

return Sprout