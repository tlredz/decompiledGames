local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ginger = {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 12.5,
	RunSpeed = 22.5,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 15,
	Stamina = 150,
	BoundarySize = 150,
	Name = "Ginger",
	Icon = "rbxassetid://87154471381383",
	VoteIcon = "rbxassetid://89066846966836",
	Render = "rbxassetid://70530017377094",
	DecodeRank = 3,
	SpeedRank = 2,
	StaminaRank = 3,
	StealthRank = 4,
	SkillCheckRank = 3,
	Ability1Name = "Baked with Care!",
	Ability1Type = "Active",
	Ability1Description = "This Toon can heal a nearby targeted Toon to full Hearts at the cost of 100 Tapes with a cooldown of 100. For each extra Ginger, the cost increases by 50 Tapes and the Cooldown increases by 30.",
	CustomAbilitySound = "rbxassetid://18553104869",
	HoldProximityAbility = true,
	Cost = 700,
	Requirement1 = { "Christmas2025Ornaments", 700 },
	Requirement2 = { "Research", 50, "GingerMonster" },
	HolidayToon = true,
	HolidayTower = true,
	Christmas = true,
	MasterySkin = "VintageGinger",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 25
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
			Name = "UseItem",
			Requirement = 35
		},
		{
			Name = "SurviveFloorWithParty",
			Requirement = 10,
			Number = 3
		},
		{
			Name = "TravelDistance",
			Requirement = 55000
		}
	},
	ActiveAbility = true,
	PlayerAbility = true,
	HealRange = 24
}
Ginger.PlayerRadius = Ginger.HealRange
Ginger.AbilityIcon = "rbxassetid://133423550171858"
Ginger.AbilityCooldown = 100
Ginger.AbilityDuration = 15
Ginger.AbilityCost = 100
Ginger.RightHandBone = "R_hand"

function Ginger.HurtAnimation(instance)
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

function Ginger.SpecialSetup(instance)
	instance:SetAttribute("HasHoldProximityAbility", true)
	instance:SetAttribute("ProximityRange", Ginger.HealRange)
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")

	if not ability1:FindFirstChild("AbilityCost") then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "AbilityCost"
		numberValue.Value = 100
		numberValue.Parent = ability1
	end

	local GingerAbility = require(game.ReplicatedStorage.CharacterModules.GingerAbility)
	local abilityCost = ability1:FindFirstChild("AbilityCost")

	if abilityCost then
		abilityCost.Value = GingerAbility.GetTapeCost()
	end

	local cooldown = ability1:FindFirstChild("Cooldown")
	local v = GingerAbility.GetCooldown() - Ginger.AbilityCooldown

	if cooldown and v > 0 then
		cooldown.Value += v
	end

	if cooldown then
		cooldown:SetAttribute("KitCooldownBonus", v)
	end

	GingerAbility.InitializePrompts(instance)
	local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
	task.spawn(function()
		while instance and instance.Parent do
			local _, v2 = TowerLUT:GetEffectiveTower(instance)

			if not v2 then
				local tapeCost = GingerAbility.GetTapeCost()

				if abilityCost and abilityCost.Value ~= tapeCost then
					abilityCost.Value = tapeCost
				end

				local v3 = GingerAbility.GetCooldown() - Ginger.AbilityCooldown

				if cooldown and v3 ~= v then
					cooldown.Value = cooldown.Value - v + v3

					if cooldown.Value < 5 then
						cooldown.Value = 5
					end

					v = v3
					cooldown:SetAttribute("KitCooldownBonus", v)
				end
			end

			task.wait(2)
		end

		GingerAbility.CleanupPrompts(instance)
	end)
	workspace.Info.Floor.Changed:Connect(function()
		if instance and instance.Parent then
			for k, _ in pairs(instance:GetAttributes()) do
				if k:match("^GingerAbilityUsed_Floor") then
					instance:SetAttribute(k, nil)
				end
			end
		end
	end)
end

function Ginger.UseActiveAbility(p, instance, _, instance2)
	print(
		"[Ginger.UseActiveAbility] Called for player:",
		p.Name,
		"foundplayer:",
		not instance2 and "nil" or instance2.Name or "nil"
	)
	local decoding = instance:WaitForChild("Decoding")
	local currentCooldown = instance:WaitForChild("Abilities"):WaitForChild("Ability1"):WaitForChild("CurrentCooldown")

	if currentCooldown.Value > 0 then
		print("[Ginger.UseActiveAbility] BLOCKED: On cooldown:", currentCooldown.Value)
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if not workspace.CurrentRoom:FindFirstChildOfClass("Model") then
		print("[Ginger.UseActiveAbility] BLOCKED: No room (in elevator)")
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if workspace.Info.FloorActive.Value ~= true then
		print("[Ginger.UseActiveAbility] BLOCKED: Floor not active")
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if decoding.Value ~= nil then
		print("[Ginger.UseActiveAbility] BLOCKED: Currently decoding")
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	if not (instance2 and instance2.Parent) then
		print("[Ginger.UseActiveAbility] BLOCKED: No target selected")
		return {
			Outcome = false,
			Reason = "No target selected! Look at an injured Toon."
		}
	end

	local humanoid = instance2:FindFirstChild("Humanoid")

	if not humanoid then
		print("[Ginger.UseActiveAbility] BLOCKED: Target has no humanoid")
		return {
			Outcome = false,
			Reason = "Invalid target!"
		}
	end

	if humanoid.Health >= humanoid.MaxHealth then
		print("[Ginger.UseActiveAbility] BLOCKED: Target at full health")
		return {
			Outcome = false,
			Reason = "Target is at full health!"
		}
	end

	if humanoid.Health <= 0 then
		print("[Ginger.UseActiveAbility] BLOCKED: Target is dead")
		return {
			Outcome = false,
			Reason = "Target is not alive!"
		}
	end

	print("[Ginger.UseActiveAbility] Target valid, starting channel...")
	local GingerAbility = require(game.ReplicatedStorage.CharacterModules.GingerAbility)

	if GingerAbility.IsChanneling(instance) then
		print("[Ginger.UseActiveAbility] BLOCKED: Already channeling")
		return {
			Outcome = false,
			Reason = "Already channeling a heal!"
		}
	end

	local v, reason = GingerAbility.StartChannel(instance, instance2)

	if v then
		print("[Ginger.UseActiveAbility] Channel started successfully")
		return {
			Outcome = "PromptCreated",
			Reason = "Channeling heal... stay close!"
		}
	end

	if reason then
		print("[Ginger.UseActiveAbility] Channel failed:", reason)
		instance:SetAttribute("HoldAbilityFailReason", reason)
		task.delay(0.1, function()
			if instance and instance.Parent then
				instance:SetAttribute("HoldAbilityFailReason", nil)
			end
		end)
		return {
			Outcome = false,
			Reason = reason
		}
	else
		instance:SetAttribute("HoldAbilityFailReason", "")
		task.delay(0.1, function()
			if instance and instance.Parent then
				instance:SetAttribute("HoldAbilityFailReason", nil)
			end
		end)
		return {
			Outcome = "PromptCreated",
			Reason = nil
		}
	end
end

local nows = {}
Ginger.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Ginger.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			local track = humanoid:LoadAnimation((animations:WaitForChild("Ability")))
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

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
					local gingerCookie = ReplicatedStorage.Parts.RenderModules.GingerCookie
					ReplicatedStorage.Events.RenderObject:FireAllClients(gingerCookie, { instance, model })
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
return Ginger