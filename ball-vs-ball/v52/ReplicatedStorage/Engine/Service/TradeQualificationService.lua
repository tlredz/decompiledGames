local Players = game:GetService("Players")
local Config = require(script.Parent.Config)
local ExperienceService = require(script.Parent.ExperienceService)
local PlayerData = require(script.Parent.PlayerData)
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getRequiredLevel()
	local allowTradeLvl = Config.misc and Config.misc.allowTradeLvl

	if typeof(allowTradeLvl) == "number" and allowTradeLvl >= 1 then
		return (math.floor(allowTradeLvl))
	end

	return 10
end

local TradeQualificationService = {
	getEligibility = function(p)
		local total = PlayerData.server[p].exp.total()
		local level = ExperienceService.getLevelInfo(total).level
		local requiredLevel = getRequiredLevel() -- equivalent call inferred; original call site unknown
		return {
			ok = requiredLevel <= level,
			level = level,
			requiredLevel = requiredLevel
		}
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function checkAutoGrant(p, p2: number, p3: number)
	local requiredLevel = getRequiredLevel() -- equivalent call inferred; original call site unknown
	local level = ExperienceService.getLevelInfo(p2).level
	local level2 = ExperienceService.getLevelInfo(p3).level

	if level < requiredLevel and requiredLevel <= level2 then
		PlayerData.server[p].tradeRequestsEnabled(true)
	end
end

function TradeQualificationService.init()
	if flag then
		return
	end

	flag = true
	local v = {}

	local function observePlayer(p)
		task.spawn(function()
			PlayerData.server.Service:waitForData(p)

			if p.Parent ~= Players then
				return
			end

			v[p] = PlayerData.server[p].exp.total.Changed(function(p2, p3)
				checkAutoGrant(p, p3, p2) -- equivalent call inferred; original call site unknown
			end)
		end)
	end

	local function stopObservingPlayer(p)
		local v2 = v[p]
		v[p] = nil

		if v2 then
			v2()
		end
	end

	Players.PlayerAdded:Connect(observePlayer)
	Players.PlayerRemoving:Connect(stopObservingPlayer)

	for _, v2 in ipairs(Players:GetPlayers()) do
		local v3 = v2
		task.spawn(function()
			PlayerData.server.Service:waitForData(v3)

			if v3.Parent ~= Players then
				return
			end

			v[v3] = PlayerData.server[v3].exp.total.Changed(function(p, p2)
				checkAutoGrant(v3, p2, p) -- equivalent call inferred; original call site unknown
			end)
		end)
	end
end

return TradeQualificationService