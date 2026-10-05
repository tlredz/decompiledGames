return function(items, callback)
	for k, item in items do
		if callback(item, k) == true then
			return k, item
		end
	end

	return nil
end