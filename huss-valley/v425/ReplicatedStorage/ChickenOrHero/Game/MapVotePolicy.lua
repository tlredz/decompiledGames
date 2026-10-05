local MapVotePolicy = {
	count = function(items, items2)
		local result = {}

		for _, item in items do
			result[item.id] = 0
		end

		for _, item in items2 do
			if result[item] then
				result[item] += 1
			end
		end

		return result
	end
}

function MapVotePolicy.choose(items, p, p2, p3)
	local count = MapVotePolicy.count(items, p)
	local v = 0
	local ids = {}

	for _, item in items do
		local v2 = count[item.id]

		if v < v2 then
			ids = { item.id }
			v = v2
		elseif v2 == v then
			table.insert(ids, item.id)
		end
	end

	if v == 0 then
		return p2, "No votes — staying here."
	end

	if table.find(ids, p2) then
		if #ids > 1 then
			return p2, "Tie — keeping the current map."
		end

		return p2, "Your next arena."
	else
		local v2 = ids[(p3 or Random.new()):NextInteger(1, #ids)]

		if #ids > 1 then
			return v2, "Chosen from the tied maps."
		end

		return v2, "Your next arena."
	end
end

return MapVotePolicy