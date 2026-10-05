require(script.Parent.FayeTypes)
return function(func)
	return {
		Func = func,
		__type = "State"
	}
end