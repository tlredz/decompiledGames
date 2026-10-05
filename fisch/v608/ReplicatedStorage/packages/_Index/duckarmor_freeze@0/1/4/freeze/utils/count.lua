local function count(items, callback)
	local count2 = 0

	for k, item in items do
		if callback == nil or callback(item, k) then
			count2 += 1
		end
	end

	return count2
end

return count