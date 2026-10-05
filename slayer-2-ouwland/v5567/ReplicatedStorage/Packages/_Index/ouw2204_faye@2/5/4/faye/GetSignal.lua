require(script.Parent.FayeTypes)
local name = script.Name
return function(method: string, p2: string, runOnInitialization: boolean?, thread)
	if method == nil or p2 == nil then
		return
	else
		return {
			Method = method,
			Index = p2,
			RunOnInitialization = runOnInitialization,
			Thread = thread,
			__type = name
		}
	end
end