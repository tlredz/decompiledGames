local FayeUtility = require(script.Parent.Misc.FayeUtility)
return function(items, callback)
	if items == nil or FayeUtility.tof(items) ~= FayeUtility.tabletxt then
		return
	end

	if callback == nil then
		return table.clone(items)
	end

	local result = {}

	for k, item in pairs(items) do
		local v, v2 = callback(k, item)

		if v == nil then
			result[k] = nil
		elseif v2 == nil then
			result[k] = v
		else
			result[v] = v2
		end
	end

	return result
end