local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local meteorOrbRain = require(ReplicatedStorage._FRAMEWORK.Libraries.meteorOrbRain)
require(ReplicatedStorage._FRAMEWORK.Libraries.meteorOrbRain.Types)
require(script.Parent.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local config = {
	impactDamage = 45,
	fallDriftStuds = 0,
	dropIntervalMinSeconds = 0.2,
	dropIntervalMaxSeconds = 0.2,
	dropsPerWave = 1,
	maxActiveMeteors = 8,
	orbs = {
		orbTemplate = "AdminAbuse/20Anniversary/Assets/CollectibleOrb",
		maxActivePerPlayer = 108
	}
}
local v2 = {
	source = "20thAnniversary:MeteorOrb",
	multiplier = 0.5
}

local function collectZones(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local zones

	if scriptables then
		zones = scriptables:FindFirstChild("Zones")
	end

	local meteorZones

	if zones then
		meteorZones = zones:FindFirstChild("MeteorZones")
	end

	if not meteorZones then
		if zones then
			meteorZones = zones:FindFirstChild("WandererZones")
		else
			meteorZones = nil
		end
	end

	local parts = {}

	if meteorZones then
		for _, part in meteorZones:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end
	end

	return parts
end

local function getMeteorTemplate(instance, p: number)
	local child

	if instance then
		child = instance:FindFirstChild((tostring(p)))
	end

	if child then
		return (child:FindFirstChild("Meteor"))
	end

	return nil
end

local MeteorSupport = {}

function MeteorSupport.start(data, p: number, p2)
	local v3 = collectZones(p2)

	if #v3 == 0 then
		logger:warn(string.format(
			"20th Anniversary Year %d map requires Scriptables.Zones.MeteorZones (or WandererZones) with BaseParts for the meteors to land on",
			p
		))
		return function() end
	end

	local v4 = meteorOrbRain.startServer({
		config = config,
		getZones = function()
			return v3
		end,
		isPlayerEligible = data.isParticipant,
		awardWin = AAEventWinAward.create(v2),
		send = data.fireToPlayer,
		logger = logger
	})
	local clientMessageConnection = data.clientMessage:Connect(function(p3, p4)
		v4.handleMessage(p3, p4)
	end)
	return function()
		clientMessageConnection:Disconnect()
		v4.stop()
	end
end

function MeteorSupport.startClient(data, p: number)
	local startClient = meteorOrbRain.startClient
	local v3 = {
		config = config,
		meteorTemplate = 0,
		send = 0,
		logger = 0
	}
	local yearAssets = data.yearAssets
	local child

	if yearAssets then
		child = yearAssets:FindFirstChild((tostring(p)))
	end

	local meteorTemplate

	if child then
		meteorTemplate = child:FindFirstChild("Meteor")
	end

	v3.meteorTemplate = meteorTemplate
	v3.send = data.fireServer
	v3.logger = logger
	local v5 = startClient(v3)
	local serverMessageConnection = data.serverMessage:Connect(function(p2)
		v5.handleMessage(p2)
	end)
	return function()
		serverMessageConnection:Disconnect()
		v5.stop()
	end
end

return MeteorSupport