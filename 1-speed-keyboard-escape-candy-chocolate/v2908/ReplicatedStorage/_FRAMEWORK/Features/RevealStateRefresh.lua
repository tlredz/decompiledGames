local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local RevealRegistry = require(ReplicatedStorage._FRAMEWORK.Libraries.RevealRegistry)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local random = Random.new()
local RevealStateRefresh = {}
local v = nil
local v2 = 1e999
local thread = nil
local v3 = {}
local v4 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function checkServer()
	assert(RunService:IsServer(), "Reveal state refresh is server-only.")
end

local function collectRequiredNames()
	local result = {}

	for _, tag in { "RevealPart", "RevealUI" } do
		for _, v5 in CollectionService:GetTagged(tag) do
			local name = v5:GetAttribute("Name")

			if type(name) == "string" and name ~= "" then
				result[name] = true
			end
		end
	end

	if #CollectionService:GetTagged("ConcertPosterReveal") > 0 then
		result.ConcertPosters = true
	end

	for _, moduleScript in ReplicatedStorage.Config.Worlds:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local module = require(moduleScript)

		if module.DISPLAY and module.DISPLAY.REVEAL_NAME then
			result[module.DISPLAY.REVEAL_NAME] = true
		end

		if not (module.PROGRESSION and module.PROGRESSION.WIN_BLOCK_REVEAL_LOCKS) then
			continue
		end

		for _, v5 in module.PROGRESSION.WIN_BLOCK_REVEAL_LOCKS do
			result[v5] = true
		end
	end

	local AuraConfig = require(ReplicatedStorage.FeatureConfigs.AuraConfig)
	local TrailConfig = require(ReplicatedStorage.FeatureConfigs.TrailConfig)
	local EventsConfig = require(ReplicatedStorage.EventsConfig)

	for _, v5 in { AuraConfig.AURAS, TrailConfig.TRAILS, EventsConfig.Trails } do
		for _, v6 in v5 do
			if v6.reveal then
				result[v6.reveal] = true
			end
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isComplete()
	for k in v3 do
		if not RevealRegistry.isRevealed(k) then
			return false
		end
	end

	return true
end

local function runRefresh(callback)
	local success, result, v5 = pcall(function()
		local v6 = callback()
		local v7

		if v6 then
			for k in v3 do
				if not RevealRegistry.isRevealed(k) then
					return v6, false
				end
			end

			v7 = true
		else
			v7 = v6
		end

		return v6, v7
	end)
	thread = nil

	if success and result then
		v4 = true

		if v5 then
			RevealStateRefresh.stop()
		else
			v2 = os.clock() + 1800
		end
	else
		v2 = os.clock() + random:NextNumber(60, 120)
	end

	if not success then
		logger.warn(logger, string.format("Reveal state refresh failed: %s", (tostring(result))))
	end
end

function RevealStateRefresh.start(callback, flag: boolean)
	checkServer() -- equivalent call inferred; original call site unknown
	v3 = collectRequiredNames()
	v4 = flag

	if v4 then
		-- equivalent call inferred; original call site unknown
		if isComplete() then
			RevealStateRefresh.stop()
			return
		end
	end

	v = callback
	local v5

	if flag then
		v5 = random:NextNumber(0, 1800)
	else
		v5 = random:NextNumber(60, 120)
	end

	v2 = os.clock() + v5
end

function RevealStateRefresh.stop()
	v = nil
	v2 = 1e999

	if thread then
		task.cancel(thread)
		thread = nil
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsServer() then
			game:BindToClose(RevealStateRefresh.stop)
		end
	end,
	OnUpdate = function()
		local v5 = v

		if v5 and thread == nil then
			local now = os.clock()

			if v2 <= now then
				if v4 then
					-- equivalent call inferred; original call site unknown
					if isComplete() then
						RevealStateRefresh.stop()
						return
					end
				end

				thread = task.defer(runRefresh, v5)
			end
		end
	end
})
return RevealStateRefresh