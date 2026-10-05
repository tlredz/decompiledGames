local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local v = {}

function getCache(p: string, p2)
	if v[p2] == nil then
		v[p2] = {}
	end

	local v2 = v[p2]

	if v2 then
		return v2[p]
	end

	return nil
end

function setCache(p: string, p2, p3)
	if v[p2] == nil then
		v[p2] = {}
	end

	local v2 = v[p2]

	if v2 then
		v2[p] = p3
	end
end

return function(p, p2)
	return React.useMemo(function()
		if p2 == nil then
			local v2 = p

			if typeof(v2) == "number" then
				return ItemConfig.match(v2):asNullable()
			end

			return nil
		else
			local v2 = p

			if typeof(v2) ~= "string" then
				return nil
			end

			local cache = getCache(v2, p2)

			if cache ~= nil then
				return cache
			end

			local nullable = ItemId.getId(v2, p2):asNullable()

			if not nullable then
				warn((`useItemConfig: invalid itemId for "{v2}" with idType "{p2}"`))
				return nil
			end

			local unwrapped = ItemConfig.match(nullable):unwrap()
			setCache(v2, p2, unwrapped)
			return unwrapped
		end
	end, { p, p2 })
end