game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
game:GetService("Players")
local LeaderboardManager = require(script.Parent.LeaderboardManager)
local remotes = ReplicatedStorage.Remotes
local AbilityIds = require(ReplicatedStorage.Shared.AbilityIds)
local idsToAbilities = AbilityIds.IdsToAbilities
require(ReplicatedStorage.Packages.Promise)
local PlayerData = require(ReplicatedStorage.Shared.PlayerData)
local PlayerUtility = require(ReplicatedStorage.Shared.PlayerUtility)
local ParseRankedValue = require(ReplicatedStorage.Common.ParseRankedValue)
local RankedSignalController = require(ReplicatedStorage.Controllers.Ranked.RankedSignalController)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local rankType = ServerInfo:GetRankType()
RankedSignalController:GetUpdateRankedMenuSignal()
local v = {
	FFA = remotes.FetchTop100Leaderboard:InvokeServer("EloFFA") or {},
	["2v2 Duos"] = remotes.FetchTop100Leaderboard:InvokeServer("EloDuo") or {},
	["1v1s"] = remotes.FetchTop100Leaderboard:InvokeServer("EloDuel") or {}
}
Instance.new("BindableEvent")

local function FetchUsernames(_)
	return function(p)
		return PlayerUtility:GetUsername(p)
	end
end

local v2 = {
	FFA = Instance.new("BindableEvent"),
	["2v2 Duos"] = Instance.new("BindableEvent"),
	["1v1s"] = Instance.new("BindableEvent")
}

local function RegisterLeaderboard()
	for k, v3 in next, v, nil do
		local v4 = v3
		local v5 = k
		task.spawn(function()
			local v6 = {}
			local v7 = {}

			for k2, v8 in next, v4, nil do
				local userId, v10, v11, elo, v13, games, v15 = ParseRankedValue(v8.key, v8.value)

				if userId == false then
					continue
				end

				v6[k2] = userId
				local elo2 = elo
				local userId2 = userId
				local v18 = v10
				local v19 = v11
				local v20 = v13
				local games2 = games
				local v22 = v15
				local v23 = k2
				v2[v5].Event:Once(function(callback)
					local v24 = {
						Elo = elo2,
						Player = callback(userId2),
						UserId = userId2,
						Region = v18 or "",
						Country = v19 or "",
						AveragePlacement = v20 / games2,
						MostUsedAbility = idsToAbilities[v22],
						Games = games2
					}
					v7[v23] = PlayerData.RegisterPlayer(v24)
				end)
			end

			v2[v5]:Fire(function(p)
				return PlayerUtility:GetUsername(p)
			end)
			LeaderboardManager.LoadPlayerList(v7, v5, rankType)
		end)
	end
end

local FFlagClient = require(game.ReplicatedStorage.ClientGameModules.FFlagClient)
task.spawn(function()
	task.wait(5)

	while true do
		if FFlagClient:GetKey("LeaderboardRankedEnabled") then
			v = {
				FFA = remotes.FetchTop100Leaderboard:InvokeServer("EloFFA") or {},
				["2v2 Duos"] = remotes.FetchTop100Leaderboard:InvokeServer("EloDuo") or {},
				["1v1s"] = remotes.FetchTop100Leaderboard:InvokeServer("EloDuel") or {}
			}
			RegisterLeaderboard()
		end

		task.wait(300)
	end
end)
LeaderboardManager.InitiateTimer()
return nil