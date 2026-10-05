local Blott = {
	Name = "Blot",
	Icon = "rbxassetid://104323857339769",
	VoteIcon = "rbxassetid://71130058273198",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 1,
	Stealth = 10,
	Stamina = 200,
	BoundarySize = 50,
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 5,
	StealthRank = 3,
	SkillCheckRank = 1,
	Ability1Name = "Blot Jr.",
	Ability1Type = "Active",
	Ability1Description = "This Toon places a decoy that attracts nearby Twisteds and has 1 Heart. This ability costs 10 Tapes and has a cooldown of 60 seconds. For each extra Blot on a team, the cost of the decoy costs an additional 10 tapes.",
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://98054898811255",
	AbilityCooldown = 60,
	AbilityDuration = 10,
	AbilityRange = 0,
	CustomAbilitySound = "rbxassetid://123425709463166",
	BaseCost = 10,
	AbilityCost = 10,
	Cost = 3000,
	Requirement1 = { "Coin", 3000 },
	Requirement2 = { "Mastery", 50, "Looey" },
	Requirement3 = { "Mastery", 100, "Yatta" },
	MasterySkin = "VintageBlott",
	MasteryRequirements = {
		{
			Name = "SurviveFloor",
			Requirement = 30
		},
		{
			Name = "SurviveFloorWithToon",
			Requirement = 10,
			Tower = { "Looey", "Yatta" }
		},
		{
			Name = "ActiveAbilityActivate",
			Requirement = 40
		},
		{
			Name = "PickUpCapsule",
			Requirement = 100
		},
		{
			Name = "UseItem",
			Requirement = 100
		},
		{
			Name = "TravelDistance",
			Requirement = 120000
		}
	},
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
	end
}

function Blott.SpecialSetup(parent)
	parent:SetAttribute("IchorPuddleImmune", true)
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local BlottAbility = require(ReplicatedStorage.CharacterModules.BlottAbility)
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
	local v = BlottAbility.Init(parent)
	local clientAbilityEvent = ReplicatedStorage.Events:FindFirstChild("ClientAbilityEvent")

	if clientAbilityEvent then
		clientAbilityEvent.OnServerEvent:Connect(function(p, p2, p3)
			if not (p == playerFromCharacter and p2 == "BlottDecoy") then
				return
			end

			local v2, v3 = BlottAbility.UseDecoyAbility(parent, v, p3, Blott.AbilityDuration)
			v = v2
			_ = v3
		end)
	end

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = "BlottDecoyBindable"
	bindableEvent.Parent = parent
	bindableEvent.Event:Connect(function()
		local v2, v3 = BlottAbility.UseDecoyAbility(parent, v, nil, Blott.AbilityDuration)
		v = v2
		_ = v3
	end)
	parent.AncestryChanged:Connect(function(p, parent2)
		if parent2 == nil then
			BlottAbility.DestroyActiveDecoy(parent, v)
		end
	end)
	parent:WaitForChild("Humanoid").HealthChanged:Connect(function(currentHealth)
		local v2 = currentHealth - v.currentHealth
		v.currentHealth = currentHealth

		if v2 < 0 and v.activeDecoy == nil then
			local v3 = tick() - v.lastDecoyTime > 5
		end
	end)
	local ability1 = parent:WaitForChild("Abilities"):WaitForChild("Ability1")

	if not ability1:FindFirstChild("AbilityCost") then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "AbilityCost"
		numberValue.Value = Blott.AbilityCost
		numberValue.Parent = ability1
	end

	local tapeCost = BlottAbility.GetTapeCost()
	local abilityCost = ability1:FindFirstChild("AbilityCost")

	if abilityCost then
		abilityCost.Value = tapeCost
	end

	task.spawn(function()
		while parent and parent.Parent do
			local tapeCost2 = BlottAbility.GetTapeCost()
			local abilityCost2 = ability1:FindFirstChild("AbilityCost")

			if abilityCost2 and abilityCost2.Value ~= tapeCost2 then
				abilityCost2.Value = tapeCost2
				Blott.AbilityCost = tapeCost2
			end

			task.wait(2)
		end
	end)
end

function Blott.ActivateAbility(instance)
	local blottDecoyBindable = instance:FindFirstChild("BlottDecoyBindable")

	if not blottDecoyBindable then
		return false
	end

	blottDecoyBindable:Fire()
	return true
end

function Blott.AbilityButton(p)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local clientAbilityEvent = ReplicatedStorage.Events:FindFirstChild("ClientAbilityEvent")

	if not clientAbilityEvent then
		return false
	end

	clientAbilityEvent:FireServer("BlottDecoy")
	return true
end

function Blott.SpecialSetupClient(p) end

function Blott.UseActiveAbility(p, parent, p2, p3)
	parent:WaitForChild("Config")
	local ability1 = parent:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	parent:WaitForChild("Stats")
	local decoding = parent:WaitForChild("Decoding")
	local survivalPoints = workspace.Info.PlayerStats:FindFirstChild(parent.Name):WaitForChild("SurvivalPoints")

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

	if decoding.Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	local inElevator = parent:WaitForChild("Stats"):WaitForChild("InElevator")

	if inElevator.Value == true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if p3 then
		return {
			Outcome = false,
			Reason = "This ability doesn't target other players!"
		}
	end

	local BlottAbility = require(game.ReplicatedStorage.CharacterModules.BlottAbility)
	local abilityCost = ability1:WaitForChild("AbilityCost")

	if survivalPoints.Value < abilityCost.Value then
		return {
			Outcome = false,
			Reason = "Not enough tapes! Need " .. abilityCost.Value .. " tapes."
		}
	end

	if inElevator.Value == true then
		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	end

	local function checkPlayerInElevator(parent2, elevatorHitBox)
		local partsInPart = workspace:GetPartsInPart(elevatorHitBox)

		for i, v in ipairs(partsInPart) do
			if v.Name == "HumanoidRootPart" and v.Parent:FindFirstChild("Humanoid") and v.Parent == parent2 then
				return true
			end
		end

		return false
	end

	if checkPlayerInElevator(
		parent,
		workspace:WaitForChild("Elevators"):WaitForChild("Elevator"):WaitForChild("ElevatorHitBox")
	) then
		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	end

	parent:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation((parent:WaitForChild("Animations"):WaitForChild("Ability"))):Play()
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "DecoyAbilityActive"
	boolValue.Parent = parent
	task.spawn(function()
		game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(p, true)
	end)
	local v = false
	local v2

	if parent:FindFirstChild("BlottAbilityStats") then
		v2 = {
			lastDecoyTime = 0,
			activeDecoy = nil,
			currentHealth = parent.Humanoid.Health,
			abilityEnabled = true
		}
	else
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "BlottAbilityStats"
		objectValue.Parent = parent
		v2 = BlottAbility.Init(parent)
		parent:SetAttribute("BlottStatsInitialized", true)
	end

	local success, result = pcall(function()
		if survivalPoints.Value >= abilityCost.Value then
			survivalPoints.Value -= abilityCost.Value

			if survivalPoints.Value <= 0 then
				survivalPoints.Value = 0
			end
		end

		print("[Blott.lua Debug] Attempting to create decoy for character: ", parent.Name)
		local decoy = BlottAbility.CreateDecoy(parent, nil, Blott.AbilityDuration)
		print("[Blott.lua Debug] BlottAbility.CreateDecoy returned: ", decoy)

		if not decoy then
			return nil
		end

		print("[Blott.lua Debug] Decoy successfully created by BlottAbility.CreateDecoy: ", decoy:GetFullName())
		v2.lastDecoyTime = tick()
		v2.activeDecoy = decoy
		currentCooldown.Value = cooldown.Value
		task.spawn(function()
			local lastTime = os.clock()

			while parent and parent.Parent do
				currentCooldown.Value -= 0.1

				if currentCooldown.Value <= 0 then
					currentCooldown.Value = 0
					break
				else
					local v4 = 0.1 - (os.clock() - lastTime) % 0.1
					task.wait((math.max(0.01, v4)))
				end
			end
		end)

		if Blott.CustomAbilitySound then
			for k, v3 in pairs(game.Players:GetPlayers()) do

			end
		end

		local attachment = Instance.new("Attachment")
		attachment.Parent = parent.HumanoidRootPart
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
		particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(
				1,
				0
			) })
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Rate = 10
		particleEmitter.Lifetime = NumberRange.new(0.5, 1)
		particleEmitter.SpreadAngle = Vector2.new(30, 30)
		particleEmitter.Enabled = true
		particleEmitter.Parent = attachment
		particleEmitter:Emit(15)
		task.delay(1, function()
			particleEmitter.Enabled = false
		end)
		game.Debris:AddItem(attachment, 2)
		task.spawn(function()
			task.wait(Blott.AbilityDuration)

			if parent and parent.Parent and parent:FindFirstChild("DecoyAbilityActive") then
				parent.DecoyAbilityActive:Destroy()
			end

			game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(p, false)
		end)
		v = true
		return decoy
	end)

	if success and result then
		return {
			Outcome = true,
			Reason = "Created a decoy to distract the monster!"
		}
	end

	if parent:FindFirstChild("DecoyAbilityActive") then
		parent.DecoyAbilityActive:Destroy()
	end

	print("[Blott.lua Debug] Decoy creation pcall failed or result was nil. Error: ", result)
	task.spawn(function()
		game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(p, false)
	end)
	return {
		Outcome = false,
		Reason = "Failed to create decoy: " .. tostring(result)
	}
end

return Blott