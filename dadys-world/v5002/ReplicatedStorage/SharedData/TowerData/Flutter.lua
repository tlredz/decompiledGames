local Flutter = {
	Name = "Flutter",
	Icon = "rbxassetid://18225864350",
	VoteIcon = "rbxassetid://18225864205",
	Render = "rbxassetid://73305488503673",
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 4,
	StealthRank = 3,
	SkillCheckRank = 2,
	IchorLeakImmune = true,
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
	BoundarySize = 100,
	Cost = 1300,
	Requirement1 = { "Coin", 1300 },
	Requirement2 = { "Research", 100, "FlutterMonster" },
	MasterySkin = "VintageFlutter",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 100
		},
		{
			Name = "TravelDistance",
			Requirement = 90000
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
			Requirement = 45
		},
		{
			Name = "ReachFloor",
			Requirement = 1,
			Number = 12
		}
	}
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

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
Flutter.CustomAbilitySound = {
	SoundId = "rbxassetid://5272402910",
	PlaybackSpeed = 1.5,
	Volume = 0.6
}

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
		game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(p, true)
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
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local StatModifierManager = require(ReplicatedStorage2.Modules.Data.StatModifierManager)
		local v = StatModifierManager.ApplyAdditiveSpeedBoost(instance, 50, "FlutterDash", {
			category = "ability",
			antiCheat = true
		})
		task.delay(Flutter.AbilityDuration, function()
			if v then
				StatModifierManager.RemoveAdditiveSpeedBoost(instance, v)
			end

			instance:SetAttribute("AbilityAnimationActive", nil)
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
	task.spawn(function()
		local rootPart = instance:WaitForChild("RootPart", 5)
		local root_jnt = rootPart and rootPart:WaitForChild("root_jnt", 5)
		local torso_jnt = root_jnt and root_jnt:WaitForChild("torso_jnt", 5)
		local chest_jnt = torso_jnt and torso_jnt:WaitForChild("chest_jnt", 5)
		local head_jnt = chest_jnt and chest_jnt:WaitForChild("head_jnt", 5)

		if not head_jnt then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.CFrame = CFrame.new(1, 1.6, -0.2) * CFrame.Angles(
			1.0471975511965976,
			-3.839724354387525,
			-1.0471975511965976
		) * CFrame.Angles(0, 3.141592653589793, 0)
		attachment.Name = "LatchedAttachment"
		attachment.Parent = head_jnt
	end)
end

local nows = {}
Flutter.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Flutter.Ability1Name .. " (%d sec)",
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
					local flutterFly = ReplicatedStorage.Parts.RenderModules.FlutterFly
					ReplicatedStorage.Events.RenderObject:FireAllClients(flutterFly, { instance })
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
return Flutter