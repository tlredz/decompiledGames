return function(items, callback)
	for k, item in items do
		if callback(item, k) == true then
			return true
		end
	end

	return false
end