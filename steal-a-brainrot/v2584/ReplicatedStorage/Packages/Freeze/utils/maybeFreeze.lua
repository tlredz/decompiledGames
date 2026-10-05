return function(list)
	if table.isfrozen(list) then
		return list
	end

	return table.freeze(list)
end