local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.PseudoEnum)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useAll = require(game.ReplicatedStorage.React.Hooks.Item.Upgrades.useAll)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
local useCurrentSortType = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentSortType)
local useAll2 = require(game.ReplicatedStorage.React.Hooks.Item.Favorited.useAll)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
return function(p)
	local v, _ = useCurrentSortType()
	local v2 = useConfig()
	local v3, _ = useCurrentGroup()
	local brackets = v2.Layout[v3].Brackets
	local v4 = useAll2()
	local v5 = useAll()
	return React.useMemo(function()
		local clone = table.clone(p)
		local v6 = {}

		for k, bracket in brackets do
			v6[bracket] = #brackets - k + 1
		end

		local v7 = {}

		for _, v8 in v5 do
			v7[v8.NetworkedUID or v8.ItemId] = v8
		end

		local v8 = {}

		for _, v9 in v4 do
			v8[v9.NetworkedUID or v9.ItemId] = v9
		end

		local v9 = {}
		local v10 = {}
		local sortPriorities = {}
		local v11 = {}
		local v12 = {}
		local rarityValues = {}
		local v13 = {}
		local skillRedirects = {}

		for _, v14 in clone do
			local unwrapped = ItemConfig.match(v14.ItemId):unwrap()
			local v15

			if v14.NetworkedUID then
				v15 = v7[v14.NetworkedUID]
			else
				v15 = v7[v14.ItemId]
			end

			local v16

			if v14.NetworkedUID then
				v16 = v8[v14.NetworkedUID]
			else
				v16 = v8[v14.ItemId]
			end

			local formatted = `{v14.ItemId}-{v14.NetworkedUID}`
			v9[formatted] = v16 and v16.Value and v2.FavoritingEnabled and 1 or 0
			v10[formatted] = v15 and v15.Value or nil
			sortPriorities[formatted] = unwrapped.Inventory.SortPriority or 0

			for _, bracket in unwrapped.Inventory.Brackets do
				local v17 = v6[bracket] or 0

				if (v11[formatted] or 0) < v17 or #unwrapped.Inventory.Brackets == 0 then
					v11[formatted] = v17
				end
			end

			if unwrapped.Index.IdType == "PhysicalMoveset" then
				v12[formatted] = unwrapped.Quality.MoneyPrice or 1e999
			else
				v12[formatted] = -1
			end

			rarityValues[formatted] = unwrapped.Quality.RarityValue or -1
			local skillRedirect = nil

			if unwrapped.Index.IdType == "PhysicalMoveset" then
				local nullable = ItemConfig.Query.selectOne({
					Index = {
						IdType = "Moveset"
					},
					Moveset = {
						Physical = unwrapped.Index.ItemId
					}
				}):asNullable()

				if not nullable then
					local nullable2 = ItemConfig.Query.selectOne({
						Index = {
							IdType = "Skin"
						},
						Skin = {
							Physical = unwrapped.Index.ItemId
						}
					}):asNullable()

					if nullable2 and nullable2.Skin then
						if not nullable2.Skin.IsDefault then
							v13[formatted] = (v13[formatted] or 0) + 1
						end

						nullable = ItemConfig.match(nullable2.Skin.Adornee):asNullable()
					end

					if not nullable then
						local nullable3 = ItemConfig.Query.selectOne({
							Index = {
								IdType = "Mutation"
							},
							Mutation = {
								Physical = unwrapped.Index.ItemId
							}
						}):asNullable()

						if nullable3 and nullable3.Mutation then
							nullable = ItemConfig.match(nullable3.Mutation.Adornee):asNullable()
						end
					end
				end

				if nullable then
					if nullable.Moveset and nullable.Moveset.SkillRedirect then
						skillRedirect = nullable.Moveset.SkillRedirect
					else
						skillRedirect = nullable.Index.ItemId
					end
				end
			end

			if not skillRedirect then
				continue
			end

			local unwrapped2 = ItemConfig.match(skillRedirect):unwrap()

			if unwrapped2.Variant.VariantOf and unwrapped2.Variant.Mutation then
				v13[formatted] = (v13[formatted] or 0) + 1
				unwrapped2 = ItemConfig.match(unwrapped2.Variant.VariantOf):unwrap()
				skillRedirect = unwrapped2.Index.ItemId
			end

			if skillRedirects[formatted] or skillRedirect > 0 then
				skillRedirects[formatted] = skillRedirect
			end

			if unwrapped.Index.IdType ~= "PhysicalMoveset" then
				continue
			end

			local v17 = unwrapped2.Moveset and unwrapped2.Moveset.Physical and ItemConfig.match(unwrapped2.Moveset.Physical):unwrap() or nil

			if v17 then
				v12[formatted] = v17.Quality.MoneyPrice or v12[formatted]
			end
		end

		local v14 = {
			v9,
			v11,
			sortPriorities,
			v10,
			rarityValues,
			v12,
			skillRedirects,
			v13
		}
		table.sort(clone, function(a, b)
			local formatted = `{a.ItemId}-{a.NetworkedUID}`
			local formatted2 = `{b.ItemId}-{b.NetworkedUID}`

			-- equivalent calls inferred from this helper; original call sites unknown
			local function fill(p2)
				if p2[formatted] == nil then
					p2[formatted] = 0
				end

				if p2[formatted2] == nil then
					p2[formatted2] = 0
				end
			end

			for _, v15 in v14 do
				fill(v15) -- equivalent call inferred; original call site unknown
			end

			local sort

			sort = function(p2: number)
				local v15 = v14[p2]

				if p2 == #v14 or v15[formatted] ~= v15[formatted2] then
					return v15[formatted] > v15[formatted2]
				end

				return sort(p2 + 1)
			end

			return sort(1)
		end)
		return clone
	end, {
		p,
		v,
		brackets,
		v5,
		v4,
		v2.FavoritingEnabled
	})
end