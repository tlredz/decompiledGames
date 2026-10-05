local nows = {}
local Squirm = {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1.5,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 5,
	Stamina = 125,
	BoundarySize = 150,
	Cost = 3000,
	Requirement1 = { "Coin", 3000 },
	Requirement2 = { "Research", 50, "SquirmMonster" },
	Requirement3 = { "NumberOfTitles", 3 },
	MasterySkin = "VintageSquirm",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 100
		},
		{
			Name = "SurviveFloor",
			Requirement = 30
		},
		{
			Name = "TravelDistance",
			Requirement = 60000
		},
		{
			Name = "EatBookshelfOnCooldown",
			Requirement = 100,
			DisplayText = "Eat from %d Bookshelves!"
		},
		{
			Name = "SurviveFloorWithToon",
			Requirement = 5,
			Tower = { "Brightney" }
		},
		{
			Name = "CompleteGenerator",
			Requirement = 100
		}
	},
	Name = "Squirm",
	Icon = "rbxassetid://126346931597430",
	Render = "rbxassetid://133102229631608",
	VoteIcon = "rbxassetid://130260118575612",
	DecodeRank = 5,
	SpeedRank = 3,
	StaminaRank = 2,
	StealthRank = 2,
	SkillCheckRank = 3,
	Ability1Name = "Distressed Delicacy",
	Ability1Type = "Active",
	Ability1Description = "Hold down your ability to eat books, gaining 100% extraction speed for 10 seconds. Proximity to a bookshelf makes this Toon's cooldown recover twice as fast. Cooldown of 80.",
	HoldProximityAbility = true,
	SelfTargetedAbility = true,
	PlayerRadius = 0,
	ActiveAbility = true,
	PlayerAbility = false,
	AbilityIcon = "rbxassetid://102564001253666",
	AbilityCooldown = 80,
	AbilityDuration = 10,
	HoldDuration = 4,
	HoldMovementSlowMultiplier = 0.5,
	BookshelfProximityRange = 10,
	BookshelfCooldownMultiplier = 2,
	RightHandBone = "R_hand_jnt",
	HurtAnimation = function(instance)
		local config = instance:FindFirstChild("Config")

		if not config then
			return
		end

		local hurtTexture = config:FindFirstChild("HurtTexture")
		local normalTexture = config:FindFirstChild("NormalTexture")

		if not (hurtTexture and normalTexture) then
			return
		end

		local head = instance:FindFirstChild("Head")

		if not head then
			return
		end

		head.TextureID = hurtTexture.Texture
		local head2 = head:FindFirstChild("Head")

		if head2 then
			head2.TextureID = hurtTexture.Texture
		end

		task.wait(2)

		if instance.Parent ~= nil and head.Parent then
			head.TextureID = normalTexture.Texture

			if head2 and head2.Parent then
				head2.TextureID = normalTexture.Texture
			end
		end
	end,
	SpecialSetup = function(instance)
		instance:SetAttribute("HasHoldProximityAbility", true)
		instance:SetAttribute("SelfTargetedHoldAbility", true)
		local abilities = instance:FindFirstChild("Abilities")

		if not abilities then
			warn("[Squirm] No Abilities folder found")
			return
		end

		if not abilities:FindFirstChild("Ability1") then
			warn("[Squirm] No Ability1 found")
			return
		end

		local success, result = pcall(function()
			return require(game.ReplicatedStorage.CharacterModules.SquirmAbility)
		end)

		if success and result then
			result.Initialize(instance)
		else
			warn("[Squirm] Failed to load SquirmAbility module")
		end
	end,
	UseActiveAbility = function(p, instance, p2, p3)
		_ = p2
		_ = p3
		local decoding = instance:FindFirstChild("Decoding")
		local abilities = instance:FindFirstChild("Abilities")

		if not abilities then
			return {
				Outcome = false,
				Reason = "No abilities"
			}
		end

		local ability1 = abilities:FindFirstChild("Ability1")

		if not ability1 then
			return {
				Outcome = false,
				Reason = "No ability"
			}
		end

		local currentCooldown = ability1:FindFirstChild("CurrentCooldown")

		if not currentCooldown then
			return {
				Outcome = false,
				Reason = "No cooldown tracking"
			}
		end

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

		if decoding and decoding.Value ~= nil then
			return {
				Outcome = false,
				Reason = "Can't use that Ability while extracting!"
			}
		end

		local success, result = pcall(function()
			return require(game.ReplicatedStorage.CharacterModules.SquirmAbility)
		end)

		if not (success and result) then
			warn("[Squirm.UseActiveAbility] Failed to load SquirmAbility module")
			return {
				Outcome = false,
				Reason = "Ability error!"
			}
		end

		if result.IsChanneling(instance) then
			return {
				Outcome = false,
				Reason = "Already channeling!"
			}
		end

		local v, reason = result.StartChannel(instance, p)

		if v then
			return {
				Outcome = "PromptCreated",
				Reason = "Channeling ability..."
			}
		end

		if reason then
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
}
Squirm.PlayFunctions = {
	RPAbility = {
		Cooldown = 10,
		DisplayName = Squirm.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			local ability_start = animations:WaitForChild("Ability_start")
			local ability_idle = animations:WaitForChild("Ability_idle")
			local ability_end = animations:WaitForChild("Ability_end")
			local track = humanoid:LoadAnimation(ability_start)
			local track2 = humanoid:LoadAnimation(ability_idle)
			local track3 = humanoid:LoadAnimation(ability_end)

			local function dothing()
				for k, v in pairs(humanoid:GetPlayingAnimationTracks()) do
					if not v.Name:find("Ability") then
						continue
					end

					v:Stop()
					v:Destroy()
				end

				track:Play()
				task.delay(1, function()
					track2:Play()
					task.wait(1)
					track3:Play()
					track2:Stop(0.5)
				end)
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
return Squirm