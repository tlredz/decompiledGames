require(script.Parent.FayeTypes)
return function(tab, callback)
	return {
		Tab = tab,
		Function = callback,
		__type = "Iterate",
		Advanced = true
	}
end