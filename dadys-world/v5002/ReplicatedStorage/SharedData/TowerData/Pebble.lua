local Pebble = {}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local v = {
	Bandage = true,
	HealthKit = true
}
Pebble.Name = "Pebble"
Pebble.Cost = 100
Pebble.Icon = "rbxassetid://16882259119"
Pebble.VoteIcon = "rbxassetid://16846452241"
Pebble.Render = "rbxassetid://71909748265903"
Pebble.Health = 2
Pebble.MainCharacter = true
Pebble.WalkSpeed = 20
Pebble.RunSpeed = 30
Pebble.DecodeSpeed = 0.75
Pebble.SkillCheckChance = 25
Pebble.SkillCheckValue = 2
Pebble.Stealth = 10
Pebble.Stamina = 175
Pebble.BoundarySize = 150
Pebble.DecodeRank = 1
Pebble.SpeedRank = 5
Pebble.StaminaRank = 4
Pebble.StealthRank = 3
Pebble.SkillCheckRank = 3
Pebble.Ability1Name = "Speak!"
Pebble.Ability1Type = "Active"
Pebble.Ability1Description = "This Toon can bark loudly, drastically decreasing Stealth and alerting any Twisteds nearby to his location. Has a Cooldown of 60."
Pebble.Ability2Name = "Fetch!"
Pebble.Ability2Type = "Passive"
Pebble.Ability2Description = "This Toon can sniff out items, causing them to be highlighted when in the Toon's vicinity."
Pebble.ActiveAbility = true
Pebble.AbilityIcon = "rbxassetid://18817555699"
Pebble.AbilityCooldown = 60
Pebble.CustomAbilitySound = {
	SoundId = "rbxassetid://16803359029",
	PlaybackSpeed = 1.5,
	Volume = 0.5
}
Pebble.AbilityDuration = 10
Pebble.MasterySkin = "VintagePebble"
Pebble.Cost = 3750
Pebble.Requirement1 = { "Coin", 3750 }
Pebble.Requirement2 = { "Research", 100, "PebbleMonster" }
Pebble.Requirement3 = { "Mastery", 100, "Toodles" }
Pebble.MasteryRequirements = {
	{
		Name = "ActiveAbilityActivate",
		Requirement = 145
	},
	{
		Name = "TravelDistance",
		Requirement = 175000
	},
	{
		Name = "PickUpItem",
		Requirement = 200
	},
	{
		Name = "EncounterMonster",
		Requirement = 80
	},
	{
		Name = "SurviveFloor",
		Requirement = 75
	},
	{
		Name = "ReachFloor",
		Requirement = 1,
		Number = 20
	}
}

function Pebble.SpecialSetup(instance)
	task.spawn(function()
		local rootPart = instance:WaitForChild("RootPart", 5)
		local rootPartRoot = rootPart and rootPart:WaitForChild("root", 5)
		local tail = rootPartRoot and rootPartRoot:WaitForChild("tail", 5)

		if not tail then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.CFrame = CFrame.new(-0.6, 0.8, -0.2) * CFrame.Angles(0, -2.0943951023931953, 3.141592653589793) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		attachment.Name = "LatchedAttachment"
		attachment.Parent = tail
	end)
end

function Pebble.ClientAbility(_, instance)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if model then
		local items = model:FindFirstChild("Items")

		if not items then
			return
		end

		local children = items:GetChildren()

		for _, v2 in pairs(children) do
			if not v2:GetChildren()[1] or not instance.PrimaryPart or not v2.PrimaryPart or v2:GetAttribute("GigiHoardProp") then
				continue
			end

			if not ((instance.PrimaryPart.Position - v2.PrimaryPart.Position).Magnitude <= 125) then
				continue
			end

			local v3, label

			if v2.Name == "Tape" then
				v3 = "Tape"
				label = "TAPES"
			elseif v2.Name == "ResearchCapsule" or v2.Name == "FakeCapsule" then
				v3 = "Research"
				label = "CAPSULE"
			else
				v3 = v[v2.Name] and "Healing" or "Item"
				label = "ITEM"
			end

			HighlightController:PlayHighlight(v2, v3, {
				FillColor = Color3.fromRGB(255, 255, 255),
				FillTransparency = 1,
				OutlineColor = Color3.fromRGB(255, 255, 255),
				OutlineTransparency = 0,
				Decay = 3,
				Billboard = {
					Label = label
				},
				Priority = HighlightController.Priority.LOCAL_ABILITY
			})
			task.wait()
		end
	end
end

function Pebble.UseActiveAbility(_, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Stealth")
	stats:WaitForChild("StealthModifier")
	local parts = ReplicatedStorage:WaitForChild("Parts")

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

	local _ = {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
	currentCooldown.Value = cooldown.Value
	local v2 = { instance, Pebble.AbilityDuration }
	local pebbleRage = ReplicatedStorage.Parts.RenderModules.PebbleRage
	ReplicatedStorage.Events.RenderObject:FireAllClients(pebbleRage, v2)

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = parts.PebbleBuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			Debris:AddItem(clone, Pebble.AbilityDuration + 1)
			Debris:AddItem(attachment, Pebble.AbilityDuration + 1)
			task.delay(Pebble.AbilityDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
				end
			end)
		end)
	end

	ReplicatedStorage.Events.MachineEvent:Fire(instance)
	local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
	local v4 = StatModifierManager.ApplyAdditiveStealthModifier(instance, -50, "PebbleSpeak", {
		category = "ability"
	})
	task.delay(Pebble.AbilityDuration, function()
		if instance and instance.Parent ~= nil and v4 then
			StatModifierManager.RemoveAdditiveStealthModifier(instance, v4)
		end
	end)
	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v6 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v6)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

function Pebble.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	local mainBody = instance:FindFirstChild("MainBody") or instance:FindFirstChild("Head")

	if mainBody then
		mainBody.TextureID = config.HurtTexture.Texture
	end

	task.wait(2)

	if instance.Parent ~= nil and mainBody then
		mainBody.TextureID = config.NormalTexture.Texture
	end
end

local nows = {}
Pebble.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Pebble.Ability1Name .. " (%d sec)",
		Action = function(p, p2, p3)
			if not (p and p2) then
				return
			end

			local function dothing()
				if p2 and p2.Parent ~= nil then
					local pebbleRage = ReplicatedStorage.Parts.RenderModules.PebbleRage
					ReplicatedStorage.Events.RenderObject:FireAllClients(pebbleRage, { p2 })
				end
			end

			if nows[p] then
				if p3 < tick() - nows[p] then
					nows[p] = tick()

					if p2 and p2.Parent ~= nil then
						local pebbleRage = ReplicatedStorage.Parts.RenderModules.PebbleRage
						ReplicatedStorage.Events.RenderObject:FireAllClients(pebbleRage, { p2 })
					end
				end
			else
				nows[p] = tick()

				if p2 and p2.Parent ~= nil then
					local pebbleRage = ReplicatedStorage.Parts.RenderModules.PebbleRage
					ReplicatedStorage.Events.RenderObject:FireAllClients(pebbleRage, { p2 })
				end
			end
		end
	}
}
return Pebble