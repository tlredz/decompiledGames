local DealResolver = {}

function DealResolver.ownershipFromTables(options, options2)
	local v = {}
	local v2 = {}

	for _, v3 in ipairs(options or {}) do
		if v3[1] then
			v[v3[1]] = true
		end
	end

	for _, v3 in ipairs(options2 or {}) do
		if v3[1] then
			v2[v3[1]] = true
		end
	end

	return {
		ownsTower = function(p)
			return v[p] == true
		end,
		ownsTrinket = function(p)
			return v2[p] == true
		end
	}
end

function DealResolver.resolve(p, p2)
	local result = {}

	for _, v in ipairs(p.always or {}) do
		table.insert(result, {
			kind = v.kind,
			id = v.id,
			amount = v.amount
		})
	end

	for _, v in ipairs(p.items or {}) do
		local v2 = false

		if v.kind == "Tower" then
			v2 = p2.ownsTower(v.id)
		elseif v.kind == "Trinket" then
			v2 = p2.ownsTrinket(v.id)
		end

		if v2 then
			if v.ifOwned then
				table.insert(result, {
					kind = v.ifOwned.kind,
					id = v.ifOwned.id,
					amount = v.ifOwned.amount,
					substituted = true,
					originalKind = v.kind,
					originalId = v.id,
					originalDisplayName = v.displayName
				})
			end
		else
			table.insert(result, {
				kind = v.kind,
				id = v.id,
				amount = v.amount,
				displayName = v.displayName
			})
		end
	end

	return result
end

return DealResolver