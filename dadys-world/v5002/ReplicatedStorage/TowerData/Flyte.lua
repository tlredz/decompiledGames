local createVector = vector.create
local Flyte = {
	Name = "Flyte",
	VoteIcon = "rbxassetid://131927598636700",
	Icon = "rbxassetid://82095952372356",
	DecodeRank = 4,
	SpeedRank = 4,
	StaminaRank = 2,
	StealthRank = 3,
	SkillCheckRank = 2,
	HealthRank = 3,
	Ability1Name = "Gust",
	Ability1Type = "Active",
	Ability1Description = "This Toon places a 'Gust' at Flyte's location that lasts for 10 seconds. Walking into the Gust gives a 15% movement speed boost for 3 seconds. Has a cooldown of 50 seconds.",
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
	Requirement1 = { "HolidayPoints", 1300 },
	MasterySkin = "VintageFlyte",
	Rarity = "Uncommon"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
game:GetService("ServerStorage")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://5272402910"
sound.Volume = 0.8
sound.Parent = script
Flyte.ActiveAbility = true
Flyte.AbilityIcon = "rbxassetid://89936564179654"
Flyte.AbilityCooldown = 50
Flyte.AbilityDuration = 10
Flyte.AbilityRange = 20
Flyte.BoostDuration = 5
Flyte.BoostMultiplier = 1.15
Flyte.CustomAbilitySound = sound

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

local function removeGustBoost(p, p2, p3)
	print("[Flyte] DEBUG: Removing boost from", p.Name, "for zone", p3)

	if not p2 or p2.Parent == nil then
		print("[Flyte] DEBUG: Character no longer exists for", p.Name)
		return
	end

	if not v4[p] then
		print("[Flyte] DEBUG: Speed tracking no longer exists for", p.Name)
		return
	end

	if not (v4[p].activeZones and v4[p].activeZones[p3]) then
		print("[Flyte] DEBUG: Zone", p3, "not found in active zones for", p.Name)
		return
	end

	local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
	local activeZone = v4[p].activeZones[p3]
	print("[Flyte] DEBUG: Removing speed modifiers for zone", p3, "from", p.Name)

	if activeZone.modifierIds then
		StatModifierManager.RemoveSpeedModifiers(p2, activeZone.modifierIds)
	end

	v4[p].activeZones[p3] = nil
	print("[Flyte] DEBUG: Removed speed boost from zone", p3, "for", p.Name)
	local count = 0

	for _ in pairs(v4[p].activeZones) do
		count += 1
	end

	if count == 0 then
		print("[Flyte] DEBUG: No more active zones, cleaning up speed tracking for", p.Name)
		v4[p] = nil
	end

	if v3[p] and v3[p][p3] then
		for _, v5 in ipairs(v3[p][p3].cleanupTimers or {}) do
			local v6 = v5
			pcall(function()
				task.cancel(v6)
			end)
		end

		v3[p][p3] = nil
		print("[Flyte] DEBUG: Removed boost tracking data for", p.Name, "zone", p3)
	end

	if v3[p] and next(v3[p]) == nil then
		v3[p] = nil
		print("[Flyte] DEBUG: Removed player from boost tracking:", p.Name)
	end
end

local function removeZoneEffects(p, p2)
	print("[Flyte] DEBUG: Player", p.Name, "exited zone", p2)

	if v2[p] and v2[p][p2] then
		v2[p][p2] = nil
		print("[Flyte] DEBUG: Removed zone from active zones for", p.Name)

		if next(v2[p]) == nil then
			v2[p] = nil
			print("[Flyte] DEBUG: Removed player from active zones:", p.Name)
		end
	end

	print("[Flyte] DEBUG: Zone effect tracking updated, but boost will remain active for its full duration")
end

local function applyGustBoost(p, character, playerZoneID, sourcePlayer)
	print("[Flyte] DEBUG: Attempting to apply gust boost to", p.Name, "from zone", playerZoneID)

	if not v3[p] then
		v3[p] = {}
	end

	local now = os.time()
	local boostEndTime = now + Flyte.BoostDuration

	if v3[p][playerZoneID] then
		if now < v3[p][playerZoneID].boostEndTime then
			print("[Flyte] DEBUG: Player already boosted by this gust, skipping")
			return false
		end

		print("[Flyte] DEBUG: Cleaning up previous boost timers for", p.Name)

		for _, v6 in ipairs(v3[p][playerZoneID].cleanupTimers or {}) do
			local v7 = v6
			pcall(function()
				task.cancel(v7)
			end)
		end

		v3[p][playerZoneID].cleanupTimers = {}
	end

	v3[p][playerZoneID] = {
		lastTouchTime = now,
		boostEndTime = boostEndTime,
		cleanupTimers = {},
		sourcePlayer = sourcePlayer
	}
	print("[Flyte] DEBUG: Getting character stats for", p.Name)
	local stats = character:WaitForChild("Stats")

	if not stats then
		warn("[Flyte] ERROR: Stats not found for", p.Name)
		return false
	end

	local speedModifier = stats:WaitForChild("SpeedModifier")
	local runSpeedModifier = stats:WaitForChild("RunSpeedModifier")

	if not (speedModifier and runSpeedModifier) then
		warn("[Flyte] ERROR: Speed modifiers not found for", p.Name)
		return false
	end

	local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)

	if not v4[p] then
		v4[p] = {
			activeZones = {}
		}
		print("[Flyte] DEBUG: Initialized speed tracking for", p.Name)
	end

	if v4[p].activeZones[playerZoneID] then
		print("[Flyte] DEBUG: Zone", playerZoneID, "already providing boost to", p.Name, "- Refreshing duration")
	else
		local modifierIds = StatModifierManager.ApplySpeedModifiers(
			character,
			Flyte.BoostMultiplier,
			"FlyteGust_" .. playerZoneID,
			{
				category = "ability",
				antiCheat = true
			}
		)
		v4[p].activeZones[playerZoneID] = {
			multiplier = Flyte.BoostMultiplier,
			appliedAt = now,
			modifierIds = modifierIds
		}
		local count = 0

		for _ in pairs(v4[p].activeZones) do
			count += 1
		end

		print("[Flyte] DEBUG: Applied new speed boost from zone", playerZoneID, "to", p.Name, "- Total zones:", count)
	end

	print("[Flyte] DEBUG: Creating visual effects for", p.Name)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		warn("[Flyte] ERROR: HumanoidRootPart not found for", p.Name)
		return true
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "BuffParticle"
	attachment.Parent = humanoidRootPart
	local speed = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild("BuffParticles") and ReplicatedStorage.Parts.BuffParticles:FindFirstChild("Speed")
	print("[Flyte] DEBUG: BuffParticles path exists:", speed ~= nil)

	if speed then
		local clone = speed.BuffParticle:Clone()
		clone.Parent = attachment
		clone.Enabled = true
		local clone2 = speed.Glow:Clone()
		clone2.Parent = attachment
		clone2.Enabled = true
		Debris:AddItem(clone, Flyte.BoostDuration + 0.5)
		Debris:AddItem(clone2, Flyte.BoostDuration + 0.5)
		print("[Flyte] DEBUG: Added BuffParticles to", p.Name)
	else
		print("[Flyte] DEBUG: Using fallback visual effects for", p.Name)
		local trail = Instance.new("Trail")
		trail.Attachment0 = attachment
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "BuffTrailEnd"
		attachment2.Position = createVector(0, 0, -2)
		attachment2.Parent = humanoidRootPart
		trail.Attachment1 = attachment2
		trail.Color = ColorSequence.new(Color3.fromRGB(200, 235, 255))
		trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(
				1,
				1
			) })
		trail.Lifetime = 0.5
		trail.WidthScale = NumberSequence.new(1, 0)
		trail.Parent = humanoidRootPart
		Debris:AddItem(trail, Flyte.BoostDuration + 0.5)
		Debris:AddItem(attachment2, Flyte.BoostDuration + 0.5)
	end

	Debris:AddItem(attachment, Flyte.BoostDuration + 0.5)
	print("[Flyte] DEBUG: Scheduling boost removal in", Flyte.BoostDuration, "seconds for", p.Name)
	local thread = task.delay(Flyte.BoostDuration, function()
		removeGustBoost(p, character, playerZoneID)
	end)
	table.insert(v3[p][playerZoneID].cleanupTimers, thread)
	print("[Flyte] DEBUG: Successfully applied gust boost to", p.Name)
	return true
end

local function onPlayerExitedZone(p, _, p2)
	removeZoneEffects(p, p2)
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
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function()
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
				print("[Flyte] DEBUG: Player exited zone manually detected:", v6.Name)

				if not v2[v6] then
					continue
				end

				v2[v6][playerZoneID] = nil
				print("[Flyte] DEBUG: Zone effect tracking updated, boost will remain for full duration")

				if next(v2[v6]) ~= nil then
					continue
				end

				v2[v6] = nil
				print("[Flyte] DEBUG: Removed player from zone tracking:", v6.Name)
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

				removeGustBoost(player, player.Character, playerZoneID)
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

local Players2 = game:GetService("Players")
Players2.PlayerRemoving:Connect(function(player)
	if v2[player] then
		local zoneManager = getZoneManager()
		pcall(function()
			zoneManager.RemoveZone(v2[player])
		end)
		v2[player] = nil
	end

	if v3[player] then
		for _, v5 in pairs(v3[player]) do
			for _, v6 in ipairs(v5.cleanupTimers or {}) do
				pcall(task.cancel, v6)
			end
		end

		v3[player] = nil
	end

	if v4[player] then
		v4[player] = nil
	end
end)

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

	local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)

	for k, v5 in pairs(v4) do
		if not k.Character then
			continue
		end

		for k2, v6 in pairs(v5.activeZones or {}) do
			if not v6.modifierIds then
				continue
			end

			StatModifierManager.RemoveSpeedModifiers(k.Character, v6.modifierIds)
			print("[Flyte] DEBUG: Cleanup - removed speed boost from zone", k2, "for", k.Name)
		end
	end

	for k, _ in pairs(v3) do
		v3[k] = nil
	end

	for k, _ in pairs(v4) do
		v4[k] = nil
	end

	print("[Flyte] DEBUG: All Flyte gusts cleaned up successfully")
end

return Flyte