local React = require(game.ReplicatedStorage.Packages.React)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local useBonusMoments = require(game.ReplicatedStorage.React.Hooks.Island.useBonusMoments)
local useGatewayAccess = require(game.ReplicatedStorage.React.Hooks.Player.useGatewayAccess)
local useAll = require(game.ReplicatedStorage.React.Hooks.Island.useAll)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
return function()
	local v = useCurrentSea()
	local v2 = useAll()
	local v3 = useGatewayAccess()
	local v4 = useBonusMoments(v)
	return React.useMemo(function()
		local function getIfBonusMomentComplete(p)
			for _, v5 in v4 do
				if v5.Sea == p.Index.Map and v5.IslandKey == p.Index.Island and v5.Name == p.Index.Key then
					return v5.IsCompleted
				end
			end

			return false
		end

		local result = {}

		for _, v5 in v2 do
			if v3 and table.find(v5.Tags, "Starter") then
				table.insert(result, v5)
			elseif Map.getIfIslandComplete(v5, getIfBonusMomentComplete) then
				table.insert(result, v5)
			end
		end

		table.freeze(result)
		return result
	end, { v2, v4, v3 })
end