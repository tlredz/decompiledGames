local HolidayCollectionCore = {
	thresholdOf = function(p)
		local v = tonumber(string.match(tostring(p.Object), "^Object(%d+)$"))

		if v and not (v < 1) then
			return v
		end

		return nil
	end
}

function HolidayCollectionCore.validateKeepsakes(options, p: number)
	local result = {}
	local v = {}
	local ids = {}

	for _, v2 in ipairs(options or {}) do
		local id = v2.Id

		if type(id) == "string" and id ~= "" then
			if v[id] then
				table.insert(result, ("keepsake id %s is listed twice"):format(id))
			end

			v[id] = true
			local threshold = HolidayCollectionCore.thresholdOf(v2)

			if threshold then
				if ids[v2.Object] then
					table.insert(
						result,
						("keepsake %s: %s is already keepsake %s"):format(id, v2.Object, ids[v2.Object])
					)
				end

				ids[v2.Object] = id

				if p < threshold then
					table.insert(
						result,
						("keepsake %s needs %d pieces but MaxCollectionProgress is %d — it can never be earned"):format(
							id,
							threshold,
							p
						)
					)
				end
			else
				table.insert(
					result,
					("keepsake %s: Object %q is not an Object<n> name"):format(id, (tostring(v2.Object)))
				)
			end
		else
			table.insert(result, ("keepsake for %s has no Id"):format((tostring(v2.Object))))
		end
	end

	return result
end

function HolidayCollectionCore.piecesToNextKeepsake(options, p: number)
	local v = nil

	for _, v2 in ipairs(options or {}) do
		local threshold = HolidayCollectionCore.thresholdOf(v2)

		if threshold and p < threshold and (not v or threshold < v) then
			v = threshold
		end
	end

	return v and v - p
end

function HolidayCollectionCore.isKeepsakeEarned(p, p2, p3: number)
	if type(p) == "table" and p[p2.Id] ~= nil then
		return true
	end

	local threshold = HolidayCollectionCore.thresholdOf(p2)
	return threshold ~= nil and threshold <= p3
end

function HolidayCollectionCore:syncKeepsakes(options, p2: number, p3: number, flag: boolean?)
	local ids = {}
	local v = false

	for _, v2 in ipairs(options or {}) do
		local threshold = HolidayCollectionCore.thresholdOf(v2)

		if not (type(v2.Id) == "string" and threshold) then
			continue
		end

		if threshold <= p2 then
			if self[v2.Id] == nil then
				self[v2.Id] = p3
				table.insert(ids, v2.Id)
				v = true
			end
		elseif flag and self[v2.Id] ~= nil then
			self[v2.Id] = nil
			v = true
		end
	end

	return v, ids
end

function HolidayCollectionCore.revealedCount(value: number, max: number)
	if max <= 0 then
		return 0
	end

	return (math.clamp(math.floor(math.clamp(value, 0, 100) / 100 * max + 1e-6), 0, max))
end

function HolidayCollectionCore.progressPercentage(p: number, p2: number)
	if p2 <= 0 then
		return 0
	end

	return (math.clamp(p / p2 * 100, 0, 100))
end

function HolidayCollectionCore.isCollectableUnlocked(p, p2, flag: boolean)
	if not p2 then
		return flag
	end

	local v

	if type(p) == "table" then
		v = p[p2.StateKey]
	end

	return type(v) == "table" and v[p2.Field] ~= nil
end

function HolidayCollectionCore.meetsTutorialGate(p: number?, p2, flag: boolean?)
	return flag == true or p == nil or p <= (tonumber(p2) or 0)
end

return HolidayCollectionCore