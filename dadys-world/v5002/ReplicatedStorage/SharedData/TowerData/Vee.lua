local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local Vee = {
	Name = "Vee",
	Icon = "rbxassetid://17288109998",
	VoteIcon = "rbxassetid://17288110108",
	Render = "rbxassetid://116285875143433",
	Health = 2,
	MainCharacter = true,
	WalkSpeed = 12.5,
	RunSpeed = 22.5,
	DecodeSpeed = 1.5,
	SkillCheckChance = 25,
	SkillCheckValue = 2.5,
	Stealth = 5,
	Stamina = 150,
	BoundarySize = 200,
	LightToon = true,
	DecodeRank = 5,
	SpeedRank = 2,
	StaminaRank = 3,
	StealthRank = 2,
	SkillCheckRank = 4,
	Ability1Name = "Mic Check",
	Ability1Type = "Active",
	Ability1Description = "This Toon can highlight all Twisteds and Machines on the Floor for 5 seconds. Has a Cooldown of 50.",
	Ability2Name = "Camera Hijack",
	Ability2Type = "Passive",
	Ability2Description = "This Toon will have the nearest 2 uncompleted Machines highlighted for them.",
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://17701202860",
	AbilityCooldown = 50,
	CustomAbilitySound = {
		SoundId = "rbxassetid://9125613060",
		PlaybackSpeed = 1,
		Volume = 0.4
	},
	Cost = 4500,
	Requirement1 = { "Coin", 4500 },
	Requirement2 = { "Research", 100, "VeeMonster" },
	Requirement3 = { "Mastery", 100, "Brightney" },
	MasterySkin = "VintageVee",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 150
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
			Name = "BlackOut",
			Requirement = 12
		},
		{
			Name = "CompleteGenerator",
			Requirement = 150
		},
		{
			Name = "EncounterMonster",
			Requirement = 75
		}
	},
	RightHandBone = "R_hand",
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
	end,
	ClientAbility = function(p, character, p2)
		if not (character and character.PrimaryPart) then
			return
		end

		local decay = p2 and 5 or 1
		local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

		if model then
			local generators = model:FindFirstChild("Generators")

			if not generators then
				return
			end

			local children = generators:GetChildren()
			local v2 = {}
			local v3 = {}

			for _, v4 in pairs(children) do
				if not (v4:GetChildren()[1] and v4.PrimaryPart) then
					continue
				end

				local stats = v4:FindFirstChild("Stats")
				local completed = stats and stats:FindFirstChild("Completed")

				if not (completed and completed.Value ~= true) then
					continue
				end

				local magnitude = (character.PrimaryPart.Position - v4.PrimaryPart.Position).Magnitude
				table.insert(v2, v4)
				table.insert(v3, magnitude)
			end

			for i = 1, #v3 do
				for i2 = i + 1, #v3 do
					if not (v3[i] > v3[i2]) then
						continue
					end

					local v4 = v3[i2]
					local v5 = v3[i]
					v3[i] = v4
					v3[i2] = v5
					local v6 = v2[i2]
					local v7 = v2[i]
					v2[i] = v6
					v2[i2] = v7
				end
			end

			local Players = game:GetService("Players")
			local LOCAL_ABILITY = Players:GetPlayerFromCharacter(character) == p and HighlightController.Priority.LOCAL_ABILITY or HighlightController.Priority.REMOTE_ABILITY

			for i = 1, math.min(p2 and 999 or 2, #v2) do
				local v4 = v2[i]

				if not v4 then
					continue
				end

				local stats = v4:FindFirstChild("Stats")

				if not stats then
					continue
				end

				local activePlayer = stats:FindFirstChild("ActivePlayer")
				local color = activePlayer.Value ~= nil and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(
					100,
					255,
					97
				)
				HighlightController:PlayHighlight(v4, "Machine", {
					FillColor = color,
					FillTransparency = 1,
					OutlineColor = color,
					OutlineTransparency = 0,
					ForceColor = activePlayer.Value ~= nil,
					Decay = decay,
					Billboard = {
						Label = "MACHINE",
						Size = UDim2.new(16, 0, 16, 0),
						Adornee = v4:FindFirstChild("GuiAttachPoint") or v4.PrimaryPart
					},
					Priority = LOCAL_ABILITY
				})
				task.wait()
			end
		end
	end,
	UseActiveAbility = function(origin, instance, _)
		instance:WaitForChild("Config")
		local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
		local cooldown = ability1:WaitForChild("Cooldown")
		local currentCooldown = ability1:WaitForChild("CurrentCooldown")
		local stats = instance:WaitForChild("Stats")
		stats:WaitForChild("WalkSpeed")
		stats:WaitForChild("RunSpeed")
		instance:WaitForChild("Humanoid")

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

		currentCooldown.Value = cooldown.Value
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
		task.spawn(function()
			game.ReplicatedStorage.Events.ClientAbilityEvent:FireAllClients(script, instance, true)
			local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

			if model then
				local children = model:WaitForChild("Monsters"):GetChildren()

				for _, v in pairs(children) do
					if not v:GetChildren()[1] or (string.find(v.Name, "Rodger") or v:GetAttribute("GigiHoardProp")) then
						continue
					end

					HighlightController:BroadcastHighlight(v, "Threat", {
						FillColor = Color3.fromRGB(100, 255, 97),
						FillTransparency = 1,
						OutlineColor = Color3.fromRGB(100, 255, 97),
						OutlineTransparency = 0,
						Decay = 5,
						Origin = origin,
						Billboard = {
							Label = "TWISTED",
							Size = UDim2.new(16, 0, 16, 0),
							ExtentsOffset = v.Name == "AstroMonster" and createVector(0, 0.5, 0) or createVector(
								0,
								1.5,
								0
							)
						}
					})
					task.wait()
				end
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
}
local nows = {}
Vee.PlayFunctions = {
	RPAbility = {
		Cooldown = 10,
		DisplayName = Vee.Ability1Name .. " (%d sec)",
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
return Vee