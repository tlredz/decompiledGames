local createVector = vector.create
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
	Render = "rbxassetid://138723059741802",
	DecodeRank = 5,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 2,
	SkillCheckRank = 2,
	Ability1Name = "Reflection",
	Ability1Type = "Active",
	Ability1Description = "This Toon can travel through a mirror, instantly teleporting to a targeted Toon regardless of line of sight. Has a cooldown of 100.",
	ActiveAbility = true,
	PlayerAbility = true,
	PlayerRadius = 80,
	AbilityIcon = "rbxassetid://18839978493",
	AbilityCooldown = 100,
	CustomAbilitySound = {
		SoundId = "rbxassetid://814169516",
		PlaybackSpeed = 1.5,
		Volume = 0.35
	},
	Cost = 2500,
	Requirement1 = { "Coin", 2500 },
	Requirement2 = { "Research", 50, "GlistenMonster" },
	Requirement3 = { "CompleteGenerator", 300 },
	MasterySkin = "VintageGlisten",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 60
		},
		{
			Name = "TravelDistance",
			Requirement = 100000
		},
		{
			Name = "PickUpItem",
			Requirement = 60
		},
		{
			Name = "UseItem",
			Requirement = 60
		},
		{
			Name = "SurviveFloor",
			Requirement = 50
		},
		{
			Name = "CompleteGenerator",
			Requirement = 100
		}
	},
	RightHandBone = "forearm_stretch.r",
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

function Glisten.UseActiveAbility(instance, instance2, p, instance3)
	instance2:WaitForChild("Config")
	local decoding = instance2:WaitForChild("Decoding")
	local ability1 = instance2:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance2:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local humanoid = instance2:WaitForChild("Humanoid")
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

	if not instance3 or instance3.Parent == nil then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	local humanoid2 = instance3:WaitForChild("Humanoid")

	if humanoid.Health <= 0 or humanoid2.Health <= 0 then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	local primaryPart = instance3.PrimaryPart
	local primaryPart2 = instance2.PrimaryPart
	local magnitude = (p.Position - primaryPart.Position).Magnitude
	local v = {
		Outcome = true,
		Reason = instance3.Name
	}

	if Glisten.PlayerRadius < magnitude then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance2, "Ability")
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	CFrame.lookAt(p.Position, primaryPart.Position)
	local v2 = humanoid.HipHeight + primaryPart2.Size.Y / 2
	local v3 = humanoid2.HipHeight + primaryPart.Size.Y / 2
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance2, "Ability")

		if instance2 and instance2.Parent ~= nil then
			local v4 = { instance2, primaryPart, primaryPart2.CFrame }
			local glistenPortal = ReplicatedStorage.Parts.RenderModules.GlistenPortal
			ReplicatedStorage.Events.RenderObject:FireAllClients(glistenPortal, v4)
		end
	end)

	if instance then
		instance:SetAttribute("KM_TELEPORT_TEMPORARY_EXCEPTION", true)
		removeCharacterAntiExploitModule:Fire(instance, true)
	end

	instance2.PrimaryPart:SetNetworkOwner(nil)
	instance2:PivotTo(primaryPart.CFrame * CFrame.new(0, -v3 + v2, 0))
	instance2.PrimaryPart:SetNetworkOwner(instance)
	local DebuffManager = require(game.ReplicatedStorage.Modules.Gameplay.DebuffManager)
	DebuffManager.ApplyConfusion(instance2, 3, 10)
	task.spawn(function()
		task.wait(2)
		removeCharacterAntiExploitModule:Fire(instance, false)
	end)
	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		local lastTime = os.clock()

		while instance2 do
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

local nows = {}
Glisten.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Glisten.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
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
				model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
				part.Parent = model
				model.PrimaryPart = part
				model:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, 15))
				local Debris = game:GetService("Debris")
				Debris:AddItem(model, 5)

				if instance and instance.Parent ~= nil then
					local v = {
						instance,
						{
							Size = part.Size,
							CFrame = part.CFrame,
							Position = part.Position
						},
						humanoidRootPart.CFrame
					}
					local glistenPortal = ReplicatedStorage.Parts.RenderModules.GlistenPortal
					ReplicatedStorage.Events.RenderObject:FireAllClients(glistenPortal, v)
				end
			end

			if nows[p] then
				if p2 < tick() - nows[p] then
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
return Glisten