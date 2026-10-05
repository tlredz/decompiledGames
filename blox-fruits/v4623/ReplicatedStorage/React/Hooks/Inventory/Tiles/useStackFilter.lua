local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemReplication = require(game.ReplicatedStorage.Util.ItemReplication)
local useDragonType = require(game.ReplicatedStorage.React.Hooks.Player.useDragonType)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
return function(list)
	local v = useConfig()
	local v2 = React.useMemo(function()
		local result = {}

		for _, v3 in ipairs(list) do
			local stackKey = ItemConfig.match(v3.ItemId):unwrap().Inventory.StackKey

			if not stackKey then
				continue
			end

			if not result[stackKey] then
				result[stackKey] = {}
			end

			table.insert(result[stackKey], v3)
		end

		for _, list2 in result do
			table.freeze(list2)
		end

		table.freeze(result)
		return result
	end, { list })
	local state, setState = React.useState({})
	local v3 = { v2, (useDragonType()) }
	React.useEffect(function()
		local function updateStackables()
			local v4 = {}

			for k, v5 in v2 do
				local v6 = {}

				for _, v7 in v5 do
					if ItemReplication.IsStackLeader.readClient(v7.ItemId, v7.NetworkedUID) then
						table.insert(v6, v7)
					end
				end

				if #v6 > 1 then
					table.sort(v6, function(a, b)
						local unwrapped = ItemConfig.match(a.ItemId):unwrap()
						local unwrapped2 = ItemConfig.match(b.ItemId):unwrap()

						if unwrapped.Inventory.StackPriority and unwrapped2.Inventory.StackPriority then
							if unwrapped.Inventory.StackPriority == unwrapped2.Inventory.StackPriority then
								return a.ItemId < b.ItemId
							end

							return unwrapped.Inventory.StackPriority > unwrapped2.Inventory.StackPriority
						else
							if unwrapped.Inventory.StackPriority then
								return true
							end

							return not unwrapped2.Inventory.StackPriority and a.ItemId < b.ItemId
						end
					end)
				end

				if not (#v6 > 0) then
					continue
				end

				local v7

				if #v6 > 0 then
					v7 = table.freeze({ v6[1] })
				end

				v4[k] = v7
			end

			table.freeze(v4)
			setState(v4)
		end

		local v4 = ItemReplication.IsStackLeader.onChanged(function(_: number, _: string?, _: boolean?)
			updateStackables()
		end)
		updateStackables()
		return function()
			v4()
		end
	end, v3)
	return (React.useMemo(function()
		local result = {}

		for _, v4 in ipairs(list) do
			local stackKey = ItemConfig.match(v4.ItemId):unwrap().Inventory.StackKey

			if stackKey and v.TileStackingDisabled ~= true then
				local v5 = state[stackKey]

				if v5 then
					local flag = false

					for _, v7 in v5 do
						if not (v4.ItemId == v7.ItemId and v4.NetworkedUID == v7.NetworkedUID) then
							continue
						end

						flag = true
						break
					end

					if flag then
						table.insert(result, v4)
					end
				end
			else
				table.insert(result, v4)
			end
		end

		table.freeze(result)
		return result
	end, { list, state, v.TileStackingDisabled }))
end