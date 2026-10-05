local v = {
	Balloon = table.freeze({
		"Orange Balloon",
		"Green Balloon",
		"Blue Balloon",
		"Red Balloon",
		"Pink Balloon",
		"Rainbow Balloon"
	}),
	Egg = table.freeze({
		"Orange Egg",
		"Green Egg",
		"Blue Egg",
		"Pink Egg"
	}),
	Bee = table.freeze({
		"Bee",
		"Fire Bee",
		"Ice Bee",
		"Queen Bee"
	})
}
local lists = {}

for _, list in pairs(v) do
	for _, v2 in ipairs(list) do
		lists[v2] = list
	end
end

return table.freeze({
	GetExclusiveGroup = function(p: string)
		return lists[p]
	end,
	HasTraitFromGroup = function(list, p: string)
		local v2 = v[p]

		if not v2 then
			return false
		end

		for _, v3 in ipairs(list) do
			if table.find(v2, v3) then
				return true
			end
		end

		return false
	end,
	CanAddTrait = function(list, p: string)
		local v2 = lists[p]

		if not v2 then
			return true
		end

		for _, v3 in ipairs(list) do
			if table.find(v2, v3) then
				return false
			end
		end

		return true
	end,
	PoolExclusiveChances = function(p)
		for _, list in pairs(v) do
			local v2 = {}
			local v3 = 0

			for _, v4 in ipairs(list) do
				local v5 = p[v4]

				if not v5 then
					continue
				end

				table.insert(v2, v4)

				if v3 < v5 then
					v3 = v5
				end
			end

			if #v2 <= 1 then
				continue
			end

			local v4 = v3 / #v2

			for _, v5 in ipairs(v2) do
				p[v5] = v4
			end
		end

		return p
	end,
	DeduplicateExclusiveTraits = function(list, p)
		local v2 = p or Random.new()

		for _, list2 in pairs(v) do
			local v3 = {}

			for i, v4 in ipairs(list) do
				if table.find(list2, v4) then
					table.insert(v3, i)
				end
			end

			if #v3 <= 1 then
				continue
			end

			local v4 = v3[v2:NextInteger(1, #v3)]

			for i = #v3, 1, -1 do
				if v3[i] ~= v4 then
					table.remove(list, v3[i])
				end
			end
		end

		return list
	end
})