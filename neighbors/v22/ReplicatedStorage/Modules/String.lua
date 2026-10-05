return {
	contains = function(value: string, p: string)
		return string.find(value, p, nil, true) and true or false
	end
}