local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local useBonusMoments = require(game.ReplicatedStorage.React.Hooks.Island.useBonusMoments)
local useAll = require(game.ReplicatedStorage.React.Hooks.Island.useAll)
local useLevel = require(game.ReplicatedStorage.React.Hooks.Player.useLevel)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local isRunning = RunService:IsRunning()
return function()
	local v = useCurrentSea()
	local v2 = useLevel()
	local v3 = useAll()
	local v4 = useBonusMoments(v)
	return React.useMemo(function()
		local result = {}

		if not v2 then
			return table.freeze({})
		end

		local function getIfBonusMomentComplete(p)
			for _, v5 in v4 do
				if v5.Sea == p.Index.Map and v5.IslandKey == p.Index.Island and v5.Name == p.Index.Key then
					return v5.IsCompleted
				end
			end

			return false
		end

		for _, v5 in v3 do
			if not Map.getIfRequirementsPass(v5, v2) or (table.find(v5.Tags, "GatewayBlocked") or table.find(
				v5.Tags,
				"NavigationBlocked"
			)) then
				continue
			end

			if table.find(v5.Tags, "Starter") or not isRunning then
				table.insert(result, v5)
			elseif Map.getIfIslandComplete(v5, getIfBonusMomentComplete) then
				table.insert(result, v5)
			end
		end

		table.freeze(result)
		return result
	end, { v3, v4, v2 })
end