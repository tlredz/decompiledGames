local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExperienceService = require(ReplicatedStorage.Engine.Service.ExperienceService)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local server = PlayerData.server
local flag = false
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function syncLevel(instance)
	if instance.Parent ~= Players then
		return
	end

	local total = server[instance].exp.total()
	instance:SetAttribute("PlayerListLevel", ExperienceService.getLevelInfo(total).level)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncTradeRequests(instance)
	if instance.Parent ~= Players then
		return
	end

	instance:SetAttribute("TradeRequestsEnabled", server[instance].tradeRequestsEnabled() == true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncWinStreak(instance)
	if instance.Parent ~= Players then
		return
	end

	instance:SetAttribute("PlayerListWinStreak", server[instance].winStreak())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncDiamonds(instance)
	if instance.Parent ~= Players then
		return
	end

	instance:SetAttribute("PlayerListDiamonds", server[instance].diamonds())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncTitle(instance)
	if instance.Parent ~= Players then
		return
	end

	instance:SetAttribute("PlayerListTitle", server[instance].equippedTitle())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function observePlayer(p)
	task.spawn(function()
		server.Service:waitForData(p)

		if p.Parent ~= Players then
			return
		end

		syncLevel(p) -- equivalent call inferred; original call site unknown
		syncTradeRequests(p) -- equivalent call inferred; original call site unknown
		syncWinStreak(p) -- equivalent call inferred; original call site unknown
		syncDiamonds(p) -- equivalent call inferred; original call site unknown
		syncTitle(p) -- equivalent call inferred; original call site unknown
		v[p] = {
			server[p].exp.total.Changed(function()
				syncLevel(p) -- equivalent call inferred; original call site unknown
			end),
			server[p].tradeRequestsEnabled.Changed(function()
				syncTradeRequests(p) -- equivalent call inferred; original call site unknown
			end),
			server[p].winStreak.Changed(function()
				syncWinStreak(p) -- equivalent call inferred; original call site unknown
			end),
			server[p].diamonds.Changed(function()
				syncDiamonds(p) -- equivalent call inferred; original call site unknown
			end),
			server[p].equippedTitle.Changed(function()
				syncTitle(p) -- equivalent call inferred; original call site unknown
			end)
		}
	end)
end

local function stopObservingPlayer(p)
	local v2 = v[p]
	v[p] = nil

	if v2 then
		for _, v3 in ipairs(v2) do
			v3()
		end
	end
end

return {
	init = function()
		if flag then
			return
		end

		flag = true
		Players.PlayerAdded:Connect(observePlayer)
		Players.PlayerRemoving:Connect(stopObservingPlayer)

		for _, v2 in ipairs(Players:GetPlayers()) do
			observePlayer(v2) -- equivalent call inferred; original call site unknown
		end
	end
}