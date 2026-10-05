require(script.Parent.FayeTypes)
local name = script.Name
return function(tab, callback, _)
	return {
		Tab = tab,
		Function = callback,
		__type = name
	}
end