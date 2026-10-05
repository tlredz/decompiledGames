local createVector = vector.create
local Cosmo = {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 1,
	Stealth = 15,
	Stamina = 175,
	BoundarySize = 50,
	Name = "Cosmo",
	Icon = "rbxassetid://18595002771",
	VoteIcon = "rbxassetid://18645267770",
	Render = "rbxassetid://113528242616055",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 4,
	StealthRank = 4,
	SkillCheckRank = 1,
	Ability1Name = "Sharing is Caring",
	Ability1Type = "Active",
	Ability1Description = "This Toon can give one of his own Hearts to heal a targeted Toon. Cannot be used when at 1 Heart. Has a Cooldown of 60.",
	Cost = 1000,
	Requirement1 = { "Coin", 1000 },
	Requirement2 = { "ToonsOwned", 4 },
	MasterySkin = "VintageCosmo",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 25
		},
		{
			Name = "TravelDistance",
			Requirement = 60000
		},
		{
			Name = "PickUpItem",
			Requirement = 35
		},
		{
			Name = "SurviveFloor",
			Requirement = 30
		},
		{
			Name = "SurviveFloorWithParty",
			Requirement = 5,
			Number = 4
		},
		{
			Name = "UseItem",
			Requirement = 35
		}
	},
	ActiveAbility = true,
	PlayerAbility = true,
	PlayerRadius = 105,
	AbilityIcon = "rbxassetid://18612562814",
	AbilityCooldown = 60,
	AbilityDuration = 15,
	CustomAbilitySound = {
		SoundId = "rbxassetid://18553104869",
		PlaybackSpeed = 1,
		Volume = 0.2
	},
	RightHandBone = "head.x",
	LatchedBoneOffset = CFrame.new(1.8, 2, 0) * CFrame.Angles(1.5707963267948966, 0, 0),
	SpecialSetup = function(_) end,
	HurtAnimation = function(instance)
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

function Cosmo.UseActiveAbility(p, instance, p2, instance2)
	local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
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

	if humanoid.Health <= 1 then
		return {
			Outcome = false,
			Reason = "Can't use that Ability on 1 Heart!"
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
	local _ = (p2.Position - primaryPart.Position).Magnitude
	local v = {
		Outcome = true,
		Reason = instance2.Name
	}
	currentCooldown.Value = cooldown.Value
	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

	if instance and instance.Parent ~= nil then
		local cosmoCookie = ReplicatedStorage.Parts.RenderModules.CosmoCookie
		ReplicatedStorage.Events.RenderObject:FireAllClients(cosmoCookie, { instance, instance2 })
	end

	local success, result = pcall(function()
		if instance2 and humanoid2 and humanoid then
			humanoid.Health -= 1
			humanoid2.Health += 1

			if humanoid2.Health >= humanoid2.MaxHealth then
				humanoid2.Health = humanoid2.MaxHealth
			end

			ActionEvent:Record(instance2, "ReceiveActiveAbility", "Cosmo", p and p.UserId)
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

local nows = {}
Cosmo.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Cosmo.Ability1Name .. " (%d sec)",
		Action = function(p, instance, _)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
			local track = humanoid:LoadAnimation((animations:WaitForChild("Ability")))

			local function dothing()
				for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
					if v.Name ~= "Ability" then
						continue
					end

					v:Stop()
					v:Destroy()
				end

				track:Play()
				local part = Instance.new("Part")
				part.Name = "HumanoidRootPart"
				part.Size = createVector(1, 1, 1)
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Transparency = 1
				local model = Instance.new("Model")
				model.Parent = workspace
				part.Parent = model
				model.PrimaryPart = part
				model:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -12))
				local Debris = game:GetService("Debris")
				Debris:AddItem(model, 5)

				if instance and instance.Parent ~= nil then
					local cosmoCookie = ReplicatedStorage.Parts.RenderModules.CosmoCookie
					ReplicatedStorage.Events.RenderObject:FireAllClients(cosmoCookie, { instance, model })
				end
			end

			if nows[p] then
				if tick() - nows[p] > 15 then
					nows[p] = tick()
					dothing()
				end
			else
				nows[p] = tick()
				dothing()
			end
		end
	}
}
return Cosmo