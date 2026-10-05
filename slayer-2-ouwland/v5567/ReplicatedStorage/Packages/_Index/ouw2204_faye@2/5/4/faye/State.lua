require(script.Parent.FayeTypes)
local name = script.Name
return function(func)
	return {
		Func = func,
		__type = name,
		IsState = true
	}
end