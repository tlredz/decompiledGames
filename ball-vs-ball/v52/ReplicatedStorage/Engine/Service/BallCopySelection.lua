local BallCopySelection = {
	PROGRESS_TARGET = 10,
	slotKey = function(p)
		return "BallCopy:" .. p
	end,
	available = function(p)
		return type(p) == "table" and (type(p.locks) ~= "table" or next(p.locks) == nil)
	end
}

function BallCopySelection.resolve(items, p, p2)
	local v

	if type(p) == "table" then
		v = p[BallCopySelection.slotKey(p2)]
	else
		v = false
	end

	local v2 = v and items[v]

	if v2 and v2.itemType == "Ball" and v2.itemId == p2 and BallCopySelection.available(v2) then
		return v
	end

	local v3 = nil
	local v4 = nil

	for k, item in items do
		if not (item.itemType == "Ball" and item.itemId == p2) then
			continue
		end

		local v5 = item
		local v6 = k

		local function better()
			if not v3 then
				return true
			end

			local available = BallCopySelection.available(v5)

			if available ~= BallCopySelection.available(v3) then
				return available
			end

			local killCount

			if type(v5.metadata) == "table" then
				killCount = v5.metadata.killCount
			else
				killCount = false
			end

			local killCount2

			if type(v3.metadata) == "table" then
				killCount2 = v3.metadata.killCount
			else
				killCount2 = false
			end

			local v7 = type(killCount) ~= "number" and -1 or killCount
			local v8 = type(killCount2) ~= "number" and -1 or killCount2

			if v7 ~= v8 then
				return v8 < v7
			end

			local obtainedAt = v5.obtainedAt or 1e999
			local obtainedAt2 = v3.obtainedAt or 1e999

			if obtainedAt == obtainedAt2 then
				return tostring(v6) < tostring(v4)
			end

			return obtainedAt < obtainedAt2
		end

		if not better() then
			continue
		end

		v4 = k
		v3 = item
	end

	return v4
end

return BallCopySelection