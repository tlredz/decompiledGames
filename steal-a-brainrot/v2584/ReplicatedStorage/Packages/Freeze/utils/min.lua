local function fn(p, p2)
	return p2 < p
end

return function(items, callback)
	if callback == nil then
		callback = fn
	end

	local v = nil
	local v2 = nil

	for k, item in items do
		if not (v == nil or callback(v, item) == true) then
			continue
		end

		v2 = k
		v = item
	end

	return v, v2
end