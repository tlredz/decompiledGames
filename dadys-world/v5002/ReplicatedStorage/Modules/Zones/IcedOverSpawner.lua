local IcedOverSpawner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local cardModifiers = workspace.Info.CardModifiers
local IceSkatingConfig = require(ReplicatedStorage.Modules.Zones.IceSkatingConfig)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local v = nil
pcall(function()
	local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
	v = SoundGroupManager
end)
local IceSkatingGlobalBoosts = require(ReplicatedStorage.CharacterModules.IceSkatingGlobalBoosts)
local RunService = game:GetService("RunService")

local function twistedIceSlide()
	if not RunService:IsServer() then
		return nil
	end

	local success, result = pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")
		return require(ServerScriptService.MonsterAI.Modules.TwistedIceSlide)
	end)

	if success then
		return result
	end

	warn("[IcedOverSpawner] TwistedIceSlide unavailable:", result)
	return nil
end

local flag = false
local v2 = {}
local playerAddedConnection = nil
local playerRemovingConnection = nil

local function debugLog(...) end

local function logModifierState(_, _) end

local function applyIceSkatingToPlayer(p, character, p2)
	debugLog("applyIceSkatingToPlayer called for", p.Name)

	if character and character:GetAttribute("IceSkatingMode") then
		debugLog("  Skipping", p.Name, "- already has IceSkatingMode")
		return
	end

	local preset = IceSkatingConfig.Presets[p2]
	local v3 = preset and preset.disableSprint ~= false
	IceSkatingConfig.ApplyAntiCheatExceptions(p, p2)

	if character then
		character:SetAttribute("IceSkatingMode", true)

		if v3 then
			character:SetAttribute("DisableSprintAnimations", true)
		end

		debugLog("  Calling IceSkatingGlobalBoosts.AddBoost with multiplier:", 1.15)
		IceSkatingGlobalBoosts.AddBoost(character, 1.15)
	end

	print("[IcedOverSpawner] Applied ice skating to", p.Name, "| Preset:", p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCharacterListeners(player)
	if v2[player] then
		v2[player]:Disconnect()
	end

	v2[player] = player.CharacterAdded:Connect(function(character)
		if flag then
			task.wait(0.1)

			if flag and character and character.Parent then
				applyIceSkatingToPlayer(player, character, "CharlieBrown")
				local iceSkatingToggle = ReplicatedStorage:FindFirstChild("IceSkatingToggle")

				if iceSkatingToggle then
					iceSkatingToggle:FireClient(player, "Activate", "CharlieBrown")
					iceSkatingToggle:FireClient(player, "FreezeLevel")
				end
			end
		end
	end)
end

local function TrackIcedOverMastery()
	local editData = ReplicatedStorage:FindFirstChild("editData")

	if not editData then
		warn("IcedOverSpawner: editData not found for mastery tracking")
		return
	end

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		local v3 = child
		local success, result = pcall(function()
			local playerFromCharacter = Players:GetPlayerFromCharacter(v3)

			if not playerFromCharacter then
				return
			end

			local moduleName = v3:WaitForChild("Config"):WaitForChild("ModuleName")
			editData:Invoke(playerFromCharacter, function(p)
				if p then
					local v4 = false

					for k, v6 in pairs(p.Data.Mastery) do
						if v6.Name ~= moduleName.Value then
							continue
						end

						v4 = v6
						break
					end

					if v4 then
						for k, v6 in pairs(v4.RequirementList) do
							if v6.Name ~= "IcedOver" then
								continue
							end

							v6.Current += 1

							if v6.Current >= v6.Amount then
								v6.Current = v6.Amount
							end
						end
					end
				end
			end)
		end)

		if not success then
			warn(result)
		end
	end
end

function IcedOverSpawner.ActivateIcedOver()
	if flag then
		warn("[IcedOverSpawner] Already active - skipping duplicate activation")
		return
	end

	print("[IcedOverSpawner] Activating Iced Over visual effects")
	flag = true

	if not cardModifiers:FindFirstChild("IceSkatingEnabled") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "IceSkatingEnabled"
		boolValue.Value = true
		boolValue.Parent = cardModifiers
	end

	local iceSkatingPreset = cardModifiers:FindFirstChild("IceSkatingPreset")

	if iceSkatingPreset then
		iceSkatingPreset.Value = "CharlieBrown"
	else
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "IceSkatingPreset"
		stringValue.Value = "CharlieBrown"
		stringValue.Parent = cardModifiers
	end

	if not cardModifiers:FindFirstChild("IceSkatingUseSounds") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "IceSkatingUseSounds"
		boolValue.Value = true
		boolValue.Parent = cardModifiers
	end

	if not cardModifiers:FindFirstChild("IceSkatingFreezeFloors") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "IceSkatingFreezeFloors"
		boolValue.Value = true
		boolValue.Parent = cardModifiers
	end

	local v3 = ReplicatedStorage:FindFirstChild("IceSkatingToggle")

	if not v3 then
		v3 = Instance.new("RemoteEvent")
		v3.Name = "IceSkatingToggle"
		v3.Parent = ReplicatedStorage
	end

	print("[IcedOverSpawner] Preset:", "CharlieBrown")

	for _, v4 in pairs(Players:GetPlayers()) do
		applyIceSkatingToPlayer(v4, v4.Character, "CharlieBrown")
		setupCharacterListeners(v4) -- equivalent call inferred; original call site unknown
	end

	playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		if flag then
			setupCharacterListeners(player) -- equivalent call inferred; original call site unknown

			if player.Character then
				applyIceSkatingToPlayer(player, player.Character, "CharlieBrown")
				v3:FireClient(player, "Activate", "CharlieBrown")
				v3:FireClient(player, "FreezeLevel")
			end
		end
	end)
	playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		if v2[player] then
			v2[player]:Disconnect()
			v2[player] = nil
		end

		IceSkatingConfig.ClearAntiCheatExceptions(player)
	end)
	task.wait(0.1)
	v3:FireAllClients("Activate", "CharlieBrown")
	v3:FireAllClients("FreezeLevel")
	local v4 = twistedIceSlide()

	if v4 then
		local success, result = pcall(v4.Activate, "CharlieBrown")

		if not success then
			warn("[IcedOverSpawner] TwistedIceSlide.Activate failed:", result)
		end
	end

	local v5 = Audio:Play("Sounds.ZoneEvents.Skating.Wind", {
		Volume = 0.8,
		Parent = workspace
	})

	if v5 and v then
		v.AssignSound(v5, "LevelEvents")
	end

	TrackIcedOverMastery()
	print("[IcedOverSpawner] Ice skating activated with Holiday Twisted spawn!")
end

function IcedOverSpawner.Cleanup()
	if not flag then
		print("[IcedOverSpawner] Already cleaned up - skipping")
		return
	end

	print("[IcedOverSpawner] Cleaning up ice skating effects")
	flag = false

	for _, connection in pairs(v2) do
		if connection then
			connection:Disconnect()
		end
	end

	v2 = {}

	if playerAddedConnection then
		playerAddedConnection:Disconnect()
		playerAddedConnection = nil
	end

	if playerRemovingConnection then
		playerRemovingConnection:Disconnect()
		playerRemovingConnection = nil
	end

	local iceSkatingToggle = ReplicatedStorage:FindFirstChild("IceSkatingToggle")

	if iceSkatingToggle then
		iceSkatingToggle:FireAllClients("Deactivate")
	end

	debugLog("Cleanup: Removing ice skating from all players")

	for _, v3 in pairs(Players:GetPlayers()) do
		if v3.Character then
			debugLog("Cleanup: Processing", v3.Name)
			local _ = v3.Character
			v3.Character:SetAttribute("IceSprintBoost", nil)
			v3.Character:SetAttribute("IceSkatingStaminaDepleted", nil)
			debugLog("  Calling IceSkatingGlobalBoosts.RemoveBoost")
			IceSkatingGlobalBoosts.RemoveBoost(v3.Character)
			local _ = v3.Character
			v3.Character:SetAttribute("IceSkatingMode", nil)
			v3.Character:SetAttribute("DisableSprintAnimations", nil)
			local humanoidRootPart = v3.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(1.5, 0.3, 0.5, 1, 1)
			end

			local humanoid = v3.Character:FindFirstChild("Humanoid")

			if humanoid then
				humanoid.MaxSlopeAngle = 89
			end
		end

		IceSkatingConfig.ClearAntiCheatExceptions(v3)
	end

	local v3 = twistedIceSlide()

	if v3 then
		pcall(v3.Deactivate)
	end

	for _, childName in ipairs({
		"IceSkatingEnabled",
		"IceSkatingPreset",
		"IceSkatingFreezeFloors",
		"IceSkatingUseSounds",
		"ForceHolidayTwisted"
	}) do
		local child = cardModifiers:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	print("[IcedOverSpawner] Cleanup complete")
end

function IcedOverSpawner.IsActive()
	return flag
end

return IcedOverSpawner