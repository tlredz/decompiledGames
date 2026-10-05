return function(value)
	return (value:sub(#value - ((value:reverse():find("%u") or #value + 1) - 1)):gsub("%d+$", ""))
end