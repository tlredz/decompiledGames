local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Economy.ItemId)
local AssetItemData = require(game.ReplicatedStorage.Util.AssetItemData)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useAssetData = require(game.ReplicatedStorage.React.Hooks.Item.useAssetData)
local useDynamicAccessories = require(game.ReplicatedStorage.React.Hooks.Player.useDynamicAccessories)
return function(value, p, p2: string?)
	local v2

	if typeof(value) ~= "number" then
		v2 = p
	end

	local v3 = useMatch(value, v2)
	local v5

	if typeof(value) ~= "number" then
		v5 = p
	end

	local v6 = useAssetData(value, v5)

	if typeof(value) == "number" then
		p2 = p
	end

	local v7 = useDynamicAccessories()
	local v8 = React.useMemo(function()
		if v7 and p2 then
			return v7[p2]
		end

		return nil
	end, { v7, p2 })
	local v9 = React.useMemo(function()
		if v8 == nil then
			return nil
		end

		local result = {}
		local buffsForItem = AccessoriesShared.GetBuffsForItem(v8, true)

		if buffsForItem then
			for k, v10 in buffsForItem do
				if type(v10) ~= "number" then
					continue
				end

				local v11 = AssetItemData.fromLegacyName(k)

				if v11:isErr() then
					continue
				end

				local solve = AssetItemData.solve(v11:unwrap(), v10)

				if not solve:isErr() then
					table.insert(result, solve:unwrap())
				end
			end
		end

		table.freeze(result)
		return result
	end, { v8 })
	return (React.useMemo(function()
		if value == nil then
			return nil
		end

		local result = {}

		if v6 and v6.Stats then
			for _, stat in v6.Stats do
				table.insert(result, stat)
			end
		end

		if v9 then
			for _, v10 in v9 do
				table.insert(result, v10)
			end
		end

		table.freeze(result)
		return result
	end, {
		v6,
		p2,
		v3,
		v9
	}))
end