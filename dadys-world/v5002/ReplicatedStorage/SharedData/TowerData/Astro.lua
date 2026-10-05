local Astro = {
	Name = "Astro",
	Icon = "rbxassetid://17476673323",
	VoteIcon = "rbxassetid://17476673553",
	Render = "rbxassetid://101809327829133",
	Health = 2,
	MainCharacter = true,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 20,
	Stamina = 150,
	BoundarySize = 100,
	LightToon = true,
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 5,
	SkillCheckRank = 2,
	Ability1Name = "Nap Time",
	Ability1Type = "Active",
	Ability1Description = "This Toon can create a pulse that fully restores Stamina of the Toons around him. Has a cooldown of 60.",
	Ability2Name = "Well Rested",
	Ability2Type = "Passive",
	Ability2Description = "This Toon regenerates Stamina 50% faster, and can see Toons that are below 50% Stamina around the map.",
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://17701285095",
	AbilityCooldown = 60,
	AbilityRange = 45,
	CustomAbilitySound = {
		SoundId = "rbxassetid://9125634950",
		PlaybackSpeed = 1,
		Volume = 0.25
	},
	Cost = 5000,
	Requirement1 = { "Coin", 5000 },
	Requirement2 = { "Research", 100, "AstroMonster" },
	Requirement3 = { "Encounter", 1, "DandyMonster" },
	MasterySkin = "VintageAstro",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 100
		},
		{
			Name = "TravelDistance",
			Requirement = 150000
		},
		{
			Name = "PickUpItem",
			Requirement = 125
		},
		{
			Name = "UseItem",
			Requirement = 125
		},
		{
			Name = "BlackOut",
			Requirement = 12
		},
		{
			Name = "BuyDandyStoreItem",
			Requirement = 25
		}
	}
}
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local AchievementGiver = RunService:IsServer() and require(ServerStorage.SharedModules.AchievementGiver) or nil

function Astro.OnLoad(instance)
	instance:SetAttribute("ShowParticleOnQuirk", true)
end

function Astro.SpecialSetup(instance)
	task.spawn(function()
		local rootPart = instance:WaitForChild("RootPart", 5)
		local rootx = rootPart and rootPart:WaitForChild("root.x", 5)
		local spine_01x = rootx and rootx:WaitForChild("spine_01.x", 5)
		local spine_02x = spine_01x and spine_01x:WaitForChild("spine_02.x", 5)
		local neckx = spine_02x and spine_02x:WaitForChild("neck.x", 5)
		local headx = neckx and neckx:WaitForChild("head.x", 5)

		if not headx then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.CFrame = CFrame.new(1, 2.1, -0.4) * CFrame.Angles(
			1.0471975511965976,
			-3.839724354387525,
			-1.0471975511965976
		) * CFrame.Angles(0, 3.141592653589793, 0)
		attachment.Name = "LatchedAttachment"
		attachment.Parent = headx
	end)
end

function Astro.HurtAnimation(instance)
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

function Astro.ClientAbility(_, instance)
	if not (instance and instance:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local parts = ReplicatedStorage:WaitForChild("Parts")
	local inGamePlayers = workspace.InGamePlayers

	if inGamePlayers then
		local children = inGamePlayers:GetChildren()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

		for _, v in pairs(children) do
			if not v:GetChildren()[1] or v == instance or v:GetAttribute("GigiHoardProp") then
				continue
			end

			local v2 = v

			local function CreatePopUp()
				if not v2:FindFirstChild("Humanoid") then
					return
				end

				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
				local humanoidRootPart2 = v2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart and humanoidRootPart2) then
					return
				end

				local stats = v2:FindFirstChild("Stats")

				if not stats then
					return
				end

				local currentStamina = stats:FindFirstChild("CurrentStamina")
				local stamina = stats:FindFirstChild("Stamina")

				if not currentStamina or not stamina or stamina.Value == 0 then
					return
				end

				local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
				local v3 = math.clamp(currentStamina.Value / stamina.Value, 0, 1)

				if v3 <= 0.5 then
					local clone = parts.HeartIconBillboards.AstroHeartIcon:Clone()
					clone.Name = "HeartIcon"
					clone.Size = UDim2.new(math.clamp(magnitude / 10, 2, 15), 0, math.clamp(magnitude / 10, 2, 15), 0)
					clone.Frame.Heart1.Visible = true
					clone.TextLabel.Text = string.format("%d%%", v3 * 100)
					clone.Parent = humanoidRootPart2
					TweenService:Create(clone.Frame.Heart1, tweenInfo, {
						ImageTransparency = 0.5
					}):Play()
					Debris:AddItem(clone, 0.5)
				end
			end

			CreatePopUp()
			task.wait()
		end
	end
end

function Astro.UseActiveAbility(_, instance, p)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	instance:WaitForChild("Humanoid")
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

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

		if instance and instance.Parent ~= nil then
			local astroPoof = ReplicatedStorage.Parts.RenderModules.AstroPoof
			ReplicatedStorage.Events.RenderObject:FireAllClients(astroPoof, { instance })
		end
	end)
	local v2 = {}
	local elevators = workspace:FindFirstChild("Elevators")

	if elevators then
		for _, child in pairs(elevators:GetChildren()) do
			local elevatorHitBox = child:FindFirstChild("ElevatorHitBox")

			if not elevatorHitBox then
				continue
			end

			for _, v3 in ipairs(workspace:GetPartsInPart(elevatorHitBox)) do
				if v3.Name == "HumanoidRootPart" then
					v2[v3.Parent] = true
				end
			end
		end
	end

	local count = 0

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		local v3 = child
		local success, result = pcall(function()
			if v3 ~= instance then
				local humanoidRootPart = v3:WaitForChild("HumanoidRootPart")
				local stats2 = v3:WaitForChild("Stats")
				local stamina = stats2:WaitForChild("Stamina")
				local currentStamina = stats2:WaitForChild("CurrentStamina")

				if (p.Position - humanoidRootPart.Position).Magnitude <= Astro.AbilityRange then
					if currentStamina.Value < stamina.Value then
						currentStamina.Value += stamina.Value * 1
					end

					if currentStamina.Value >= stamina.Value then
						currentStamina.Value = stamina.Value
					end

					local attachment = Instance.new("Attachment")
					attachment.Name = "BuffParticle"
					attachment.Parent = humanoidRootPart
					local clone = game.ReplicatedStorage.Parts.BuffParticles.Stamina.BuffParticle:Clone()
					clone.Parent = attachment
					clone.Enabled = true
					local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Stamina.Glow:Clone()
					clone2.Parent = attachment
					clone2.Enabled = true
					Debris:AddItem(clone, 2)
					Debris:AddItem(clone2, 2)
					Debris:AddItem(attachment, 2)
					task.delay(1, function()
						if instance and instance.Parent ~= nil and attachment then
							clone.Enabled = false
							clone2.Enabled = false
						end
					end)

					if not v2[v3] then
						count += 1
					end
				end
			end
		end)

		if not success then
			warn(result)
		end
	end

	local playerFromCharacter = AchievementGiver and count >= 3 and not v2[instance] and instance:GetAttribute("MaskToon") == nil and Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		task.spawn(function()
			AchievementGiver:CompleteAchievementOneOff(playerFromCharacter, "ID_48_Bedtime")
		end)
	end

	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v4 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v4)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

local nows = {}
Astro.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Astro.Ability1Name .. " (%d sec)",
		Action = function(p, folder, p2)
			if not (p and folder) then
				return
			end

			local animations = folder:WaitForChild("Animations")
			local humanoid = folder:WaitForChild("Humanoid")
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

				if folder and folder.Parent ~= nil then
					local astroPoof = ReplicatedStorage.Parts.RenderModules.AstroPoof

					for _, emitter in pairs(folder:GetDescendants()) do
						if not (emitter:IsA("ParticleEmitter") and emitter.Parent:IsA("Attachment")) then
							continue
						end

						emitter.Enabled = true
						local v2 = emitter
						task.delay(1.4, function()
							if v2 and v2.Parent then
								v2.Enabled = false
							end
						end)
					end

					ReplicatedStorage.Events.RenderObject:FireAllClients(astroPoof, { folder })
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
return Astro