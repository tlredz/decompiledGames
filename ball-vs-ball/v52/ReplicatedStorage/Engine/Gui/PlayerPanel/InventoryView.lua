local InventoryEntries = require(game.ReplicatedStorage.Engine.Gui.Inventory.InventoryEntries)
local InventoryView = {
	kind = function(p)
		if typeof(p.serial) == "number" then
			return "Rainbow"
		end

		if typeof(p.killCount) == "number" then
			return "Shiny"
		end

		return "Classic"
	end,
	build = function(items, p, isBall)
		local groups = {}
		local aggregates = {}

		for _, item in items do
			local config = p.byCnId[item.cnId]

			if not config then
				continue
			end

			local v4 = {
				key = item.instanceId,
				instanceId = item.instanceId,
				item = table.clone(item),
				config = config,
				isBall = isBall,
				serial = item.serial,
				killCount = item.killCount,
				tradable = item.tradable
			}
			local v5 = groups[item.cnId]

			if not v5 then
				v5 = {}
				groups[item.cnId] = v5
			end

			table.insert(v5, v4)
		end

		for k, list in groups do
			table.sort(list, InventoryEntries.compareCopies)
			local v3 = nil

			for _, v5 in list do
				if v5.item.equipped ~= true then
					continue
				end

				v3 = v5
				break
			end

			if not v3 then
				for _, v6 in list do
					if v6.item.listed then
						continue
					end

					v3 = v6
					break
				end
			end

			local v5 = v3 or list[1]
			table.insert(aggregates, {
				key = "group:" .. k,
				cnId = k,
				item = table.clone(v5.item),
				config = v5.config,
				isBall = isBall,
				count = #list,
				aggregate = true
			})
		end

		table.sort(aggregates, function(a, b)
			if a.config.rating == b.config.rating then
				return a.config.cnId < b.config.cnId
			end

			return a.config.rating > b.config.rating
		end)
		return {
			groups = groups,
			aggregates = aggregates
		}
	end
}

function InventoryView.filter(list, p, p2)
	local result = {
		All = #list,
		Classic = 0,
		Shiny = 0,
		Rainbow = 0
	}
	local result2 = {}

	for _, v in list do
		local kind = InventoryView.kind(v)
		result[kind] += 1

		if not p2 or p == "All" or p == kind then
			table.insert(result2, v)
		end
	end

	return result2, result
end

return InventoryView