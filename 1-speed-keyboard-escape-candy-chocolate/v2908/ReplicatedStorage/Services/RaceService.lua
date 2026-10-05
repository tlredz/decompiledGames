local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Utilities.Signal)
local ZoneSystem = require(ReplicatedStorage:WaitForChild("ZoneSystem"))
local RaceConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("RaceConfig"))
local isClient = RunService:IsClient()
local localPlayer

if isClient then
	localPlayer = Players.LocalPlayer or nil
else
	localPlayer = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stageIndexOf(instance)
	return (instance:GetAttribute(RaceConfig.STAGE_ATTRIBUTE))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sortedSASZones()
	local sASZones = ZoneSystem.GetSASZones()
	table.sort(sASZones, function(a, b)
		return (a:GetAttribute(RaceConfig.STAGE_ATTRIBUTE) or 0) < (b:GetAttribute(RaceConfig.STAGE_ATTRIBUTE) or 0)
	end)
	return sASZones
end

local sASZones = ZoneSystem.GetSASZones()
table.sort(sASZones, function(a, b)
	return (a:GetAttribute(RaceConfig.STAGE_ATTRIBUTE) or 0) < (b:GetAttribute(RaceConfig.STAGE_ATTRIBUTE) or 0)
end)
local v = isClient and 0 or #sASZones

local function getStageCount()
	return v
end

if isClient then
	local RaceRemotes = require(ReplicatedStorage.Services.RaceRemotes)
	RaceRemotes.RaceStageCount:connect(function(value: number)
		if type(value) == "number" then
			v = value
		end
	end)
end

local playerEnteredStage = Signal.new()
local playerLeftStage = Signal.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getLivingHRP(player)
	local character = player.Character

	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and not (humanoid.Health <= 0) then
		return (character:FindFirstChild("HumanoidRootPart"))
	end

	return nil
end

local function getPlayersInPart(p)
	local result = {}

	for _, v4 in Players:GetPlayers() do
		local livingHRP = getLivingHRP(v4) -- equivalent call inferred; original call site unknown

		if livingHRP and ZoneSystem.GetZoneAt(livingHRP, { p }) then
			result[#result + 1] = v4
		end
	end

	return result
end

local function getPlayerStage(player)
	local livingHRP = getLivingHRP(player) -- equivalent call inferred; original call site unknown

	if not livingHRP then
		return nil
	end

	local zoneAt = ZoneSystem.GetZoneAt(livingHRP, sortedSASZones())
	return zoneAt and zoneAt:GetAttribute(RaceConfig.STAGE_ATTRIBUTE) or nil
end

local function getAllPlayersStages()
	local sASZones2 = sortedSASZones() -- equivalent call inferred; original call site unknown
	local attributes = {}

	for _, v5 in Players:GetPlayers() do
		local livingHRP = getLivingHRP(v5) -- equivalent call inferred; original call site unknown
		local v6

		if livingHRP then
			v6 = ZoneSystem.GetZoneAt(livingHRP, sASZones2) or nil
		end

		local attribute = v6 and v6:GetAttribute(RaceConfig.STAGE_ATTRIBUTE)

		if attribute then
			attributes[v5] = attribute
		end
	end

	return attributes
end

local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function initState(p)
	v4[p] = {
		stage = nil
	}
end

local function getPlayerState(p)
	return v4[p or localPlayer]
end

local function setStageZone(p, instance)
	local v6 = v5[p]

	if instance == v6 then
		return
	end

	local v7 = v4[p]

	if v6 then
		if v7 then
			v7.stage = nil
		end

		playerLeftStage:Fire(p, (v6:GetAttribute(RaceConfig.STAGE_ATTRIBUTE)))
	end

	if instance then
		local stage = stageIndexOf(instance) -- equivalent call inferred; original call site unknown

		if v7 then
			v7.stage = stage
		end

		playerEnteredStage:Fire(p, stage)
	end

	v5[p] = instance
end

local function tick()
	local sASZones2 = sortedSASZones() -- equivalent call inferred; original call site unknown

	if isClient then
		local livingHRP = getLivingHRP(localPlayer) -- equivalent call inferred; original call site unknown
		setStageZone(localPlayer, livingHRP and ZoneSystem.GetZoneAt(livingHRP, sASZones2) or nil)
	else
		for _, v7 in Players:GetPlayers() do
			if not v4[v7] then
				continue
			end

			local livingHRP = getLivingHRP(v7) -- equivalent call inferred; original call site unknown
			local v8

			if livingHRP then
				v8 = ZoneSystem.GetZoneAt(livingHRP, sASZones2) or nil
			end

			setStageZone(v7, v8)
		end
	end
end

if isClient then
	initState(localPlayer) -- equivalent call inferred; original call site unknown
else
	Players.PlayerAdded:Connect(initState)
	Players.PlayerRemoving:Connect(function(player)
		v4[player] = nil
		v5[player] = nil
	end)

	for _, v6 in Players:GetPlayers() do
		initState(v6) -- equivalent call inferred; original call site unknown
	end
end

RunService.Heartbeat:Connect(tick)
return {
	SortedStages = sASZones,
	GetStageCount = getStageCount,
	GetPlayersInPart = getPlayersInPart,
	GetPlayerStage = getPlayerStage,
	GetAllPlayersStages = getAllPlayersStages,
	GetPlayerState = getPlayerState,
	PlayerEnteredStage = playerEnteredStage,
	PlayerLeftStage = playerLeftStage
}