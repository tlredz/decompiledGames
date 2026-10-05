require(script.Parent.FayeTypes)
local name = script.Name
return function(func, params)
	if func == nil then
		return
	else
		return {
			__type = name,
			func = func,
			Params = params
		}
	end
end