local Squirm = {
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1.5,
	SkillCheckChance = 30,
	SkillCheckValue = 2,
	Stealth = 5,
	Stamina = 125,
	BoundarySize = 150,
	Name = "Squirm",
	Icon = "rbxassetid://0",
	VoteIcon = "rbxassetid://0",
	DecodeRank = 5,
	SpeedRank = 3,
	StaminaRank = 2,
	StealthRank = 2,
	SkillCheckRank = 3,
	Ability1Name = "Bookworm Feast",
	Ability1Type = "Active",
	Ability1Description = "Hold to consume forbidden knowledge, gaining 100% bonus Extraction Speed for 10 seconds. Close proximity to a bookshelf makes this Toon's cooldown recover twice as fast.",
	HoldProximityAbility = true,
	SelfTargetedAbility = true,
	PlayerRadius = 0,
	ActiveAbility = true,
	PlayerAbility = false,
	AbilityIcon = "rbxassetid://0",
	AbilityCooldown = 80,
	AbilityDuration = 10,
	HoldDuration = 4,
	HoldMovementSlowMultiplier = 0.5,
	AbilityStartAnimationId = "rbxassetid://103929085331673",
	AbilityLoopAnimationId = "rbxassetid://126404363103447",
	AbilityEndAnimationId = "rbxassetid://131063198435963",
	BookshelfProximityRange = 10,
	BookshelfCooldownMultiplier = 2,
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
	end
}

function Squirm.SpecialSetup(parent)
	parent:SetAttribute("HasHoldProximityAbility", true)
	parent:SetAttribute("SelfTargetedHoldAbility", true)
	local abilities = parent:FindFirstChild("Abilities")

	if not abilities then
		warn("[Squirm] No Abilities folder found")
		return
	end

	if not abilities:FindFirstChild("Ability1") then
		warn("[Squirm] No Ability1 found")
		return
	end

	local parent2 = parent:FindFirstChild("Animations")

	if not parent2 then
		parent2 = Instance.new("Folder")
		parent2.Name = "Animations"
		parent2.Parent = parent
	end

	local v2 = {
		{
			name = "AbilityHold",
			id = Squirm.AbilityLoopAnimationId
		},
		{
			name = "Ability",
			id = Squirm.AbilityEndAnimationId
		},
		{
			name = "AbilityStart",
			id = Squirm.AbilityStartAnimationId
		}
	}

	for i, v3 in ipairs(v2) do
		local v4 = parent2:FindFirstChild(v3.name)

		if not v4 then
			v4 = Instance.new("Animation")
			v4.Name = v3.name
			v4.Parent = parent2
		end

		v4.AnimationId = v3.id
	end

	local success, result = pcall(function()
		return require(game.ReplicatedStorage.CharacterModules.SquirmAbility)
	end)

	if success and result then
		result.Initialize(parent)
	else
		warn("[Squirm] Failed to load SquirmAbility module")
	end
end

function Squirm.UseActiveAbility(p, instance, p2, p3)
	_ = p2
	_ = p3
	print("[Squirm.UseActiveAbility] Called for player:", p.Name)
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
		print("[Squirm.UseActiveAbility] BLOCKED: On cooldown:", currentCooldown.Value)
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if not workspace.CurrentRoom:FindFirstChildOfClass("Model") then
		print("[Squirm.UseActiveAbility] BLOCKED: No room (in elevator)")
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if workspace.Info.FloorActive.Value ~= true then
		print("[Squirm.UseActiveAbility] BLOCKED: Floor not active")
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if decoding and decoding.Value ~= nil then
		print("[Squirm.UseActiveAbility] BLOCKED: Currently decoding")
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
		print("[Squirm.UseActiveAbility] BLOCKED: Already channeling")
		return {
			Outcome = false,
			Reason = "Already channeling!"
		}
	end

	local v, reason = result.StartChannel(instance, p)

	if v then
		print("[Squirm.UseActiveAbility] Channel started successfully")
		return {
			Outcome = "PromptCreated",
			Reason = "Channeling ability..."
		}
	end

	print("[Squirm.UseActiveAbility] Channel failed:", reason)

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

return Squirm