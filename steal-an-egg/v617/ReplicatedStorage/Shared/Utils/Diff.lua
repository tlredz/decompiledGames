local deepEquals

deepEquals = function(item, items)
	if item == items or item ~= item and items ~= items then
		return true
	end

	if type(item) ~= "table" or type(items) ~= "table" then
		return false
	end

	for k, item2 in pairs(item) do
		if not deepEquals(item2, items[k]) then
			return false
		end
	end

	for k in pairs(items) do
		if item[k] == nil then
			return false
		end
	end

	return true
end

return function(items, items2, p)
	if type(items) ~= "table" or type(items2) ~= "table" then
		return {}, {}
	end

	local skipKeys

	if p then
		skipKeys = p.SkipKeys
	end

	local result = {}

	for k, item in items2 do
		if skipKeys and skipKeys[k] then
			continue
		end

		local item2 = items[k]

		if item2 == item then
			continue
		end

		if not (typeof(item) ~= typeof(item2) or type(item) ~= "table" or not deepEquals(item, item2)) then
			continue
		end

		result[k] = item
	end

	local result2 = {}

	for k in items do
		if skipKeys and skipKeys[k] or items2[k] ~= nil then
			continue
		end

		result2[k] = true
	end

	return result, result2
end