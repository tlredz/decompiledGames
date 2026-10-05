local Flutter = {
	Name = "Flutter",
	Icon = "rbxassetid://18225864350",
	VoteIcon = "rbxassetid://18225864205",
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 4,
	StealthRank = 3,
	SkillCheckRank = 2,
	Ability1Name = "Floaty Dash",
	Ability1Type = "Active",
	Ability1Description = "This Toon can dash forward, drastically increasing her Movement Speed for 0.75 Seconds. Has a cooldown of 45.",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 10,
	Stamina = 175,
	BoundarySize = 100
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)

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

function Flutter.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	setFaceTexture(instance, config.HurtTexture.Texture)
	task.wait(2)

	if instance.Parent ~= nil then
		setFaceTexture(instance, config.NormalTexture.Texture)
	end
end

Flutter.ActiveAbility = true
Flutter.AbilityIcon = "rbxassetid://18227483474"
Flutter.AbilityCooldown = 45
Flutter.AbilityDuration = 0.75
Flutter.AbilityRange = 30
Flutter.CustomAbilitySound = script.Sound

function Flutter.UseActiveAbility(p, instance, _)
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
			local flutterFly = ReplicatedStorage.Parts.RenderModules.FlutterFly
			ReplicatedStorage.Events.RenderObject:FireAllClients(flutterFly, { instance })
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
		local v = StatModifierManager.ApplyAdditiveSpeedBoost(instance, 50, "FlutterFloatyDash", {
			antiCheat = true
		})
		task.delay(Flutter.AbilityDuration, function()
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
		Debris:AddItem(clone, Flutter.AbilityDuration + 1)
		Debris:AddItem(clone2, Flutter.AbilityDuration + 1)
		Debris:AddItem(attachment, Flutter.AbilityDuration + 1)
		task.delay(Flutter.AbilityDuration, function()
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

function Flutter.SpecialSetup(instance)
	instance:SetAttribute("IchorPuddleImmune", true)
end

return Flutter