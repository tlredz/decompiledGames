return function(items, p)
	for _, item in items do
		if item == p then
			return true
		end
	end

	return false
end