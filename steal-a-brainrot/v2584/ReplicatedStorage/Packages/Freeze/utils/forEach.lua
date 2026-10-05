return function(items, callback)
	local count = 0

	for k, item in items do
		count += 1

		if callback(item, k) == false then
			break
		end
	end

	return count
end