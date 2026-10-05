require(script.Parent.Parent.Types)
local Index = require(script.Parent.Index)
local Legacy = {
	matches = function(list, p)
		if not Index.isArray(list) then
			return list == p
		end

		return p ~= nil and table.find(list, p) ~= nil
	end
}

function Legacy.checkAdvancedQuery(p, data)
	if data.Operation == "EQ" then
		return Legacy.matches(p, data.Value)
	end

	if data.Operation == "NEQ" then
		return not Legacy.matches(p, data.Value)
	end

	if data.Operation == "OR" then
		for _, value in data.Values do
			if Legacy.matches(p, value) then
				return true
			end
		end

		return false
	else
		if data.Operation ~= "NOR" then
			error((`unsupported query operation: {data.Operation}`))
			return
		end

		for _, value in data.Values do
			if Legacy.matches(p, value) then
				return false
			end
		end

		return true
	end
end

function Legacy.checkQuery(items, p)
	if p == nil then
		return true
	end

	if type(p) ~= "table" then
		return Legacy.matches(items, p)
	end

	if p.Operation then
		return Legacy.checkAdvancedQuery(items, p)
	end

	assert(#p == 0, "arrays are not a valid query format")

	if type(items) ~= "table" then
		return false
	end

	local v = {}

	for k in items do
		v[k] = true
	end

	for k in p do
		v[k] = true
	end

	for k in v do
		if not Legacy.checkQuery(items[k], p[k]) then
			return false
		end
	end

	return true
end

function Legacy.select(items, p)
	local result = {}

	for _, item in items do
		if Legacy.checkQuery(item, p) then
			table.insert(result, item)
		end
	end

	return result
end

return Legacy