local createVector = vector.create
local Flyte = {
	Name = "Flyte",
	VoteIcon = "rbxassetid://131927598636700",
	Icon = "rbxassetid://82095952372356",
	Render = "rbxassetid://116436929929803",
	DecodeRank = 4,
	SpeedRank = 4,
	StaminaRank = 2,
	StealthRank = 3,
	SkillCheckRank = 2,
	HealthRank = 3,
	Ability1Name = "Gust",
	Ability1Type = "Active",
	Ability1Description = "This Toon places a 'Gust' at Flyte's location that lasts for 10 seconds. Any Toon that walks into the Gust receives a 15% Movement Speed boost while in the Gust and for 3 seconds after leaving. Has a cooldown of 50 seconds.",
	HolidayToon = true,
	HolidayTower = true,
	Easter = true,
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 1.2,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 10,
	Stamina = 125,
	BoundarySize = 100,
	Cost = 1300,
	Requirement1 = { "Baskets", 700 },
	Requirement2 = { "Research", 50, "FlyteMonster" },
	MasterySkin = "VintageFlyte",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 85
		},
		{
			Name = "SurviveFloor",
			Requirement = 45
		},
		{
			Name = "CompleteGenerator",
			Requirement = 60
		},
		{
			Name = "ReachFloor",
			Requirement = 1,
			Number = 12
		},
		{
			Name = "SurviveFloorWithToon",
			Requirement = 5,
			Tower = "Flutter"
		},
		{
			Name = "TravelDistance",
			Requirement = 90000
		}
	},
	Rarity = "Uncommon"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
game:GetService("ServerStorage")
local ActionEvent = RunService:IsServer() and require(ReplicatedStorage.SharedUtils.ActionEvent)
Flyte.ActiveAbility = true
Flyte.AbilityIcon = "rbxassetid://89936564179654"
Flyte.AbilityCooldown = 50
Flyte.AbilityDuration = 10
Flyte.AbilityRange = 20
Flyte.BoostDuration = 3
Flyte.BoostMultiplier = 1.15
Flyte.CustomAbilitySound = "rbxassetid://5272402910"

function Flyte.SpecialSetup(instance)
	task.spawn(function()
		local rootPart = instance:WaitForChild("RootPart", 5)
		local rootPartRoot = rootPart and rootPart:WaitForChild("root", 5)
		local torso = rootPartRoot and rootPartRoot:WaitForChild("torso", 5)
		local chest = torso and torso:WaitForChild("chest", 5)
		local head = chest and chest:WaitForChild("head", 5)

		if not head then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.CFrame = CFrame.new(-1.8, -0.8, -0.3) * CFrame.Angles(0, -1.7453292519943295, 0) * CFrame.Angles(
			0.7853981633974483,
			0,
			0
		) * CFrame.Angles(0, 3.141592653589793, 0)
		attachment.Name = "LatchedAttachment"
		attachment.Parent = head
	end)
end

function Flyte.HurtAnimation(instance)
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

local v = nil

local function getZoneManager()
	if v then
		return v
	end

	print("[Flyte] DEBUG: Loading ZoneModifierManager")
	local ZoneModifierManager = require(ServerScriptService:WaitForChild("ZoneModifierManager"))
	v = ZoneModifierManager

	if v then
		print("[Flyte] DEBUG: ZoneModifierManager loaded successfully")
	else
		warn("[Flyte] ERROR: Failed to load ZoneModifierManager")
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerZoneID(p)
	return "FlyteGust_" .. p.UserId
end

local v2 = {}
local v3 = {}
local v4 = {}

local function destroyVisuals(visuals)
	if not visuals then
		return
	end

	for _, v5 in ipairs(visuals) do
		local v6 = v5
		pcall(function()
			if v6 and v6.Parent then
				v6:Destroy()
			end
		end)
	end
end

local function removeGustBoost(p, character, p2)
	if v3[p] and v3[p][p2] then
		local v5 = v3[p][p2]

		if v5.graceTimer then
			pcall(task.cancel, v5.graceTimer)
			v5.graceTimer = nil
		end

		v3[p][p2] = nil

		if next(v3[p]) == nil then
			v3[p] = nil
		end
	end

	if not (v4[p] and v4[p].activeZones[p2]) then
		return
	end

	local activeZone = v4[p].activeZones[p2]

	if character and character.Parent and activeZone.modifierIds then
		local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
		StatModifierManager.RemoveSpeedModifiers(character, activeZone.modifierIds)
	end

	destroyVisuals(activeZone.visuals)
	v4[p].activeZones[p2] = nil

	if next(v4[p].activeZones) == nil then
		v4[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelGracePeriod(p, p2)
	local v5 = v3[p] and v3[p][p2]

	if v5 and v5.graceTimer then
		pcall(task.cancel, v5.graceTimer)
		v5.graceTimer = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginGracePeriod(player, character, p)
	local v5 = v3[player] and v3[player][p]

	if not v5 or v5.graceTimer then
		return
	end

	v5.graceTimer = task.delay(Flyte.BoostDuration, function()
		local character2 = player and player.Character or character
		removeGustBoost(player, character2, p)
	end)
end

local function applyGustBoost(p, character, playerZoneID, sourcePlayer)
	if ActionEvent then
		ActionEvent:Record(p, "ReceiveActiveAbility", Flyte.Name, sourcePlayer.UserId)
	end

	if v3[p] and v3[p][playerZoneID] then
		cancelGracePeriod(p, playerZoneID) -- equivalent call inferred; original call site unknown
		return true
	else
		v3[p] = v3[p] or {}
		v3[p][playerZoneID] = {
			sourcePlayer = sourcePlayer,
			graceTimer = nil
		}
		v4[p] = v4[p] or {
			activeZones = {}
		}
		local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
		local modifierIds = StatModifierManager.ApplySpeedModifiers(
			character,
			Flyte.BoostMultiplier,
			"FlyteGust_" .. playerZoneID,
			{
				category = "ability",
				antiCheat = true
			}
		)
		local visuals = {}
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			table.insert(visuals, attachment)
			local speed = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild("BuffParticles") and ReplicatedStorage.Parts.BuffParticles:FindFirstChild("Speed")

			if speed then
				local clone = speed.BuffParticle:Clone()
				clone.Parent = attachment
				clone.Enabled = true
				local clone2 = speed.Glow:Clone()
				clone2.Parent = attachment
				clone2.Enabled = true
			else
				local trail = Instance.new("Trail")
				trail.Attachment0 = attachment
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "BuffTrailEnd"
				attachment2.Position = createVector(0, 0, -2)
				attachment2.Parent = humanoidRootPart
				trail.Attachment1 = attachment2
				trail.Color = ColorSequence.new(Color3.fromRGB(200, 235, 255))
				trail.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1)
				})
				trail.Lifetime = 0.5
				trail.WidthScale = NumberSequence.new(1, 0)
				trail.Parent = humanoidRootPart
				table.insert(visuals, trail)
				table.insert(visuals, attachment2)
			end

			local v7 = Flyte.AbilityDuration + Flyte.BoostDuration + 1

			for _, v8 in ipairs(visuals) do
				Debris:AddItem(v8, v7)
			end
		end

		v4[p].activeZones[playerZoneID] = {
			modifierIds = modifierIds,
			visuals = visuals
		}
		return true
	end
end

local function onPlayerExitedZone(player, _, p)
	if v2[player] and v2[player][p] then
		v2[player][p] = nil

		if next(v2[player]) == nil then
			v2[player] = nil
		end
	end

	local character = player and player.Character

	if character then
		local v5 = v3[player] and v3[player][p]

		if not v5 then
			return
		end

		if v5.graceTimer then
			return
		else
			v5.graceTimer = task.delay(Flyte.BoostDuration, function()
				local character2 = player and player.Character or character
				removeGustBoost(player, character2, p)
			end)
		end
	end
end

function Flyte.UseActiveAbility(p, instance, _)
	print("[Flyte] DEBUG: UseActiveAbility called for", p.Name)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local decoding = instance:WaitForChild("Decoding")

	if currentCooldown.Value > 0 then
		print("[Flyte] DEBUG: Ability on cooldown for", p.Name)
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if workspace.Info.FloorActive.Value ~= true then
		print("[Flyte] DEBUG: Floor not active for", p.Name)
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	if decoding.Value ~= nil then
		print("[Flyte] DEBUG: Player is extracting:", p.Name)
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	print("[Flyte] DEBUG: Setting ability on cooldown for", p.Name)
	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		local position = humanoidRootPart.Position
		local vector2 = Vector3.new(Flyte.AbilityRange, 1, Flyte.AbilityRange)
		print("[Flyte] DEBUG: Creating gust zone at position", position, "with size", vector2)
		print("[Flyte] DEBUG: Firing animation event for", p.Name)
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
		local playerZoneID = getPlayerZoneID(p) -- equivalent call inferred; original call site unknown
		print("[Flyte] DEBUG: Generated zone ID:", playerZoneID)
		local zoneManager = getZoneManager()

		if not zoneManager then
			warn("[Flyte] ERROR: ZoneManager not found")
			return
		end

		print("[Flyte] DEBUG: Checking for existing zone type:", playerZoneID)

		if not zoneManager.GetZoneType(playerZoneID) then
			print("[Flyte] DEBUG: Defining new zone type:", playerZoneID)
			zoneManager.DefineZoneType(playerZoneID, {
				stats = {},
				targetType = "All",
				boostDuration = Flyte.BoostDuration,
				affectedPlayers = {}
			})
		end

		print("[Flyte] DEBUG: Creating zone part")
		local zone = zoneManager.CreateZone(playerZoneID, position, vector2)

		if not zone then
			warn("[Flyte] ERROR: Failed to create gust zone")
			return
		end

		print("[Flyte] DEBUG: Zone created successfully:", zone:GetFullName())

		if not v2[p] then
			v2[p] = {}
		end

		v2[p][playerZoneID] = zone

		if zone then
			print("[Flyte] DEBUG: Customizing zone appearance")
			zone.Color = Color3.fromRGB(200, 235, 255)
			zone.Material = Enum.Material.SmoothPlastic
			zone.Transparency = 1
			local gustFX = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild("GustFX")

			if gustFX then
				print("[Flyte] DEBUG: Found GustFX, applying to zone")
				local clone = gustFX:Clone()
				clone.Parent = zone
				clone.CFrame = zone.CFrame

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				print("[Flyte] DEBUG: GustFX applied successfully")
			else
				print("[Flyte] DEBUG: GustFX not found, using fallback effect")
				local attachment = Instance.new("Attachment")
				attachment.Parent = zone
				local particleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Texture = "rbxassetid://6101261905"
				particleEmitter.Color = ColorSequence.new(Color3.fromRGB(220, 240, 255))
				particleEmitter.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(0.5, 0.6),
					NumberSequenceKeypoint.new(1, 1)
				})
				particleEmitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 2),
					NumberSequenceKeypoint.new(1, 5)
				})
				particleEmitter.Acceleration = createVector(0, 1, 0)
				particleEmitter.Lifetime = NumberRange.new(1, 2)
				particleEmitter.Rate = 50
				particleEmitter.Speed = NumberRange.new(10, 15)
				particleEmitter.SpreadAngle = Vector2.new(180, 180)
				particleEmitter.Parent = attachment
				Debris:AddItem(attachment, Flyte.AbilityDuration)
			end

			print("[Flyte] DEBUG: Zone customization complete")
		end

		print("[Flyte] DEBUG: Setting up manual zone detection")
		local v5 = {}
		local heartbeatConnection = nil
		local RunService2 = game:GetService("RunService")
		heartbeatConnection = RunService2.Heartbeat:Connect(function()
			if not (zone and zone.Parent) then
				heartbeatConnection:Disconnect()
				return
			end

			if tick() % 0.3 > 0.05 then
				return
			end

			for _, v6 in pairs(Players:GetPlayers()) do
				local character = v6.Character

				if not (character and character:FindFirstChild("HumanoidRootPart")) then
					continue
				end

				local v7 = (character.HumanoidRootPart.Position - zone.Position).Magnitude <= zone.Size.X / 2

				if v7 and not v5[v6] then
					v5[v6] = true
					print("[Flyte] DEBUG: Player entered zone manually detected:", v6.Name)
					local character2 = v6.Character

					if character2 then
						applyGustBoost(v6, character2, playerZoneID, p)
					end
				end

				if v7 or not v5[v6] then
					continue
				end

				v5[v6] = nil
				print("[Flyte] DEBUG: Player exited zone, starting grace:", v6.Name)
				local character2 = v6.Character

				if character2 then
					local v8 = playerZoneID
					local v9 = v3[v6] and v3[v6][v8]

					if v9 and not v9.graceTimer then
						local v10 = v6
						local character4 = character2
						local v12 = v8
						v9.graceTimer = task.delay(Flyte.BoostDuration, function()
							local character3 = v10 and v10.Character or character4
							removeGustBoost(v10, character3, v12)
						end)
					end
				end

				if not v2[v6] then
					continue
				end

				v2[v6][playerZoneID] = nil

				if next(v2[v6]) == nil then
					v2[v6] = nil
				end
			end
		end)
		print("[Flyte] DEBUG: Scheduling zone removal in", Flyte.AbilityDuration, "seconds")
		task.delay(Flyte.AbilityDuration, function()
			print("[Flyte] DEBUG: Removing gust zone")

			if heartbeatConnection then
				print("[Flyte] DEBUG: Disconnecting zone check connection")
				heartbeatConnection:Disconnect()
			end

			for player, _ in pairs(v5) do
				if not (typeof(player) == "Instance" and player:IsA("Player") and player.Character) then
					continue
				end

				beginGracePeriod(player, player.Character, playerZoneID) -- equivalent call inferred; original call site unknown
			end

			if zone and zone.Parent then
				zone:Destroy()
			end

			local zoneManager2 = getZoneManager()

			if zoneManager2 then
				local success, result = pcall(function()
					return zoneManager2.RemoveZone(playerZoneID)
				end)

				if success then
					print("[Flyte] DEBUG: Zone manager removal result:", result)
				else
					print("[Flyte] DEBUG: Error removing zone from zone manager:", result)
				end
			end

			if v2[p] and v2[p][playerZoneID] then
				v2[p][playerZoneID] = nil
				print("[Flyte] DEBUG: Removed zone tracking for", p.Name, "zone", playerZoneID)

				if next(v2[p]) == nil then
					v2[p] = nil
					print("[Flyte] DEBUG: Removed all zone tracking for", p.Name)
				end
			end

			print("[Flyte] DEBUG: Zone removed successfully")
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
				local v6 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v6)
			end
		end
	end)
	print("[Flyte] DEBUG: Ability activated successfully for", p.Name)
	return {
		Outcome = true,
		Reason = "Gust created!"
	}
end

function Flyte.CleanupGusts()
	print("[Flyte] DEBUG: Cleaning up all Flyte gusts")

	for k, v5 in pairs(v2) do
		for k2, _ in pairs(v5) do
			local zoneManager = getZoneManager()

			if zoneManager then
				local v6 = zoneManager
				local v7 = k2
				local success, result = pcall(function()
					return v6.RemoveZone(v7)
				end)

				if success then
					print("[Flyte] DEBUG: Cleanup - removed zone", k2, "result:", result)
				else
					print("[Flyte] DEBUG: Error removing zone", k2, ":", result)
				end
			end

			v2[k][k2] = nil
		end

		if next(v2[k]) ~= nil then
			continue
		end

		v2[k] = nil
		print("[Flyte] DEBUG: Cleanup - removed player", k.Name, "from zone tracking")
	end

	local v5 = {}

	for k, v6 in pairs(v4) do
		for k2 in pairs(v6.activeZones or {}) do
			table.insert(v5, {
				player = k,
				zoneId = k2
			})
		end
	end

	for _, v6 in ipairs(v5) do
		removeGustBoost(v6.player, v6.player.Character, v6.zoneId)
	end

	for k, v6 in pairs(v3) do
		for _, v7 in pairs(v6) do
			if v7.graceTimer then
				pcall(task.cancel, v7.graceTimer)
			end
		end

		v3[k] = nil
	end

	print("[Flyte] DEBUG: All Flyte gusts cleaned up successfully")
end

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		if v4[player] then
			local v5 = {}

			for k in pairs(v4[player].activeZones or {}) do
				table.insert(v5, k)
			end

			for _, v6 in ipairs(v5) do
				removeGustBoost(player, player.Character, v6)
			end
		end

		if v3[player] then
			for _, v5 in pairs(v3[player]) do
				if v5.graceTimer then
					pcall(task.cancel, v5.graceTimer)
				end
			end

			v3[player] = nil
		end

		if v2[player] then
			v2[player] = nil
		end
	end)
end

Flyte.PlayFunctions = {}
return Flyte