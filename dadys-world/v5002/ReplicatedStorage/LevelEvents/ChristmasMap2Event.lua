local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local IceSkatingConfig = require(ReplicatedStorage.Modules.Zones.IceSkatingConfig)
local IcedOverSpawner = require(ReplicatedStorage.Modules.Zones.IcedOverSpawner)
local IceSkatingGlobalBoosts = require(ReplicatedStorage.CharacterModules.IceSkatingGlobalBoosts)
local ChristmasMap2Event = {}
ChristmasMap2Event.properties = {
	AltersPhysics = true,
	IceSkatingMode = "ZoneBased",
	HasDialogueTriggers = true,
	TriggerDuration = 8
}
ChristmasMap2Event.loadDelay = 0.5
ChristmasMap2Event.setupDelay = 0.1

function ChristmasMap2Event.onRoomLoad(instance, _)
	print("[ChristmasMap2Event] Setting up ChristmasMap2 special event")
	local triggerZones = instance:FindFirstChild("TriggerZones")

	if triggerZones then
		for _, instance2 in pairs(triggerZones:GetChildren()) do
			if not (instance2.Name:find("Dialogue") or instance2.Name:find("Story") or instance2.Name:find("Lore")) then
				continue
			end

			CollectionService:AddTag(instance2, "StoryTrigger")
			print("[ChristmasMap2Event] Tagged story trigger:", instance2.Name)
		end
	end

	local iceSkatingZones = instance:FindFirstChild("IceSkatingZones")

	if iceSkatingZones then
		print("[ChristmasMap2Event] Found IceSkatingZones folder with", #iceSkatingZones:GetChildren(), "zones")
	end
end

function ChristmasMap2Event.setupBehaviors(ancestor, _)
	print("[ChristmasMap2Event] Setting up zone-based ice skating and lore room")
	local v = {}
	local SimpleZone = require(ReplicatedStorage.Modules:WaitForChild("SimpleZone"))
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = ReplicatedStorage:FindFirstChild("IceSkatingToggle")

	if not v7 then
		v7 = Instance.new("RemoteEvent")
		v7.Name = "IceSkatingToggle"
		v7.Parent = ReplicatedStorage
	end

	local charlieBrownTriggerZone = IceSkatingConfig.Presets.CharlieBrownTriggerZone
	local walkSpeedMultiplier = charlieBrownTriggerZone and charlieBrownTriggerZone.walkSpeedMultiplier or 1.15

	local function debugLog(...) end

	local function logModifierState(_, _) end

	local function applyIcePhysics(character)
		debugLog("applyIcePhysics called for", character.Name)

		if IcedOverSpawner.IsActive() then
			debugLog("  GUARD: IcedOver is active, skipping zone-based effects")
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoidRootPart) then
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not playerFromCharacter then
			return
		end

		local userId = playerFromCharacter.UserId

		if character:GetAttribute("IceSkatingMode") then
			debugLog("  GUARD: Already has IceSkatingMode, skipping")
			return
		end

		if not v5[userId] or v5[userId].character ~= character then
			v5[userId] = {
				character = character,
				hrp = humanoidRootPart,
				originalHRPPhysics = humanoidRootPart.CustomPhysicalProperties,
				originalMaxSlopeAngle = humanoid.MaxSlopeAngle
			}
		end

		humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0, 0.1, 100, 0.5)
		humanoid.MaxSlopeAngle = 89
		character:SetAttribute("IceSkatingMode", true)
		debugLog("  Calling IceSkatingGlobalBoosts.AddBoost with multiplier:", walkSpeedMultiplier)
		IceSkatingGlobalBoosts.AddBoost(character, walkSpeedMultiplier)
		IceSkatingConfig.ApplyAntiCheatExceptions(playerFromCharacter, "CharlieBrownTriggerZone")
		v4[userId] = true
		v7:FireClient(playerFromCharacter, "Activate", "CharlieBrownTriggerZone")
		print("[ChristmasMap2Event] Applied ice physics and effects to", character.Name)
	end

	local function removeIcePhysics(character)
		debugLog("removeIcePhysics called for", character.Name)

		if IcedOverSpawner.IsActive() then
			debugLog("  GUARD: IcedOver is active, skipping removal")
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not playerFromCharacter then
			return
		end

		local userId = playerFromCharacter.UserId
		local v8 = v5[userId]

		if not v4[userId] then
			debugLog("  GUARD: No effects active for this player, skipping")
			return
		end

		if v8 then
			pcall(function()
				if v8.hrp and v8.hrp.Parent then
					v8.hrp.CustomPhysicalProperties = PhysicalProperties.new(1.5, 0.3, 0.5, 1, 1)
				end

				if v8.character:FindFirstChild("Humanoid") then
					v8.character.Humanoid.MaxSlopeAngle = v8.originalMaxSlopeAngle or 89
				end
			end)
			v5[userId] = nil
		end

		debugLog("  Calling IceSkatingGlobalBoosts.RemoveBoost")
		IceSkatingGlobalBoosts.RemoveBoost(character)
		v4[userId] = nil
		v7:FireClient(playerFromCharacter, "Deactivate")
		task.delay(3, function()
			if v4[userId] ~= nil then
				return
			end

			if character and character.Parent then
				character:SetAttribute("IceSkatingMode", nil)
				character:SetAttribute("DisableSprintAnimations", nil)
			end

			if playerFromCharacter and playerFromCharacter.Parent then
				IceSkatingConfig.ClearAntiCheatExceptions(playerFromCharacter)
			end
		end)
		print("[ChristmasMap2Event] Removed ice physics and effects from", character.Name)
	end

	local tagged = CollectionService:GetTagged("IceSkatingZone")
	local count = 0

	for _, part in pairs(tagged) do
		if not (part:IsDescendantOf(ancestor) and part:IsA("BasePart")) then
			continue
		end

		local v8 = SimpleZone.fromPart(part)
		v8.ItemEntered:Connect(function(player)
			if player:IsA("Player") and player.Character then
				local userId = player.UserId

				if v6[userId] then
					task.cancel(v6[userId])
					v6[userId] = nil
				end

				v3[userId] = (v3[userId] or 0) + 1
				applyIcePhysics(player.Character)
			end
		end)
		v8.ItemExited:Connect(function(player)
			if player:IsA("Player") and player.Character then
				local userId = player.UserId
				v3[userId] = (v3[userId] or 1) - 1

				if v3[userId] <= 0 then
					v3[userId] = nil

					if v6[userId] then
						task.cancel(v6[userId])
					end

					v6[userId] = task.delay(0, function()
						v6[userId] = nil

						if not v3[userId] and player.Character then
							removeIcePhysics(player.Character)
						end
					end)
				end
			end
		end)
		v8:BindToHeartbeat()
		table.insert(v2, v8)
		count += 1
	end

	if count == 0 then
		warn("[ChristmasMap2Event] No 'IceSkatingZone' tagged parts found in room!")
	else
		print("[ChristmasMap2Event] Set up", count, "ice zones")
	end

	local dialogueEvent = ReplicatedStorage:FindFirstChild("StoryEvents") and ReplicatedStorage.StoryEvents:FindFirstChild("DialogueEvent")
	local v8 = {}
	local v9 = {}
	local v10 = {}

	if dialogueEvent then
		local v11 = {
			Bobette = "...I don't remember leaving things like this.",
			Ginger = "Oh Bobette...",
			Coal = "(Whine whine)",
			Rudie = "Woah..."
		}

		local function getHolidayToonName(player)
			if not (player and player.Character) then
				return nil
			end

			local config = player.Character:FindFirstChild("Config")

			if config and config:FindFirstChild("ModuleName") then
				local value = config.ModuleName.Value

				if v11[value] then
					return value
				end
			end

			return nil
		end

		local tagged2 = CollectionService:GetTagged("StoryTrigger")

		for _, part in pairs(tagged2) do
			if not (part:IsDescendantOf(ancestor) and part:IsA("BasePart")) then
				continue
			end

			local v12 = SimpleZone.fromPart(part)
			local v13 = part
			v12.ItemEntered:Connect(function(player)
				if not player:IsA("Player") then
					return
				end

				local value

				if player and player.Character then
					local config = player.Character:FindFirstChild("Config")

					if config and config:FindFirstChild("ModuleName") then
						value = config.ModuleName.Value

						if not v11[value] then
							value = nil
						end
					else
						value = nil
					end
				else
					value = nil
				end

				if not value or v9[player] then
					return
				end

				local v14 = player.UserId .. "_" .. v13:GetFullName()

				if not v10[v14] then
					v10[v14] = task.spawn(function()
						task.wait(8)

						if player and player.Parent then
							v9[player] = true
							local v15 = v11[value]
							dialogueEvent:Fire(player.Character, value, v15, 3)
							v10[v14] = nil
							print("[ChristmasMap2Event] Triggered lore dialogue for", value)
						end
					end)
				end
			end)
			local v14 = part
			v12.ItemExited:Connect(function(player)
				if not player:IsA("Player") then
					return
				end

				local v15 = player.UserId .. "_" .. v14:GetFullName()

				if v10[v15] then
					task.cancel(v10[v15])
					v10[v15] = nil
				end
			end)
			v12:BindToHeartbeat()
			table.insert(v8, v12)
		end

		print("[ChristmasMap2Event] Lore room dialogue system initialized")
	else
		warn("[ChristmasMap2Event] DialogueEvent not found - lore room disabled")
	end

	return function()
		print("[ChristmasMap2Event] Cleaning up...")

		for _, v11 in ipairs(v2) do
			v11:UnbindFromHeartbeat()
		end

		for k, _ in pairs(v4) do
			local playerByUserId = Players:GetPlayerByUserId(k)

			if not playerByUserId then
				continue
			end

			if playerByUserId.Character then
				playerByUserId.Character:SetAttribute("IceSprintBoost", nil)
				playerByUserId.Character:SetAttribute("IceSkatingStaminaDepleted", nil)
				IceSkatingGlobalBoosts.RemoveBoost(playerByUserId.Character)
				playerByUserId.Character:SetAttribute("IceSkatingMode", nil)
				playerByUserId.Character:SetAttribute("DisableSprintAnimations", nil)
				local humanoidRootPart = playerByUserId.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(1.5, 0.3, 0.5, 1, 1)
				end

				local humanoid = playerByUserId.Character:FindFirstChild("Humanoid")

				if humanoid then
					humanoid.MaxSlopeAngle = 89
				end
			end

			local v11 = playerByUserId
			pcall(function()
				v7:FireClient(v11, "Deactivate")
			end)
			IceSkatingConfig.ClearAntiCheatExceptions(playerByUserId)
		end

		for _, v11 in pairs(v6) do
			if v11 then
				task.cancel(v11)
			end
		end

		table.clear(v6)
		table.clear(v3)
		table.clear(v4)
		table.clear(v5)

		for _, v11 in ipairs(v8) do
			v11:UnbindFromHeartbeat()
		end

		table.clear(v9)

		for _, v11 in pairs(v10) do
			if v11 then
				task.cancel(v11)
			end
		end

		table.clear(v10)

		for _, callback in ipairs(v) do
			pcall(callback)
		end

		print("[ChristmasMap2Event] Cleanup complete")
	end
end

return ChristmasMap2Event