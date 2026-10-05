local createVector = vector.create
local Rudie = {
	Name = "Rudie",
	Icon = "rbxassetid://72865471267749",
	VoteIcon = "rbxassetid://115049360703538",
	Render = "rbxassetid://89896103645402",
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 3,
	SkillCheckRank = 3,
	Ability1Name = "Antler Charge",
	Ability1Type = "Active",
	Ability1Description = "This Toon uses his antlers to quickly charge forward in a short burst, helping him escape tricky situations.",
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
	BoundarySize = 150,
	Cost = 300,
	Requirement1 = { "Christmas2025Ornaments", 300 },
	HolidayToon = true,
	HolidayTower = true,
	Christmas = true,
	LightToon = true,
	MasterySkin = "VintageRudie",
	MasteryRequirements = {
		{
			Name = "CompleteGenerator",
			Requirement = 30
		},
		{
			Name = "ActiveAbilityActivate",
			Requirement = 60
		},
		{
			Name = "SurviveFloor",
			Requirement = 25
		},
		{
			Name = "PickUpItem",
			Requirement = 35
		},
		{
			Name = "UseItem",
			Requirement = 30
		},
		{
			Name = "TravelDistance",
			Requirement = 50000
		}
	},
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://121879477765524",
	AbilityCooldown = 23,
	AbilityDuration = 0.4,
	AbilityRange = 15,
	CustomAbilitySound = "rbxassetid://5272402910"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
Rudie.RightHandBone = "R_hand"

function Rudie.OnLoad(instance)
	task.spawn(function()
		local nose = instance and instance:WaitForChild("Nose", 60)
		local weldConstraint = nose and nose:WaitForChild("WeldConstraint", 60)

		if not weldConstraint then
			return
		end

		task.wait()
		weldConstraint.Enabled = false
	end)
end

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

function Rudie.UseActiveAbility(p, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown2 = ability1:WaitForChild("Cooldown")
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

	currentCooldown.Value = cooldown2.Value
	task.spawn(function()
		game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(p, true)
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
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local StatModifierManager = require(ReplicatedStorage2.Modules.Data.StatModifierManager)
		local v = StatModifierManager.ApplyAdditiveSpeedBoost(instance, 50, "RudieDash", {
			category = "ability",
			antiCheat = true
		})
		task.delay(Rudie.AbilityDuration, function()
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

local nows = {}
Rudie.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Rudie.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			local track = humanoid:LoadAnimation((animations:WaitForChild("Ability")))

			for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
				if v.Name ~= "Ability" then
					continue
				end

				v:Stop()
				v:Destroy()
			end

			track:Play()

			local function dothing()
				if instance and instance.Parent ~= nil then
					local rudieBoost = ReplicatedStorage.Parts.RenderModules.RudieBoost
					ReplicatedStorage.Events.RenderObject:FireAllClients(rudieBoost, { instance })
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 0.5
				part.Size = createVector(1, 1, 1)
				part.Parent = workspace
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Size = createVector(2, 2, 2),
					Transparency = 1
				}):Play()
				Debris:AddItem(part, 0.3)
				cooldown = false
			end

			if nows[p] then
				if p2 < tick() - nows[p] then
					nows[p] = tick()
					cooldown = true
					dothing()
				end
			else
				nows[p] = tick()
				cooldown = true
				dothing()
			end
		end
	}
}
return Rudie