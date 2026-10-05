local equalObjects = require(script.Parent.equalObjects)
local compareDeep

compareDeep = function(items, items2)
	if type(items) ~= "table" or type(items2) ~= "table" then
		return items == items2
	end

	for k, item in pairs(items) do
		if not compareDeep(items2[k], item) then
			return false
		end
	end

	for k, item in pairs(items2) do
		if not compareDeep(items[k], item) then
			return false
		end
	end

	return true
end

local function equalsDeep(...)
	if equalObjects(...) then
		return true
	end

	local v = select("#", ...)
	local v2 = select(1, ...)

	for i = 2, v do
		if not compareDeep(v2, (select(i, ...))) then
			return false
		end
	end

	return true
end

return equalsDeep