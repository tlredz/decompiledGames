local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local PlaceRegistry = require(ReplicatedStorage.Config.PlaceRegistry)
local Signal = require(ReplicatedStorage.Utilities.Signal)
require(script.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

-- equivalent calls inferred from this helper; original call sites unknown
local function newEntry(configKey: string)
	return {
		configKey = configKey,
		variant = nil,
		enrolling = false
	}
end

local function ensureEntry(p, configKey: string)
	local entry = p.entries[configKey]

	if not entry then
		entry = newEntry(configKey)
		p.entries[configKey] = entry
	end

	return entry
end

local function fetchValue(p, p2: string)
	local ConfigService = game:GetService("ConfigService")
	return ConfigService:GetConfigForPlayerAsync(p):GetValue(p2)
end

local function readVariant(player, data)
	local controlGroup = data.controlGroup

	if RunService:IsStudio() and data.studioForce then
		return data.studioForce
	end

	local success, result = pcall(fetchValue, player, data.configKey)

	if not success then
		logger:warn(string.format(
			"ConfigService fetch failed for %s (%s): %s",
			data.configKey,
			player.Name,
			(tostring(result))
		))
		return controlGroup
	end

	if table.find(data.variantGroups, result) then
		controlGroup = result
	end

	return controlGroup
end

local function applyFetchedVariant(data, session, entry)
	local variant = readVariant(data.player, session)

	if data.player.Parent then
		entry.enrolling = false
		entry.variant = variant
		data.remotes.variantAssigned:fire(data.player, entry.configKey, variant)

		if PlaceRegistry.isTestPlace() then
			logger:print(string.format(
				"[ABT] %s is assigned variant group %q in experiment %q",
				data.player.Name,
				variant,
				entry.configKey
			))
		end
	end
end

local PlayerExperimentCard = {}
PlayerExperimentCard.__index = PlayerExperimentCard

function PlayerExperimentCard.new(player, remotes, sessions)
	local assigned = Signal.new()
	local self = setmetatable({
		player = player,
		remotes = remotes,
		sessions = sessions,
		entries = {},
		_assigned = assigned,
		_janitor = Janitor.new()
	}, PlayerExperimentCard)
	self._janitor:Add(assigned, "Destroy")
	return self
end

function PlayerExperimentCard:enroll(p: string)
	local session = self.sessions[p]
	local configKey = session.configKey
	local entry = self.entries[configKey]

	if not entry then
		entry = newEntry(configKey)
		self.entries[configKey] = entry
	end

	if entry.variant then
		self.remotes.variantAssigned:fire(self.player, entry.configKey, entry.variant)
	elseif not entry.enrolling then
		entry.enrolling = true
		self._janitor:Add(task.spawn(function()
			applyFetchedVariant(self, session, entry)
		end))
	end
end

function PlayerExperimentCard.requestEnrollment(p, configKey: string)
	local entry = p.entries[configKey]

	if not entry then
		entry = newEntry(configKey)
		p.entries[configKey] = entry
	end

	if not entry.enrolling then
		entry.enrolling = true
		p.remotes.requestEnrollment:fire(configKey)
	end
end

function PlayerExperimentCard:receiveAssignment(configKey: string, variant: string)
	local entry = self.entries[configKey]

	if not entry then
		entry = newEntry(configKey)
		self.entries[configKey] = entry
	end

	entry.variant = variant
	self._assigned:Fire(configKey, variant)
end

function PlayerExperimentCard.getPlayerVariantGroup(p, p2: string)
	local entry = p.entries[p2]
	local controlGroup = p.sessions[p2].controlGroup

	if entry and entry.variant then
		controlGroup = entry.variant
	end

	return controlGroup
end

function PlayerExperimentCard.isPlayerEnrolled(p, p2: string)
	local entry = p.entries[p2]
	return entry ~= nil and entry.variant ~= nil
end

function PlayerExperimentCard:onVariantAssigned(p2: string, callback)
	local connection = self._assigned:Connect(function(p3: string, p4: string)
		if p3 == p2 then
			callback(p4)
		end
	end)
	return function()
		connection:Disconnect()
	end
end

function PlayerExperimentCard:Destroy()
	self._janitor:Destroy()
end

return PlayerExperimentCard