local Rudie = {
	Name = "Rudie",
	Icon = "rbxassetid://72865471267749",
	VoteIcon = "rbxassetid://115049360703538",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 3,
	SkillCheckRank = 3,
	Ability1Name = "Antler Charge",
	Ability1Type = "Active",
	Ability1Description = "This Toon uses his antlers to quickly charge forward in a short burst, helping him escape tricky situations.",
	CustomAbilitySound = "rbxassetid://5272402910",
	LightToon = true,
	PassiveAbilityModule = "Rudie",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 10,
	Stamina = 150,
	BoundarySize = 150
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)

function Rudie.HurtAnimation(instance)
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

Rudie.ActiveAbility = true
Rudie.AbilityIcon = "rbxassetid://121879477765524"
Rudie.AbilityCooldown = 23
Rudie.AbilityDuration = 0.4
Rudie.AbilityRange = 15

function Rudie.UseActiveAbility(p, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	instance:WaitForChild("Humanoid")
	local decoding = instance:WaitForChild("Decoding")
	instance:WaitForChild("HumanoidRootPart")

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

	if decoding.Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		local removeCharacterAntiExploitModule = game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule")
		removeCharacterAntiExploitModule:Fire(p, true)
		instance:SetAttribute("AbilityAnimationActive", true)
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

		if instance and instance.Parent ~= nil then
			local rudieBoost = ReplicatedStorage.Parts.RenderModules.RudieBoost
			ReplicatedStorage.Events.RenderObject:FireAllClients(rudieBoost, { instance })
		end

		local stats2 = instance:WaitForChild("Stats")
		stats2:WaitForChild("WalkSpeed")
		stats2:WaitForChild("RunSpeed")
		instance:WaitForChild("Humanoid")
		stats2:WaitForChild("Sprinting")
		stats2:WaitForChild("SpeedModifier")
		stats2:WaitForChild("RunSpeedModifier")
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		task.wait()
		local lookVector = humanoidRootPart.CFrame.LookVector
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
			lookVector.X * 55,
			assemblyLinearVelocity.Y,
			lookVector.Z * 55
		)
		local v = StatModifierManager.ApplyAdditiveSpeedBoost(instance, 50, "RudieAntlerCharge", {
			antiCheat = true
		})
		task.delay(Rudie.AbilityDuration, function()
			StatModifierManager.RemoveAdditiveSpeedBoost(instance, v)
			instance:SetAttribute("AbilityAnimationActive", nil)
			task.wait(1)
			removeCharacterAntiExploitModule:Fire(p, false)
		end)
		local attachment = Instance.new("Attachment")
		attachment.Name = "BuffParticle"
		attachment.Parent = humanoidRootPart
		local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
		clone.Parent = attachment
		clone.Enabled = true
		local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
		clone2.Parent = attachment
		clone2.Enabled = true
		Debris:AddItem(clone, Rudie.AbilityDuration + 1)
		Debris:AddItem(clone2, Rudie.AbilityDuration + 1)
		Debris:AddItem(attachment, Rudie.AbilityDuration + 1)
		task.delay(Rudie.AbilityDuration, function()
			if instance and instance.Parent ~= nil and attachment then
				clone.Enabled = false
				clone2.Enabled = false
			end
		end)
	end)
	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v2 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v2)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

Rudie.Cost = 300
Rudie.Requirement1 = { "HolidayPoints", 300 }
Rudie.HolidayTower = true
Rudie.HolidayToon = true
Rudie.HolidayTower = true
Rudie.MasterySkin = "VintageRudie"
return Rudie