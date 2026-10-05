return function(items, callback)
	for k, item in items do
		if callback(item, k) == false then
			return false
		end
	end

	return true
end