local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local floatingOrbWins = require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
require(script.Parent.Parent.Types)
local t = require(ReplicatedStorage.Packages.t)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {
	orbTemplate = "AdminAbuse/20Anniversary/Assets/CollectibleOrb",
	orbsPerWave = 18,
	maxActivePerPlayer = 126
}
local v2 = {
	source = "20thAnniversary:WinOrb",
	multiplier = 0.5
}
local strictInterface = t.strictInterface({
	kind = t.literal("winOrbCollect"),
	id = t.string
})

local function collectZones(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local zones

	if scriptables then
		zones = scriptables:FindFirstChild("Zones")
	end

	local orbZones

	if zones then
		orbZones = zones:FindFirstChild("OrbZones")
	end

	local parts = {}

	if orbZones then
		for _, part in orbZones:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end
	end

	return parts
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveOrbConfig(p)
	if not p then
		return v
	end

	local clone = table.clone(v)
	local orbsPerWave

	if p.orbsPerWave == nil then
		orbsPerWave = clone.orbsPerWave
	else
		orbsPerWave = p.orbsPerWave
	end

	clone.orbsPerWave = orbsPerWave
	local maxActivePerPlayer

	if p.maxActivePerPlayer == nil then
		maxActivePerPlayer = clone.maxActivePerPlayer
	else
		maxActivePerPlayer = p.maxActivePerPlayer
	end

	clone.maxActivePerPlayer = maxActivePerPlayer
	return clone
end

local OrbSupport = {}
OrbSupport.doubledOrbConfig = {
	orbsPerWave = 36,
	maxActivePerPlayer = 252
}

function OrbSupport.start(data, p: number, p2, p3)
	local v3 = collectZones(p2)

	if #v3 == 0 then
		logger:warn(string.format(
			"20th Anniversary Year %d map requires Scriptables.Zones.OrbZones with BaseParts for the win orbs to spawn in",
			p
		))
		return function() end
	end

	local startServer = floatingOrbWins.startServer
	local orbConfig = resolveOrbConfig(p3) -- equivalent call inferred; original call site unknown
	local v5 = startServer({
		config = orbConfig,
		getSpawnZones = function()
			return v3
		end,
		isPlayerEligible = data.isParticipant,
		awardWin = AAEventWinAward.create(v2),
		sendSpawn = function(p4, id: string, vector: Vector3)
			data.fireToPlayer(p4, {
				kind = "winOrbSpawn",
				id = id,
				position = vector
			})
		end,
		sendDespawn = function(p4, id: string)
			data.fireToPlayer(p4, {
				kind = "winOrbDespawn",
				id = id
			})
		end,
		logger = logger
	})
	local clientMessageConnection = data.clientMessage:Connect(function(p4, p5)
		if strictInterface(p5) then
			v5.handleCollect(p4, p5.id)
		end
	end)
	return function()
		clientMessageConnection:Disconnect()
		v5.stop()
	end
end

function OrbSupport.startClient(p, p2)
	local startClient = floatingOrbWins.startClient
	local orbConfig = resolveOrbConfig(p2) -- equivalent call inferred; original call site unknown
	local v4 = startClient({
		config = orbConfig,
		requestCollect = function(id: string)
			p.fireServer({
				kind = "winOrbCollect",
				id = id
			})
		end,
		logger = logger
	})
	local serverMessageConnection = p.serverMessage:Connect(function(data)
		if data.kind == "winOrbSpawn" then
			v4.handleSpawn(data.id, data.position)
		elseif data.kind == "winOrbDespawn" then
			v4.handleDespawn(data.id)
		end
	end)
	return function()
		serverMessageConnection:Disconnect()
		v4.stop()
	end
end

return OrbSupport