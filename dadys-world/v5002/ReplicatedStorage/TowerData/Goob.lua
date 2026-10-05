local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Goob = {
	Name = "Goob",
	Icon = "rbxassetid://17231084415",
	VoteIcon = "rbxassetid://17231084745",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 5,
	Stamina = 175,
	BoundarySize = 150,
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 4,
	StealthRank = 2,
	SkillCheckRank = 3,
	Ability1Name = "Hug!",
	Ability1Type = "Active",
	Ability1Description = "This Toon can pull other Toons towards his position. Needs direct line of sight. 30 Second Cooldown.",
	Cost = 1,
	Requirement1 = { "Coin", 1 },
	ActiveAbility = true,
	PlayerAbility = true,
	PlayerRadius = 75,
	AbilityIcon = "rbxassetid://17701467369",
	AbilityCooldown = 30,
	CustomAbilitySound = script.Sound
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function canseetarget(folder, ancestor, p, primaryPart, magnitude)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local folders = {}
	local filterDescendantsInstances = {}
	local position = p.Position
	local v2 = (primaryPart.Position - p.Position).Unit * magnitude
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

local function isValidPosition(p)
	local region = Region3.new(p - createVector(1, 1.5, 1), p + createVector(1, 1.5, 1))
	return workspace:IsRegion3Empty(region)
end

function Goob.UseActiveAbility(player, instance, p, instance2)
	instance:WaitForChild("Config")
	local decoding = instance:WaitForChild("Decoding")
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

	if instance2:WaitForChild("Stats"):WaitForChild("InElevator").Value == true then
		return {
			Outcome = false,
			Reason = "You can't target Toons in the Elevator!"
		}
	end

	if humanoid.Health <= 0 or humanoid2.Health <= 0 then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	local function checkPlayerInElevator(instance3, elevatorHitBox)
		local partsInPart = workspace:GetPartsInPart(elevatorHitBox)

		for _, v in ipairs(partsInPart) do
			if v.Name == "HumanoidRootPart" and v.Parent:FindFirstChild("Humanoid") and v.Parent == instance3 then
				return true
			end
		end

		return false
	end

	if checkPlayerInElevator(
		instance2,
		workspace:WaitForChild("Elevators"):WaitForChild("Elevator"):WaitForChild("ElevatorHitBox")
	) then
		return {
			Outcome = false,
			Reason = "You can't use that Ability on someone in the Elevator!"
		}
	end

	local decoding2 = instance2:WaitForChild("Decoding")

	if decoding2.Value ~= nil then
		return {
			Outcome = false,
			Reason = "You can't target extracting Toons!"
		}
	end

	local grabbing = instance2:FindFirstChild("Grabbing")

	if grabbing and grabbing.Value == true then
		return {
			Outcome = false,
			Reason = "You can't target Toons who are grabbing!"
		}
	end

	local primaryPart = instance2.PrimaryPart
	local primaryPart2 = instance.PrimaryPart

	if not canseetarget(instance, instance2, p, primaryPart, (p.Position - primaryPart.Position).Magnitude) then
		return {
			Outcome = false,
			Reason = "You need line of sight with that Toon!"
		}
	end

	if decoding2 and decoding2.Value ~= nil then
		return {
			Outcome = false,
			Reason = "You can't target extracting Toons!"
		}
	end

	local v = {
		Outcome = true,
		Reason = instance2.Name
	}
	currentCooldown.Value = cooldown.Value
	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Pull")
	local tweenInfo = TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local removeCharacterAntiExploitModule = game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule")
	removeCharacterAntiExploitModule:Fire(instance2, true)
	removeCharacterAntiExploitModule:Fire(player, true)
	local _, v2, _ = CFrame.lookAt(p.Position, primaryPart.Position):ToOrientation()
	local X = p.Position.X
	local Y = p.Position.Y
	local Z = p.Position.Z
	local cFrame = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)
	TweenService:Create(instance.PrimaryPart, tweenInfo, {
		CFrame = cFrame
	}):Play()
	task.spawn(function()
		primaryPart2.Anchored = true
		task.delay(0.75, function()
			if primaryPart2 and primaryPart2.Parent ~= nil then
				primaryPart2.Anchored = false
			end
		end)

		if decoding2.Value == nil then
			primaryPart.Anchored = false
		end

		local _ = primaryPart.CFrame
		task.spawn(function()
			if instance and instance.Parent ~= nil then
				instance.Grabbing.Value = true
				task.delay(0.75, function()
					instance.Grabbing.Value = false
				end)
				local goobToonGrab = ReplicatedStorage.Parts.RenderModules.GoobToonGrab
				ReplicatedStorage.Events.RenderObject:FireAllClients(goobToonGrab, { instance, instance2 })
			end
		end)
		task.wait(0.25)

		if not canseetarget(instance, instance2, p, primaryPart, (p.Position - primaryPart.Position).Magnitude) then
			return {
				Outcome = false,
				Reason = "Line of sight with that Toon was lost!"
			}
		end

		if decoding2 and decoding2.Value ~= nil then
			return {
				Outcome = false,
				Reason = "You can't target extracting Toons!"
			}
		end

		if not primaryPart2 or primaryPart2.Parent == nil then
			return
		end

		primaryPart2.Anchored = true

		if not primaryPart or primaryPart.Parent == nil then
			return
		end

		if decoding2.Value == nil then
			primaryPart.Anchored = false
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Invincible"
		boolValue.Parent = primaryPart.Parent
		boolValue.Value = true
		Debris:AddItem(boolValue, 0.5)
		local boolValue2 = Instance.new("BoolValue")
		boolValue2.Name = "Grabbed"
		boolValue2.Parent = primaryPart.Parent
		boolValue2.Value = true
		Debris:AddItem(boolValue2, 0.6)
		local boolValue3 = Instance.new("BoolValue")
		boolValue3.Name = "NoDecode"
		boolValue3.Parent = primaryPart2.Parent
		boolValue3.Value = true
		Debris:AddItem(boolValue3, 1)
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		if primaryPart and primaryPart.Parent ~= nil and game.Players:GetPlayerFromCharacter(primaryPart.Parent) then
			local clone = game.ServerStorage.Scripts.OwnerSetter:Clone()
			clone.Parent = primaryPart

			if game.Players:GetPlayerFromCharacter(primaryPart.Parent) then
				clone.PlayerValue.Value = game.Players:GetPlayerFromCharacter(primaryPart.Parent)
			end

			clone.Duration.Value = 0.515
			clone.Disabled = false
		end

		if decoding2 and decoding2.Parent ~= nil and decoding2.Value ~= nil and player then
			decoding2.Value:WaitForChild("Stats"):WaitForChild("ForceStop"):Fire(player)
			ReplicatedStorage.Events.StopInteracting:FireClient(player)
		end

		local tween = TweenService:Create(primaryPart, tweenInfo2, {
			CFrame = p * CFrame.Angles(0, 3.141592653589793, 0)
		})
		tween:Play()
		tween.Completed:Wait()

		if primaryPart2 and primaryPart2.Parent ~= nil then
			primaryPart2.Anchored = false
		end

		if primaryPart and primaryPart.Parent ~= nil and decoding2.Value == nil then
			primaryPart.Anchored = false
		end

		removeCharacterAntiExploitModule:Fire(instance2, false)
		removeCharacterAntiExploitModule:Fire(player, false)
	end)
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

function Goob.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	instance.Head.TextureID = config.HurtTexture.Texture
	task.wait(2)

	if instance.Parent ~= nil then
		instance.Head.TextureID = config.NormalTexture.Texture
	end
end

return Goob