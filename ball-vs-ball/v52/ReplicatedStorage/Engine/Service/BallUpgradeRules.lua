local BallUpgradeRules = {
	REQUIRED = 6,
	killCount = function(p)
		local killCount

		if type(p.metadata) == "table" then
			killCount = p.metadata.killCount
		end

		if killCount == nil then
			killCount = p.killCount
		end

		return killCount
	end
}

function BallUpgradeRules.kind(p)
	if p.serial ~= nil then
		return "Rainbow"
	end

	if BallUpgradeRules.killCount(p) == nil then
		return "Classic"
	end

	return "Shiny"
end

function BallUpgradeRules.eligible(data, p)
	if type(data) ~= "table" or data.itemType ~= "Ball" or type(data.itemId) ~= "string" or p and data.ownerUserId ~= p then
		return false
	end

	if type(data.locks) ~= "nil" and (type(data.locks) ~= "table" or next(data.locks) ~= nil) then
		return false
	end

	local v = BallUpgradeRules.killCount(data)

	if v == nil or type(v) == "number" and v == v and not (v < 0) and v ~= 1e999 and v % 1 == 0 then
		return BallUpgradeRules.kind(data) ~= "Rainbow"
	end

	return false
end

function BallUpgradeRules.targetFeature(p, p2)
	if not BallUpgradeRules.eligible(p, p2) then
		return nil
	end

	if BallUpgradeRules.kind(p) == "Classic" then
		return "killTracking"
	end

	return "serial"
end

function BallUpgradeRules.collect(options, p, p2, p3, p4, p5)
	local result = {}

	for k, v in options or {} do
		if v.itemId ~= p or not BallUpgradeRules.eligible(v, p3) or p4 and p4[k] or not (not p5 or BallUpgradeRules.kind(v) == p5) then
			continue
		end

		table.insert(result, {
			id = k,
			item = v
		})
	end

	table.sort(result, function(a, b)
		if a.item.tradable == true == (b.item.tradable == true) then
			return a.id < b.id
		end

		return a.item.tradable == true == p2
	end)
	return result
end

function BallUpgradeRules.validate(p, p2, value, items)
	if type(value) ~= "string" or type(items) ~= "table" then
		return nil, "invalid_materials"
	end

	local main

	if type(p) == "table" then
		main = p[value]
	else
		main = false
	end

	local targetFeature = BallUpgradeRules.targetFeature(main, p2)

	if not targetFeature then
		return nil, "ineligible"
	end

	local consumed = {
		[value] = true
	}
	local count = 0

	for k, item in pairs(items) do
		count += 1

		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or BallUpgradeRules.REQUIRED - 1 < k then
			return nil, "invalid_count"
		end

		if type(item) ~= "string" or consumed[item] then
			return nil, "invalid_materials"
		end

		consumed[item] = true
	end

	if count ~= BallUpgradeRules.REQUIRED - 1 then
		return nil, "invalid_count"
	end

	local tradable = true
	local total = 0

	for k in consumed do
		local v4 = p[k]

		if not BallUpgradeRules.eligible(v4, p2) then
			return nil, "ineligible"
		end

		if v4.itemId ~= main.itemId or BallUpgradeRules.kind(v4) ~= BallUpgradeRules.kind(main) then
			return nil, "mismatch"
		end

		tradable = tradable and v4.tradable == true
		total += BallUpgradeRules.killCount(v4) or 0
	end

	return {
		main = main,
		consumed = consumed,
		tradable = tradable,
		feature = targetFeature,
		killCount = total
	}
end

return BallUpgradeRules