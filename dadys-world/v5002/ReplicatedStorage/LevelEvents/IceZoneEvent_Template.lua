local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local IceSkatingConfig = require(ReplicatedStorage.Modules.Zones.IceSkatingConfig)
local IceZoneEventTemplate = {}
IceZoneEventTemplate.properties = {
	AltersLighting = true,
	AltersPhysics = true,
	IceSkatingMode = "ZoneBased",
	UsesSimplePhysics = true
}
IceZoneEventTemplate.loadDelay = 0.5
IceZoneEventTemplate.setupDelay = 0.1

function IceZoneEventTemplate.onRoomLoad(instance, _)
	print("[IceZoneEvent] Setting up zone-based ice skating")
	instance:SetAttribute("OriginalBrightness", Lighting.Brightness)
	instance:SetAttribute("OriginalAmbient_R", Lighting.Ambient.R)
	instance:SetAttribute("OriginalAmbient_G", Lighting.Ambient.G)
	instance:SetAttribute("OriginalAmbient_B", Lighting.Ambient.B)
	instance:SetAttribute("OriginalOutdoorAmbient_R", Lighting.OutdoorAmbient.R)
	instance:SetAttribute("OriginalOutdoorAmbient_G", Lighting.OutdoorAmbient.G)
	instance:SetAttribute("OriginalOutdoorAmbient_B", Lighting.OutdoorAmbient.B)
	instance:SetAttribute("OriginalClockTime", Lighting.ClockTime)
	instance:SetAttribute("OriginalFogEnd", Lighting.FogEnd)
	instance:SetAttribute("OriginalFogColor_R", Lighting.FogColor.R)
	instance:SetAttribute("OriginalFogColor_G", Lighting.FogColor.G)
	instance:SetAttribute("OriginalFogColor_B", Lighting.FogColor.B)
	TweenService:Create(Lighting, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 2.2,
		Ambient = Color3.fromRGB(235, 245, 255),
		OutdoorAmbient = Color3.fromRGB(225, 235, 250),
		FogEnd = 500,
		FogColor = Color3.fromRGB(210, 225, 245)
	}):Play()
	local triggerZones = instance:FindFirstChild("TriggerZones") or instance:FindFirstChild("IceZones")

	if triggerZones then
		for _, instance2 in pairs(triggerZones:GetChildren()) do
			if not (instance2.Name:find("Ice") or instance2.Name:find("Skating")) then
				continue
			end

			CollectionService:AddTag(instance2, "IceZone")
			print("[IceZoneEvent] Tagged ice zone:", instance2.Name)
		end
	end
end

function IceZoneEventTemplate.setupBehaviors(instance, _)
	local SimpleZone = require(ReplicatedStorage.Modules:WaitForChild("SimpleZone"))
	local Players = game:GetService("Players")
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}

	local function applyIcePhysics(character)
		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoidRootPart) then
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(character)
		local userId = playerFromCharacter and playerFromCharacter.UserId or character.Name

		if not v4[userId] then
			v4[userId] = {
				character = character,
				hrp = humanoidRootPart,
				originalHRPPhysics = humanoidRootPart.CustomPhysicalProperties,
				originalMaxSlopeAngle = humanoid.MaxSlopeAngle,
				originalWalkSpeed = humanoid.WalkSpeed
			}
		end

		humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0, 0.1, 100, 0.5)
		humanoid.MaxSlopeAngle = 89
		humanoid.WalkSpeed *= 1.3
		character:SetAttribute("IceSkatingMode", true)
		local playerFromCharacter2 = Players:GetPlayerFromCharacter(character)

		if playerFromCharacter2 then
			IceSkatingConfig.ApplyAntiCheatExceptions(playerFromCharacter2, "Simple")
		end
	end

	local function removeIcePhysics(character)
		local playerFromCharacter = Players:GetPlayerFromCharacter(character)
		local userId = playerFromCharacter and playerFromCharacter.UserId or character.Name
		local v5 = v4[userId]

		if not v5 then
			return
		end

		pcall(function()
			if v5.hrp and v5.hrp.Parent then
				v5.hrp.CustomPhysicalProperties = PhysicalProperties.new(1.5, 0.3, 0.5, 1, 1)
			end

			if v5.character:FindFirstChild("Humanoid") then
				local humanoid = v5.character.Humanoid
				humanoid.MaxSlopeAngle = v5.originalMaxSlopeAngle or 89
				humanoid.WalkSpeed = v5.originalWalkSpeed or 16
			end
		end)
		v4[userId] = nil
		character:SetAttribute("IceSkatingMode", nil)

		if playerFromCharacter then
			IceSkatingConfig.ClearAntiCheatExceptions(playerFromCharacter)
		end
	end

	local tagged = CollectionService:GetTagged("IceZone")

	if #tagged == 0 then
		warn("[IceZoneEvent] No 'IceZone' tagged parts found! Tag parts in Studio to enable zones.")
	end

	for _, part in pairs(tagged) do
		if not (part:IsDescendantOf(instance) and part:IsA("BasePart")) then
			continue
		end

		local v5 = SimpleZone.fromPart(part)
		v5.ItemEntered:Connect(function(player)
			if player:IsA("Player") and player.Character then
				v3[player.UserId] = true
				applyIcePhysics(player.Character)
			end
		end)
		v5.ItemExited:Connect(function(player)
			if player:IsA("Player") and player.Character then
				v3[player.UserId] = nil
				removeIcePhysics(player.Character)
			end
		end)
		v5:BindToHeartbeat()
		table.insert(v2, v5)
	end

	return function()
		for _, v5 in ipairs(v2) do
			v5:UnbindFromHeartbeat()
		end

		for k, _ in pairs(v3) do
			local v5 = v4[k]

			if v5 and v5.character then
				removeIcePhysics(v5.character)
			end
		end

		for _, v5 in pairs(Players:GetPlayers()) do
			if v5.Character then
				v5.Character:SetAttribute("IceSkatingMode", nil)
				v5.Character:SetAttribute("DisableSprintAnimations", nil)
				local humanoidRootPart = v5.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(1.5, 0.3, 0.5, 1, 1)
				end

				local humanoid = v5.Character:FindFirstChild("Humanoid")

				if humanoid then
					humanoid.MaxSlopeAngle = 89
				end
			end

			IceSkatingConfig.ClearAntiCheatExceptions(v5)
		end

		pcall(function()
			TweenService:Create(Lighting, TweenInfo.new(1), {
				Brightness = instance:GetAttribute("OriginalBrightness") or 1,
				Ambient = Color3.new(
					instance:GetAttribute("OriginalAmbient_R") or 0.5,
					instance:GetAttribute("OriginalAmbient_G") or 0.5,
					instance:GetAttribute("OriginalAmbient_B") or 0.5
				)
			}):Play()
		end)

		for _, callback in ipairs(v) do
			pcall(callback)
		end
	end
end

return IceZoneEventTemplate