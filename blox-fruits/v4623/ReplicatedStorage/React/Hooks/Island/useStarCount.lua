local React = require(game.ReplicatedStorage.Packages.React)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local useBonusMoments = require(game.ReplicatedStorage.React.Hooks.Island.useBonusMoments)
return function(p, p2)
	local v = useBonusMoments(p, p2)
	local v2 = React.useMemo(function()
		local result = {}

		for _, v3 in Map.DEFINITIONS do
			if not p or v3.Key == p then
				table.insert(result, v3)
			end
		end

		table.freeze(result)
		return result
	end, { p })
	local v3 = React.useMemo(function()
		local islands = {}

		for _, v4 in v2 do
			for _, island in v4.Islands do
				if not p2 or island.Index.Key == p2 then
					table.insert(islands, island)
				end
			end
		end

		table.freeze(islands)
		return islands
	end, { p2, v2 })
	local v4 = React.useMemo(function()
		local bonusMoments = {}

		for _, v5 in v3 do
			if not v5.BonusMoments then
				continue
			end

			for _, bonusMoment in v5.BonusMoments do
				table.insert(bonusMoments, bonusMoment)
			end
		end

		table.freeze(bonusMoments)
		return bonusMoments
	end, { v3 })
	local v5 = React.useMemo(function()
		local count = 0

		for _, _ in v4 do
			count += 1
		end

		return count
	end, { v4 })
	return React.useMemo(function()
		local count = 0

		for _, v6 in v do
			if v6.IsCompleted then
				count += 1
			end
		end

		return count
	end, { v }), v5
end