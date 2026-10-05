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
	Render = "rbxassetid://133708170138877",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 4,
	StealthRank = 2,
	SkillCheckRank = 3,
	Ability1Name = "Tea Time",
	Ability1Type = "Active",
	Ability1Description = "This Toon can spend 75 Tapes to heal themself by 1 Heart. Has a Cooldown of 100.",
	Cost = 1250,
	Requirement1 = { "Coin", 1250 },
	Requirement2 = { "DandyStoreItem", 25 },
	MasterySkin = "VintageTeagan",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 25
		},
		{
			Name = "TravelDistance",
			Requirement = 75000
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
			Name = "EncounterMonster",
			Requirement = 25
		},
		{
			Name = "BuyDandyStoreItem",
			Requirement = 15
		}
	},
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://18185982499",
	AbilityCooldown = 100,
	AbilityCost = 75,
	CustomAbilitySound = {
		SoundId = "rbxassetid://9119516340",
		PlaybackSpeed = 0.8,
		Volume = 0.4
	},
	RightHandBone = "hand.r",
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		setFaceTexture(instance, config.HurtTexture.Texture)
		task.wait(2)

		if instance.Parent ~= nil then
			setFaceTexture(instance, config.NormalTexture.Texture)
		end
	end,
	ClientAbility = function(_, _) end,
	UseActiveAbility = function(_, instance, _)
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
}
local nows = {}
Teagan.PlayFunctions = {
	RPAbility = {
		Cooldown = 10,
		DisplayName = Teagan.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
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

				if instance and instance.Parent ~= nil then
					local particles = instance:WaitForChild("Head"):WaitForChild("Particles")
					particles.ParticleEmitter:Emit(10)
					particles.ParticleEmitter2:Emit(10)
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
return Teagan