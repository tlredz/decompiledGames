local createVector = vector.create
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
	Render = "rbxassetid://127724693999368",
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
	Ability2Description = "This Toon gains a 25% Movement Speed boost when any Machine is completed for 10 seconds.",
	Cost = 4250,
	Requirement1 = { "Coin", 4250 },
	Requirement2 = { "Research", 100, "ShellyMonster" },
	Requirement3 = { "Mastery", 100, "Tisha" },
	MasterySkin = "VintageShelly",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 125
		},
		{
			Name = "TravelDistance",
			Requirement = 150000
		},
		{
			Name = "PickUpItem",
			Requirement = 100
		},
		{
			Name = "SurviveFloorWithParty",
			Requirement = 15,
			Number = 5
		},
		{
			Name = "CompleteGenerator",
			Requirement = 150
		},
		{
			Name = "SurviveFloor",
			Requirement = 80
		}
	},
	ActiveAbility = true,
	PlayerAbility = true,
	PlayerRadius = 60,
	AbilityIcon = "rbxassetid://18209649932",
	AbilityCooldown = 60,
	AbilityDuration = 15,
	CustomAbilitySound = {
		SoundId = "rbxassetid://6684542570",
		PlaybackSpeed = 1,
		Volume = 0.2
	}
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local TweenService = game:GetService("TweenService")

function Shelly.CreateTargetVisual(instance, p)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local v

	if humanoidRootPart then
		v = humanoidRootPart:FindFirstChild("StickerOverride") or nil
	end

	local adornee = v or instance.PrimaryPart or humanoidRootPart or instance
	local v3, v4 = HighlightController:PlayHighlight(instance, "Target", {
		FillColor = Color3.fromRGB(255, 255, 255),
		FillTransparency = 0.85,
		OutlineColor = Color3.fromRGB(255, 255, 255),
		OutlineTransparency = 0,
		Billboard = {
			Label = p and "MACHINE" or "TARGET",
			Size = p and UDim2.new(16, 0, 16, 0) or UDim2.new(6, 0, 6, 0),
			Adornee = adornee
		},
		Priority = HighlightController.Priority.LOCAL_ABILITY
	})

	if not v4 then
		return v3, v4
	end

	v4.DistanceStep = 1
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

	local function onChange()
		v4:SetAttribute("Height", v4.CurrentDistance <= 30 and createVector(0, 3.2, 0) or createVector(0, 1, 0))
	end

	v4:GetAttributeChangedSignal("Height"):Connect(function()
		local height = v4:GetAttribute("Height") or createVector(0, 1, 0)
		TweenService:Create(v4, tweenInfo, {
			StudsOffset = height
		}):Play()
	end)
	v4:GetPropertyChangedSignal("CurrentDistance"):Connect(onChange)
	v4:SetAttribute("Height", v4.CurrentDistance <= 30 and createVector(0, 3.2, 0) or createVector(0, 1, 0))
	return v3, v4
end

Shelly.RightHandBone = "R_finger"

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

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

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
		local shellyEffect = ReplicatedStorage2.Parts.RenderModules.ShellyEffect
		ReplicatedStorage2.Events.RenderObject:FireAllClients(shellyEffect, { instance })
	end

	local success, result = pcall(function()
		if instance2 then
			local humanoidRootPart = instance2:WaitForChild("HumanoidRootPart")
			local _ = (p.Position - humanoidRootPart.Position).Magnitude
			local stats2 = instance2:WaitForChild("Stats")
			stats2:WaitForChild("WalkSpeed")
			stats2:WaitForChild("RunSpeed")
			instance2:WaitForChild("Humanoid")
			stats2:WaitForChild("Sprinting")
			local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
			local StatModifierManager = require(ReplicatedStorage3.Modules.Data.StatModifierManager)
			local v2 = StatModifierManager.ApplyModifier(instance2, "DecodeSpeedModifier", 1.75, "ShellyCheer", {
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

local nows = {}
Shelly.PlayFunctions = {
	RPAbility = {
		Cooldown = 10,
		DisplayName = Shelly.Ability1Name .. " (%d sec)",
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
					local shellyEffect = ReplicatedStorage2.Parts.RenderModules.ShellyEffect
					ReplicatedStorage2.Events.RenderObject:FireAllClients(shellyEffect, { instance })
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
return Shelly