local InventoryEntries = {
	compareCopies = function(data, data2)
		local v = typeof(data.serial) ~= "number" and 1e999 or data.serial
		local v2 = typeof(data2.serial) ~= "number" and 1e999 or data2.serial

		if v ~= v2 then
			return v < v2
		end

		local v3 = typeof(data.killCount) ~= "number" and -1e999 or data.killCount
		local v4 = typeof(data2.killCount) ~= "number" and -1e999 or data2.killCount

		if v3 ~= v4 then
			return v4 < v3
		end

		if data.tradable == true == (data2.tradable == true) then
			return tostring(data.instanceId or data.key) < tostring(data2.instanceId or data2.key)
		end

		return data.tradable == true
	end,
	preferred = function(list, p)
		for _, v in list do
			if v.instanceId == p then
				return v
			end
		end

		for _, v in list do
			if not (v.locked or v.listed) then
				return v
			end
		end

		return list[1]
	end,
	equippedId = function(p, p2, p3)
		if type(p) ~= "table" then
			return nil
		end

		if p2 == "Ball" then
			p2 = "BallCopy:" .. p3
		end

		return p[p2]
	end
}

function InventoryEntries.aggregate(items, p, p2, p3)
	local v = {}
	local clones = {}

	for _, item in items do
		local cnId = item.config.cnId

		if not v[cnId] then
			v[cnId] = {}
		end

		table.insert(v[cnId], item)
	end

	for k, list in v do
		table.sort(list, InventoryEntries.compareCopies)
		local clone = table.clone(InventoryEntries.preferred(list, InventoryEntries.equippedId(p, p2, k)))
		clone.key = p3 .. ":" .. k
		clone.count = #list
		table.insert(clones, clone)
	end

	return clones
end

return InventoryEntries